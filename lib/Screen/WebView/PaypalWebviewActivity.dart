import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';

class PaypalWebview extends StatefulWidget {
  final String? url, from, msg, amt, orderId;

  const PaypalWebview(
      {Key? key, this.url, this.from, this.msg, this.amt, this.orderId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayPalWebview();
  }
}

class StatePayPalWebview extends State<PaypalWebview> {
  String message = '';
  bool isloading = true;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  DateTime? currentBackPressTime;
  late UserProvider userProvider;
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        titleSpacing: 0,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: DesignConfiguration.shadow(),
            child: Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  DateTime now = DateTime.now();
                  if (currentBackPressTime == null ||
                      now.difference(currentBackPressTime!) >
                          const Duration(seconds: 2)) {
                    currentBackPressTime = now;
                    setSnackbar(
                      "${getTranslated(
                        context,
                        "Don't press back while doing payment!",
                      )}\n ${getTranslated(context, 'EXIT_WR')!}",
                      context,
                    );
                  }
                  if (widget.from == 'order' && widget.orderId != null) {
                    deleteOrder();
                  }
                  Routes.pop(context);
                },
                child: const Center(
                  child: Icon(
                    Icons.keyboard_arrow_left,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
        title: Text(
          appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Stack(
          children: <Widget>[
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>{
                _toasterJavascriptChannel(context),
              },
              navigationDelegate: (NavigationRequest request) async {
                if (request.url.startsWith(PAYPAL_RESPONSE_URL) ||
                    request.url.startsWith(FLUTTERWAVE_RES_URL)) {
                  if (mounted) {
                    setState(() {
                      isloading = true;
                    });
                  }
                  String responseurl = request.url;
                  if (responseurl.contains('Failed') ||
                      responseurl.contains('failed')) {
                    if (mounted) {
                      setState(() {
                        isloading = false;
                        message = 'Transaction Failed';
                      });
                    }
                    Timer(const Duration(seconds: 1), () {
                      Routes.pop(context);
                    });
                  } else if (responseurl.contains('Completed') ||
                      responseurl.contains('completed') ||
                      responseurl.toLowerCase().contains('success')) {
                    if (mounted) {
                      setState(() {
                        message = 'Transaction Successfull';
                      });
                    }
                    List<String> testdata = responseurl.split('&');
                    for (String data in testdata) {
                      if (data.split('=')[0].toLowerCase() == 'tx' ||
                          data.split('=')[0].toLowerCase() ==
                              'transaction_id') {
                        userProvider.setCartCount('0');
                        if (widget.from == 'order') {
                          if (request.url.startsWith(PAYPAL_RESPONSE_URL)) {
                            Routes.navigateToCustomerSupportScreen(context);
                          } else {
                            String txid = data.split('=')[1];
                            AddTransaction(
                              txid,
                              widget.orderId!,
                              SUCCESS,
                              'Order placed successfully',
                              true,
                            );
                          }
                        } else if (widget.from == 'wallet') {
                          if (request.url.startsWith(FLUTTERWAVE_RES_URL)) {
                            String txid = data.split('=')[1];
                            setSnackbar('Transaction Successful', context);
                            if (mounted) {
                              setState(
                                () {
                                  isloading = false;
                                },
                              );
                            }
                            Timer(
                              const Duration(seconds: 1),
                              () {
                                Routes.pop(context);
                              },
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        }

                        break;
                      }
                    }
                  }

                  if (request.url.startsWith(PAYPAL_RESPONSE_URL) &&
                      widget.orderId != null &&
                      (responseurl.contains('Canceled-Reversal') ||
                          responseurl.contains('Denied') ||
                          responseurl.contains('Failed'))) deleteOrder();
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                setState(() {
                  isloading = false;
                });
              },
            ),
            isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            message.trim().isEmpty
                ? Container()
                : Center(
                    child: Container(
                      color: colors.primary,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.white,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(
          "${getTranslated(
            context,
            "Don't press back while doing payment!",
          )}\n ${getTranslated(
            context,
            'EXIT_WR',
          )!}",
          context);
      return Future.value(false);
    }
    if (widget.from == 'order' && widget.orderId != null) {
      deleteOrder();
    }
    Navigator.pop(context, 'true');
    return Future.value(true);
  }

  Future<void> deleteOrder() async {
    try {
      var parameter = {
        ORDER_ID: widget.orderId,
      };

      Response response =
          await post(deleteOrderApi, body: parameter, headers: headers).timeout(
        const Duration(
          seconds: timeOut,
        ),
      );
      if (mounted) {
        setState(
          () {
            isloading = false;
          },
        );
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);

      setState(
        () {
          isloading = false;
        },
      );
    }
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'Toaster',
      onMessageReceived: (JavascriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.message,
              style: const TextStyle(
                fontFamily: 'ubuntu',
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> AddTransaction(String tranId, String orderID, String status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: context.read<CartProvider>().payMethod,
        TXNID: tranId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };

      Response response =
          await post(addTransactionApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      DateTime now = DateTime.now();
      currentBackPressTime = now;
      var getdata = json.decode(response.body);

      bool error = getdata['error'];
      String? msg1 = getdata['message'];
      if (!error) {
        if (redirect) {
          userProvider.setCartCount('0');
          context.read<CartProvider>().promoAmt = 0;
          context.read<CartProvider>().remWalBal = 0;
          context.read<CartProvider>().usedBalance = 0;
          context.read<CartProvider>().payMethod = '';
          context.read<CartProvider>().isPromoValid = false;
          context.read<CartProvider>().isUseWallet = false;
          context.read<CartProvider>().isPayLayShow = true;
          context.read<CartProvider>().selectedMethod = null;
          context.read<CartProvider>().totalPrice = 0;
          context.read<CartProvider>().oriPrice = 0;
          context.read<CartProvider>().taxPer = 0;
          context.read<CartProvider>().deliveryCharge = 0;
          Routes.navigateToOrderSuccessScreen(context);
        }
      } else {
        setSnackbar(msg1!, context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }
}
