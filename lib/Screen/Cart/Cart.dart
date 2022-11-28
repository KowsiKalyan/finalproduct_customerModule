import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:paytm/paytm.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../Helper/Color.dart';
import '../../Helper/String.dart';
import '../StripeService/Stripe_Service.dart';
import '../../Helper/routes.dart';
import '../../Model/Model.dart';
import '../../Model/Section_Model.dart';
import '../../Model/User.dart';
import '../../Provider/paymentProvider.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/promoCodeProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/simmerEffect.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../Payment/Payment.dart';
import '../WebView/PaypalWebviewActivity.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../WebView/midtransWebView.dart';
import 'Widget/attachPrescriptionImageWidget.dart';
import 'Widget/bankTransferContentWidget.dart';
import 'Widget/cartIteamWidget.dart';
import 'Widget/cartListIteamWidget.dart';
import 'Widget/confirmDialog.dart';
import 'Widget/noIteamCartWidget.dart';
import 'Widget/orderSummeryWidget.dart';
import 'Widget/paymentWidget.dart';
import 'Widget/saveLaterIteamWidget.dart';
import 'Widget/setAddress.dart';

class Cart extends StatefulWidget {
  final bool fromBottom;

  const Cart({Key? key, required this.fromBottom}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateCart();
}

String? stripePayId;

class StateCart extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  bool _isCartLoad = true, _placeOrder = true, _isSaveLoad = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? msg;
  bool _isLoading = true;
  Razorpay? _razorpay;
  final paystackPlugin = PaystackPlugin();
  final ScrollController _scrollControllerOnCartItems = ScrollController();
  final ScrollController _scrollControllerOnSaveForLaterItems =
      ScrollController();
  bool isAvailable = true;
  String razorpayOrderId = '';
  String? rozorpayMsg;
  String orderId = '';

  Future<void> cartFun({
    required int index,
    required int selectedPos,
    required double total,
  }) async {
    db.moveToCartOrSaveLater(
      'save',
      context
          .read<CartProvider>()
          .saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .id!,
      context.read<CartProvider>().saveLaterList[index].id!,
      context,
    );

    context.read<CartProvider>().productIds.add(context
        .read<CartProvider>()
        .saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .id!);
    context.read<CartProvider>().productIds.remove(context
        .read<CartProvider>()
        .saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .id!);
    context.read<CartProvider>().oriPrice =
        context.read<CartProvider>().oriPrice + total;
    context
        .read<CartProvider>()
        .addCartItem(context.read<CartProvider>().saveLaterList[index]);
    context.read<CartProvider>().saveLaterList.removeAt(index);

    context.read<CartProvider>().addCart = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  Future<void> saveForLaterFun({
    required int index,
    required int selectedPos,
    required double total,
    required List<SectionModel> cartList,
  }) async {
    db.moveToCartOrSaveLater(
      'cart',
      cartList[index].productList![0].prVarientList![selectedPos].id!,
      cartList[index].id!,
      context,
    );
    context
        .read<CartProvider>()
        .productIds
        .add(cartList[index].productList![0].prVarientList![selectedPos].id!);
    context.read<CartProvider>().productIds.remove(
        cartList[index].productList![0].prVarientList![selectedPos].id!);
    context.read<CartProvider>().oriPrice =
        context.read<CartProvider>().oriPrice - total;
    context.read<CartProvider>().saveLaterList.add(
          SectionModel(
            id: cartList[index].id,
            varientId: cartList[index].varientId,
            qty: '1',
            sellerId: cartList[index].sellerId,
            productList: cartList[index].productList,
          ),
        );
    context.read<CartProvider>().removeCartItem(
        cartList[index].productList![0].prVarientList![selectedPos].id!);

    context.read<CartProvider>().saveLater = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().setprescriptionImages([]);
    context.read<CartProvider>().selectedMethod = null;
    context.read<CartProvider>().selectedMethod = null;
    context.read<CartProvider>().payMethod = null;
    context.read<CartProvider>().deliverable = false;
    callApi();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  callApi() async {
    context.read<CartProvider>().setProgress(false);

    if (CUR_USERID != null) {
      _getCart('0');
      _getSaveLater('1');
    } else {
      context.read<CartProvider>().productIds = (await db.getCart())!;
      _getOffCart();
      context.read<CartProvider>().productVariantIds =
          (await db.getSaveForLater())!;
      _getOffSaveLater();
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isCartLoad = true;
        _isSaveLoad = true;
      });
    }
    isAvailable = true;
    if (CUR_USERID != null) {
      clearAll();

      _getCart('0');
      return _getSaveLater('1');
    } else {
      context.read<CartProvider>().oriPrice = 0;
      context.read<CartProvider>().saveLaterList.clear();
      context.read<CartProvider>().productIds = (await db.getCart())!;
      await _getOffCart();
      context.read<CartProvider>().productVariantIds =
          (await db.getSaveForLater())!;
      await _getOffSaveLater();
    }
  }

  clearAll() {
    context.read<CartProvider>().totalPrice = 0;
    context.read<CartProvider>().oriPrice = 0;
    context.read<CartProvider>().taxPer = 0;
    context.read<CartProvider>().deliveryCharge = 0;
    context.read<CartProvider>().addressList.clear();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        context.read<CartProvider>().setCartlist([]);
        context.read<CartProvider>().setProgress(false);
      },
    );
    context.read<CartProvider>().promoAmt = 0;
    context.read<CartProvider>().remWalBal = 0;
    context.read<CartProvider>().usedBalance = 0;
    context.read<CartProvider>().payMethod = '';
    context.read<CartProvider>().isPromoValid = false;
    context.read<CartProvider>().isUseWallet = false;
    context.read<CartProvider>().isPayLayShow = true;
    context.read<CartProvider>().selectedMethod = null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    context.read<CartProvider>().noteC.dispose();
    context.read<CartProvider>().promoC.dispose();

    for (int i = 0; i < context.read<CartProvider>().controller.length; i++) {
      context.read<CartProvider>().controller[i].dispose();
    }
    _scrollControllerOnCartItems.removeListener(() {});
    _scrollControllerOnSaveForLaterItems.removeListener(() {});
    if (_razorpay != null) _razorpay!.clear();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNow() {
    setState(() {});
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (BuildContext context) => super.widget),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  updatePromo(String promo) {
    setState(
      () {
        context.read<CartProvider>().isPromoLen = false;
        context.read<CartProvider>().promoC.text = promo;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget.fromBottom
          ? null
          : getSimpleAppBar(getTranslated(context, 'CART')!, context),
      body: isNetworkAvail
          ? CUR_USERID != null
              ? Stack(
                  children: <Widget>[
                    _showContent(context),
                    Selector<CartProvider, bool>(
                      builder: (context, data, child) {
                        return DesignConfiguration.showCircularProgress(
                            data, colors.primary);
                      },
                      selector: (_, provider) => provider.isProgress,
                    ),
                  ],
                )
              : Stack(
                  children: <Widget>[
                    _showContent1(context),
                    Selector<CartProvider, bool>(
                      builder: (context, data, child) {
                        return DesignConfiguration.showCircularProgress(
                            data, colors.primary);
                      },
                      selector: (_, provider) => provider.isProgress,
                    ),
                  ],
                )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Future<void> _getCart(String save) async {
    isNetworkAvail = await isNetworkAvailable();

    if (isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};

        apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            context.read<CartProvider>().oriPrice =
                double.parse(getdata[SUB_TOTAL]);

            context.read<CartProvider>().taxPer =
                double.parse(getdata[TAX_PER]);

            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().deliveryCharge +
                    context.read<CartProvider>().oriPrice;

            List<SectionModel> cartList = (data as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();

            context.read<CartProvider>().setCartlist(cartList);

            if (getdata.containsKey(PROMO_CODES)) {
              var promo = getdata[PROMO_CODES];
              context.read<CartProvider>().promoList =
                  (promo as List).map((e) => Promo.fromJson(e)).toList();
            }

            for (int i = 0; i < cartList.length; i++) {
              context
                  .read<CartProvider>()
                  .controller
                  .add(TextEditingController());
            }
            setState(() {});
          } else {
            if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
          }
          if (mounted) {
            setState(() {
              _isCartLoad = false;
            });
          }

          _getAddress();
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> _getOffCart() async {
    if (context.read<CartProvider>().productIds.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        var parameter = {
          'product_variant_ids':
              context.read<CartProvider>().productIds.join(',')
        };
        context.read<ProductListProvider>().setProductListParameter(parameter);
        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              if (!error) {
                var data = value['data'];
                setState(() {
                  context.read<CartProvider>().setCartlist([]);

                  context.read<CartProvider>().oriPrice = 0;
                });

                List<Product> cartList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                for (int i = 0; i < cartList.length; i++) {
                  for (int j = 0; j < cartList[i].prVarientList!.length; j++) {
                    if (context
                        .read<CartProvider>()
                        .productIds
                        .contains(cartList[i].prVarientList![j].id)) {
                      String qty = (await db.checkCartItemExists(
                          cartList[i].id!, cartList[i].prVarientList![j].id!))!;

                      List<Product>? prList = [];
                      cartList[i].prVarientList![j].cartCount = qty;
                      prList.add(cartList[i]);

                      context.read<CartProvider>().addCartItem(
                            SectionModel(
                              id: cartList[i].id,
                              varientId: cartList[i].prVarientList![j].id,
                              qty: qty,
                              productList: prList,
                              sellerId: cartList[i].seller_id,
                            ),
                          );

                      double price =
                          double.parse(cartList[i].prVarientList![j].disPrice!);
                      if (price == 0) {
                        price =
                            double.parse(cartList[i].prVarientList![j].price!);
                      }
                      double total =
                          qty == '' ? price : (price * int.parse(qty));

                      setState(
                        () {
                          context.read<CartProvider>().oriPrice =
                              context.read<CartProvider>().oriPrice + total;
                        },
                      );
                    }
                  }
                }
                setState(() {});
              }
              if (mounted) {
                setState(
                  () {
                    _isCartLoad = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), _scaffoldKey);
            },
          ),
        );
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(
        () {
          _isCartLoad = false;
        },
      );
    }
  }

  Future<void> _getOffSaveLater() async {
    if (context.read<CartProvider>().productVariantIds.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        var parameter = {
          'product_variant_ids':
              context.read<CartProvider>().productVariantIds.join(',')
        };
        context.read<ProductListProvider>().setProductListParameter(parameter);

        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              String? msg = value['message'];
              if (!error) {
                var data = value['data'];
                context.read<CartProvider>().saveLaterList.clear();
                List<Product> cartList = (data as List)
                    .map((data) => Product.fromJson(data))
                    .toList();
                for (int i = 0; i < cartList.length; i++) {
                  for (int j = 0; j < cartList[i].prVarientList!.length; j++) {
                    if (context
                        .read<CartProvider>()
                        .productVariantIds
                        .contains(cartList[i].prVarientList![j].id)) {
                      String qty = (await db.checkSaveForLaterExists(
                          cartList[i].id!, cartList[i].prVarientList![j].id!))!;
                      List<Product>? prList = [];
                      prList.add(cartList[i]);
                      context.read<CartProvider>().saveLaterList.add(
                            SectionModel(
                              id: cartList[i].id,
                              varientId: cartList[i].prVarientList![j].id,
                              qty: qty,
                              productList: prList,
                              sellerId: cartList[i].seller_id,
                            ),
                          );
                    }
                  }
                }

                setState(() {});
              }
              if (mounted) {
                setState(
                  () {
                    _isSaveLoad = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), _scaffoldKey);
            },
          ),
        );
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } else {
      setState(
        () {
          _isSaveLoad = false;
        },
      );
      context.read<CartProvider>().saveLaterList = [];
    }
  }

  Future<void> _getSaveLater(String save) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];
            context.read<CartProvider>().saveLaterList = (data as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();
            context.read<CartProvider>().saveLaterList.forEach((element) {});
            List<SectionModel> cartList = context.read<CartProvider>().cartList;
            for (int i = 0; i < cartList.length; i++) {
              context
                  .read<CartProvider>()
                  .controller
                  .add(TextEditingController());
            }
          } else {
            if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
          }
          if (mounted) setState(() {});
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }

    return;
  }

  setSnackbar(
      String msg, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.black,
            fontFamily: 'ubuntu',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 1.0,
      ),
    );
  }

  _showContent1(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;

    return _isCartLoad || _isSaveLoad
        ? const ShimmerEffect()
        : cartList.isEmpty && context.read<CartProvider>().saveLaterList.isEmpty
            ? const EmptyCart()
            : Container(
                color: Theme.of(context).colorScheme.lightWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: RefreshIndicator(
                          color: colors.primary,
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            controller: _scrollControllerOnCartItems,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: cartList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return CartListViewLayOut(
                                      index: index,
                                      setState: setStateNow,
                                      saveForLatter: saveForLaterFun,
                                    );
                                  },
                                ),
                                context
                                        .read<CartProvider>()
                                        .saveLaterList
                                        .isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          getTranslated(
                                              context, 'SAVEFORLATER_BTN')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                      )
                                    : Container(
                                        height: 0,
                                      ),
                                if (context
                                    .read<CartProvider>()
                                    .saveLaterList
                                    .isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: context
                                        .read<CartProvider>()
                                        .saveLaterList
                                        .length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return SaveLatterIteam(
                                        index: index,
                                        setState: setStateNow,
                                        cartFunc: cartFun,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        context.read<CartProvider>().cartList.length != 0
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: 5.0,
                                  end: 10.0,
                                  start: 10.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 5,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getTranslated(
                                                context, 'TOTAL_PRICE')!,
                                          ),
                                          Text(
                                            '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().oriPrice)!} ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontFamily: 'ubuntu',
                                                ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 0,
                              ),
                      ],
                    ),
                    cartList.isNotEmpty
                        ? SimBtn(
                            size: 0.9,
                            height: 40,
                            borderRadius: circularBorderRadius5,
                            title: getTranslated(context, 'PROCEED_CHECKOUT'),
                            onBtnSelected: () async {
                              Routes.navigateToLoginScreen(context);
                            },
                          )
                        : Container(
                            height: 0,
                          ),
                  ],
                ),
              );
  }

  _showContent(BuildContext context) {
    return _isCartLoad
        ? const ShimmerEffect()
        : context.read<CartProvider>().cartList.isEmpty &&
                context.read<CartProvider>().saveLaterList.isEmpty
            ? const EmptyCart()
            : Container(
                color: Theme.of(context).colorScheme.lightWhite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 10.0, left: 10.0, top: 10),
                        child: RefreshIndicator(
                          color: colors.primary,
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            controller: _scrollControllerOnCartItems,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (context
                                    .read<CartProvider>()
                                    .cartList
                                    .isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: context
                                        .read<CartProvider>()
                                        .cartList
                                        .length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return CartListViewLayOut(
                                        index: index,
                                        setState: setStateNow,
                                        saveForLatter: saveForLaterFun,
                                      );
                                    },
                                  ),
                                if (context
                                    .read<CartProvider>()
                                    .saveLaterList
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getTranslated(
                                          context, 'SAVEFORLATER_BTN')!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontFamily: 'ubuntu',
                                          ),
                                    ),
                                  ),
                                if (context
                                    .read<CartProvider>()
                                    .saveLaterList
                                    .isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: context
                                        .read<CartProvider>()
                                        .saveLaterList
                                        .length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return SaveLatterIteam(
                                        index: index,
                                        setState: setStateNow,
                                        cartFunc: cartFun,
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (context.read<CartProvider>().promoList.isNotEmpty &&
                            context.read<CartProvider>().oriPrice > 0)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 5.0, end: 10.0, start: 10.0),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                    end: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.white,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(
                                      5,
                                    ),
                                  ),
                                  child: TextField(
                                    textDirection: Directionality.of(context),
                                    controller:
                                        context.read<CartProvider>().promoC,
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                      border: InputBorder.none,
                                      hintText: getTranslated(
                                              context, 'PROMOCODE_LBL') ??
                                          '',
                                    ),
                                    onChanged: (val) {
                                      setState(
                                        () {
                                          if (val.isEmpty) {
                                            context
                                                .read<CartProvider>()
                                                .isPromoLen = false;
                                            context
                                                .read<CartProvider>()
                                                .promoAmt = 0;
                                            context
                                                .read<CartProvider>()
                                                .isPromoValid = false;
                                          } else {
                                            context
                                                .read<CartProvider>()
                                                .promoAmt = 0;
                                            context
                                                .read<CartProvider>()
                                                .isPromoLen = true;
                                            context
                                                .read<CartProvider>()
                                                .isPromoValid = false;
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  end: 0,
                                  child: InkWell(
                                    onTap: () {
                                      Routes.navigateToPromoCodeScreen(
                                        context,
                                        'cart',
                                        updatePromo,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(11),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colors.grad1Color,
                                              colors.grad2Color
                                            ],
                                            stops: [
                                              0,
                                              1
                                            ]),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: colors.whiteTemp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: 5.0,
                            end: 10.0,
                            start: 10.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (context.read<CartProvider>().isPromoValid!)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getTranslated(
                                            context, 'PROMO_CODE_DIS_LBL')!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack2,
                                              fontFamily: 'ubuntu',
                                            ),
                                      ),
                                      Text(
                                        '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().promoAmt)!} ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .lightBlack2,
                                              fontFamily: 'ubuntu',
                                            ),
                                      )
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        getTranslated(context, 'TOTAL_PRICE')!),
                                    Text(
                                      '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().oriPrice)!} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontFamily: 'ubuntu',
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SimBtn(
                      size: 0.9,
                      height: 40,
                      borderRadius: circularBorderRadius5,
                      title: context.read<CartProvider>().isPromoLen
                          ? getTranslated(context, 'VALI_PRO_CODE')
                          : getTranslated(context, 'PROCEED_CHECKOUT'),
                      onBtnSelected: () async {
                        if (context.read<CartProvider>().isPromoLen == false) {
                          if (context.read<CartProvider>().oriPrice > 0) {
                            FocusScope.of(context).unfocus();
                            if (isAvailable) {
                              if (context.read<CartProvider>().totalPrice !=
                                  0) {
                                checkout();
                              }
                            } else {
                              setSnackbar(
                                  getTranslated(
                                      context, 'CART_OUT_OF_STOCK_MSG')!,
                                  _scaffoldKey);
                            }
                            if (mounted) setState(() {});
                          } else {
                            setSnackbar(getTranslated(context, 'ADD_ITEM')!,
                                _scaffoldKey);
                          }
                        } else {
                          await context
                              .read<PromoCodeProvider>()
                              .validatePromocode(
                                  check: false,
                                  context: context,
                                  promocode:
                                      context.read<CartProvider>().promoC.text,
                                  update: setStateNow)
                              .then(
                            (value) {
                              setState(
                                () {
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
  }

  checkout() {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            context.read<CartProvider>().checkoutState = setState;
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                key: _checkscaffoldKey,
                body: isNetworkAvail
                    ? context.read<CartProvider>().cartList.isEmpty
                        ? const EmptyCart()
                        : _isLoading
                            ? const ShimmerEffect()
                            : Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SetAddress(update: setStateNow),
                                                AttachPrescriptionImages(
                                                    cartList: context
                                                        .read<CartProvider>()
                                                        .cartList),
                                                SelectPayment(
                                                    updateCheckout:
                                                        updateCheckout),
                                                cartItems(context
                                                    .read<CartProvider>()
                                                    .cartList),
                                                OrderSummery(
                                                  cartList: context
                                                      .read<CartProvider>()
                                                      .cartList,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Selector<CartProvider, bool>(
                                          builder: (context, data, child) {
                                            return DesignConfiguration
                                                .showCircularProgress(
                                                    data, colors.primary);
                                          },
                                          selector: (_, provider) =>
                                              provider.isProgress,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context).colorScheme.white,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  start: 15.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().totalPrice)!} ',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                              Text(
                                                '${context.read<CartProvider>().cartList.length} Items',
                                                style: const TextStyle(
                                                  fontFamily: 'ubuntu',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10.0,
                                          ),
                                          child: SimBtn(
                                            borderRadius: circularBorderRadius5,
                                            size: 0.4,
                                            title: getTranslated(
                                                context, 'PLACE_ORDER'),
                                            onBtnSelected: _placeOrder
                                                ? () {
                                                    context
                                                        .read<CartProvider>()
                                                        .checkoutState!(
                                                      () {
                                                        _placeOrder = false;
                                                      },
                                                    );
                                                    if (context
                                                                .read<
                                                                    CartProvider>()
                                                                .selAddress ==
                                                            '' ||
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .selAddress!
                                                            .isEmpty) {
                                                      msg = getTranslated(
                                                          context,
                                                          'addressWarning');
                                                      Routes
                                                          .navigateToManageAddressScreen(
                                                              context, false);

                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else if (context
                                                                .read<
                                                                    CartProvider>()
                                                                .payMethod ==
                                                            null ||
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .payMethod!
                                                            .isEmpty) {
                                                      msg = getTranslated(
                                                          context,
                                                          'payWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                                  updateCheckout,
                                                                  msg),
                                                        ),
                                                      );
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else if (context
                                                            .read<
                                                                CartProvider>()
                                                            .isTimeSlot! &&
                                                        int.parse(context
                                                                .read<
                                                                    PaymentProvider>()
                                                                .allowDay!) >
                                                            0 &&
                                                        (context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .selDate ==
                                                                null ||
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .selDate!
                                                                .isEmpty)) {
                                                      msg = getTranslated(
                                                          context,
                                                          'dateWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                            updateCheckout,
                                                            msg,
                                                          ),
                                                        ),
                                                      );
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else if (context
                                                            .read<
                                                                CartProvider>()
                                                            .isTimeSlot! &&
                                                        context
                                                            .read<
                                                                PaymentProvider>()
                                                            .timeSlotList
                                                            .isNotEmpty &&
                                                        (context
                                                                    .read<
                                                                        CartProvider>()
                                                                    .selTime ==
                                                                null ||
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .selTime!
                                                                .isEmpty)) {
                                                      msg = getTranslated(
                                                          context,
                                                          'timeWarning');
                                                      Navigator.push(
                                                        context,
                                                        CupertinoPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Payment(
                                                            updateCheckout,
                                                            msg,
                                                          ),
                                                        ),
                                                      );
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else if (double.parse(
                                                            MIN_ALLOW_CART_AMT!) >
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .oriPrice) {
                                                      setSnackbar(
                                                          getTranslated(context,
                                                              'MIN_CART_AMT')!,
                                                          _checkscaffoldKey);
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else if (!context
                                                        .read<CartProvider>()
                                                        .deliverable) {
                                                      checkDeliverable();
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    } else {
                                                      confirmDialog();
                                                      context
                                                          .read<CartProvider>()
                                                          .checkoutState!(
                                                        () {
                                                          _placeOrder = true;
                                                        },
                                                      );
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                    : NoInterNet(
                        setStateNoInternate: setStateNoInternate,
                        buttonSqueezeanimation: buttonSqueezeanimation,
                        buttonController: buttonController,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _getAddress() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };

        apiBaseHelper.postAPICall(getAddressApi, parameter).then((getdata) {
          bool error = getdata['error'];

          if (!error) {
            var data = getdata['data'];

            context.read<CartProvider>().addressList =
                (data as List).map((data) => User.fromAddress(data)).toList();

            if (context.read<CartProvider>().addressList.length == 1) {
              context.read<CartProvider>().selectedAddress = 0;
              context.read<CartProvider>().selAddress =
                  context.read<CartProvider>().addressList[0].id;
              if (!ISFLAT_DEL) {
                if (context.read<CartProvider>().totalPrice <
                    double.parse(
                        context.read<CartProvider>().addressList[0].freeAmt!)) {
                  context.read<CartProvider>().deliveryCharge = double.parse(
                      context
                          .read<CartProvider>()
                          .addressList[0]
                          .deliveryCharge!);
                } else {
                  context.read<CartProvider>().deliveryCharge = 0;
                }
              }
            } else {
              for (int i = 0;
                  i < context.read<CartProvider>().addressList.length;
                  i++) {
                if (context.read<CartProvider>().addressList[i].isDefault ==
                    '1') {
                  context.read<CartProvider>().selectedAddress = i;
                  context.read<CartProvider>().selAddress =
                      context.read<CartProvider>().addressList[i].id;
                  if (!ISFLAT_DEL) {
                    if (context.read<CartProvider>().totalPrice <
                        double.parse(context
                            .read<CartProvider>()
                            .addressList[i]
                            .freeAmt!)) {
                      context.read<CartProvider>().deliveryCharge =
                          double.parse(context
                              .read<CartProvider>()
                              .addressList[i]
                              .deliveryCharge!);
                    } else {
                      context.read<CartProvider>().deliveryCharge = 0;
                    }
                  }
                }
              }
            }

            if (ISFLAT_DEL) {
              if ((context.read<CartProvider>().oriPrice) <
                  double.parse(MIN_AMT!)) {
                context.read<CartProvider>().deliveryCharge =
                    double.parse(CUR_DEL_CHR!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
            }
            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice +
                    context.read<CartProvider>().deliveryCharge;
          } else {
            if (ISFLAT_DEL) {
              if ((context.read<CartProvider>().oriPrice) <
                  double.parse(MIN_AMT!)) {
                context.read<CartProvider>().deliveryCharge =
                    double.parse(CUR_DEL_CHR!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
            }
            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice +
                    context.read<CartProvider>().deliveryCharge;
          }
          if (mounted) {
            setState(
              () {
                _isLoading = false;
              },
            );
          }
          if (context.read<CartProvider>().checkoutState != null) {
            context.read<CartProvider>().checkoutState!(() {});
          }
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {}
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Map<String, dynamic> result =
        await updateOrderStatus(orderID: orderId, status: PLACED);
    if (!result['error']) {
      await addTransaction(
          response.paymentId, orderId, SUCCESS, rozorpayMsg, true);
    } else {
      setSnackbar('${result['message']}', _checkscaffoldKey);
    }
    if (mounted) {
      context.read<CartProvider>().setProgress(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    var getdata = json.decode(response.message!);
    String errorMsg = getdata['error']['description'];
    setSnackbar(errorMsg, _checkscaffoldKey);
    deleteOrder(orderId);
    if (mounted) {
      context.read<CartProvider>().checkoutState!(
        () {
          _placeOrder = true;
        },
      );
    }
    context.read<CartProvider>().setProgress(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    deleteOrder(orderId);
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      {required String status, required String orderID}) async {
    var parameter = {ORDER_ID: orderID, STATUS: status};
    var result = await ApiBaseHelper().postAPICall(updateOrderApi, parameter);
    return {'error': result['error'], 'message': result['message']};
  }

  updateCheckout() {
    if (mounted) context.read<CartProvider>().checkoutState!(() {});
  }

  razorpayPayment(String orderID, String? msg) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    String? contact = settingsProvider.mobile;
    String? email = settingsProvider.email;
    String amt = ((context.read<CartProvider>().totalPrice.round()) * 100)
        .toStringAsFixed(2);

    if (contact != '' && email != '') {
      context.read<CartProvider>().setProgress(true);

      context.read<CartProvider>().checkoutState!(() {});
      try {
        //create a razorpayOrder for capture payment automatically
        var response = await ApiBaseHelper()
            .postAPICall(createRazorpayOrder, {'order_id': orderID});
        var razorpayOrderID = response['data']['id'];
        var options = {
          KEY: context.read<CartProvider>().razorpayId,
          AMOUNT: amt,
          NAME: settingsProvider.userName,
          'prefill': {CONTACT: contact, EMAIL: email, 'Order Id': orderID},
          'order_id': razorpayOrderID,
        };
        razorpayOrderId = orderID;
        rozorpayMsg = msg;
        _razorpay = Razorpay();
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

        _razorpay!.open(options);
      } catch (e) {}
    } else {
      if (email == '') {
        setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
      } else if (contact == '') {
        setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
      }
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      var parameter = {
        ORDER_ID: orderId,
      };

      http.Response response =
          await post(deleteOrderApi, body: parameter, headers: headers)
              .timeout(const Duration(seconds: timeOut));

      if (mounted) {
        setState(() {});
      }

      Navigator.of(context).pop();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);

      setState(() {});
    }
  }

  void paytmPayment(String? tranId, String orderID, String? status, String? msg,
      bool redirect) async {
    String? paymentResponse;
    context.read<CartProvider>().setProgress(true);

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl =
        '${context.read<CartProvider>().payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderId';

    var parameter = {
      AMOUNT: context.read<CartProvider>().totalPrice.toString(),
      USER_ID: CUR_USERID,
      ORDER_ID: orderId
    };

    try {
      apiBaseHelper.postAPICall(getPytmChecsumkApi, parameter).then(
        (getdata) {
          bool error = getdata['error'];

          if (!error) {
            String txnToken = getdata['txn_token'];
            setState(
              () {
                paymentResponse = txnToken;
              },
            );

            var paytmResponse = Paytm.payWithPaytm(
              callBackUrl: callBackUrl,
              mId: context.read<CartProvider>().paytmMerId!,
              orderId: orderId,
              txnToken: txnToken,
              txnAmount: context.read<CartProvider>().totalPrice.toString(),
              staging: context.read<CartProvider>().payTesting,
            );
            paytmResponse.then(
              (value) {
                context.read<CartProvider>().setProgress(false);

                _placeOrder = true;
                setState(() {});
                context.read<CartProvider>().checkoutState!(
                  () async {
                    if (value['error']) {
                      paymentResponse = value['errorMessage'];

                      if (value['response'] != '') {
                        addTransaction(
                            value['response']['TXNID'],
                            orderId,
                            value['response']['STATUS'] ?? '',
                            paymentResponse,
                            false);
                      }
                    } else {
                      if (value['response'] != '') {
                        paymentResponse = value['response']['STATUS'];
                        if (paymentResponse == 'TXN_SUCCESS') {
                          await updateOrderStatus(
                              orderID: orderID, status: PLACED);
                          addTransaction(value['response']['TXNID'], orderID,
                              SUCCESS, msg, true);
                        } else {
                          deleteOrder(orderID);
                        }
                      }
                    }

                    setSnackbar(paymentResponse!, _checkscaffoldKey);
                  },
                );
              },
            );
          } else {
            context.read<CartProvider>().checkoutState!(
              () {
                _placeOrder = true;
              },
            );

            context.read<CartProvider>().setProgress(false);

            setSnackbar(getdata['message'], _checkscaffoldKey);
          }
        },
        onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        },
      );
    } catch (e) {}
  }

  Future<void> placeOrder(String? tranId) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);

      SettingProvider settingsProvider =
          Provider.of<SettingProvider>(context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId =
            varientId != null ? '$varientId,${sec.varientId!}' : sec.varientId;
        quantity = quantity != null ? '$quantity,${sec.qty!}' : sec.qty;
      }

      String? payVia;
      if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'COD_LBL')) {
        payVia = 'COD';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYPAL_LBL')) {
        payVia = 'PayPal';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYUMONEY_LBL')) {
        payVia = 'PayUMoney';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'RAZORPAY_LBL')) {
        payVia = 'RazorPay';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYSTACK_LBL')) {
        payVia = 'Paystack';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'FLUTTERWAVE_LBL')) {
        payVia = 'Flutterwave';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'STRIPE_LBL')) {
        payVia = 'Stripe';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'PAYTM_LBL')) {
        payVia = 'Paytm';
      } else if (context.read<CartProvider>().payMethod == 'Wallet') {
        payVia = 'Wallet';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'BANKTRAN')) {
        payVia = 'bank_transfer';
      } else if (context.read<CartProvider>().payMethod ==
          getTranslated(context, 'MidTrans')) {
        payVia = 'midtrans';
      } else if (context.read<CartProvider>().payMethod == 'My Fatoorah') {
        payVia = 'my fatoorah';
      }
      var request = http.MultipartRequest('POST', placeOrderApi);
      request.headers.addAll(headers);

      try {
        request.fields[USER_ID] = CUR_USERID!;
        request.fields[MOBILE] = mob;
        request.fields[PRODUCT_VARIENT_ID] = varientId!;
        request.fields[QUANTITY] = quantity!;
        request.fields[TOTAL] =
            context.read<CartProvider>().oriPrice.toString();
        request.fields[FINAL_TOTAL] =
            context.read<CartProvider>().totalPrice.toString();
        request.fields[DEL_CHARGE] =
            context.read<CartProvider>().deliveryCharge.toString();
        request.fields[TAX_PER] =
            context.read<CartProvider>().taxPer.toString();
        request.fields[PAYMENT_METHOD] = payVia!;
        request.fields[ADD_ID] = context.read<CartProvider>().selAddress!;
        request.fields[ISWALLETBALUSED] =
            context.read<CartProvider>().isUseWallet! ? '1' : '0';
        request.fields[WALLET_BAL_USED] =
            context.read<CartProvider>().usedBalance.toString();
        request.fields[ORDER_NOTE] = context.read<CartProvider>().noteC.text;

        if (context.read<CartProvider>().isTimeSlot!) {
          request.fields[DELIVERY_TIME] =
              context.read<CartProvider>().selTime ?? 'Anytime';
          request.fields[DELIVERY_DATE] =
              context.read<CartProvider>().selDate ?? '';
        }
        if (context.read<CartProvider>().isPromoValid!) {
          request.fields[PROMOCODE] = context.read<CartProvider>().promocode!;
          request.fields[PROMO_DIS] =
              context.read<CartProvider>().promoAmt.toString();
        }

        if (context.read<CartProvider>().payMethod ==
            getTranslated(context, 'COD_LBL')) {
          request.fields[ACTIVE_STATUS] = PLACED;
        } else {
          request.fields[ACTIVE_STATUS] = WAITING;
        }

        if (context.read<CartProvider>().prescriptionImages.isEmpty) {
          for (var i = 0;
              i < context.read<CartProvider>().prescriptionImages.length;
              i++) {
            final mimeType = lookupMimeType(
                context.read<CartProvider>().prescriptionImages[i].path);

            var extension = mimeType!.split('/');

            var pic = await http.MultipartFile.fromPath(
              DOCUMENT,
              context.read<CartProvider>().prescriptionImages[i].path,
              contentType: MediaType('image', extension[1]),
            );

            request.files.add(pic);
          }
        }
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        _placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);

          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            orderId = getdata['order_id'].toString();
            if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'RAZORPAY_LBL')) {
              razorpayPayment(orderId, msg);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'STRIPE_LBL')) {
              stripePayment(context.read<CartProvider>().stripePayId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYSTACK_LBL')) {
              paystackPayment(context, tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'PAYTM_LBL')) {
              paytmPayment(tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'FLUTTERWAVE_LBL')) {
              flutterwavePayment(tranId, orderId, SUCCESS, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                getTranslated(context, 'MidTrans')) {
              midTrasPayment(context.read<CartProvider>().stripePayId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (context.read<CartProvider>().payMethod ==
                'My Fatoorah') {
              fatoorahPayment(tranId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else {
              context.read<UserProvider>().setCartCount('0');
              clearAll();
              Routes.navigateToOrderSuccessScreen(context);
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          context.read<CartProvider>().checkoutState!(
            () {
              _placeOrder = true;
            },
          );
        }
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString()
      };
      apiBaseHelper.postAPICall(paypalTransactionApi, parameter).then(
        (getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            String? data = getdata['data'];
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => PaypalWebview(
                  url: data,
                  from: 'order',
                  orderId: orderId,
                ),
              ),
            );
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
          }
          context.read<CartProvider>().setProgress(false);
        },
        onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        },
      );
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  Future<void> addTransaction(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: context.read<CartProvider>().payMethod,
        TXNID: tranId,
        AMOUNT: context.read<CartProvider>().totalPrice.toString(),
        STATUS: status,
        MSG: msg ?? '$status the payment'
      };
      apiBaseHelper.postAPICall(addTransactionApi, parameter).then(
        (getdata) {
          bool error = getdata['error'];
          String? msg1 = getdata['message'];

          if (!error) {
            if (redirect) {
              context.read<UserProvider>().setCartCount('0');
              clearAll();
              Routes.navigateToOrderSuccessScreen(context);
            }
          } else {
            setSnackbar(msg1!, _checkscaffoldKey);
          }
        },
        onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        },
      );
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  paystackPayment(
    BuildContext context,
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    context.read<CartProvider>().setProgress(true);
    await paystackPlugin.initialize(
        publicKey: context.read<CartProvider>().paystackId!);
    String? email = context.read<SettingProvider>().email;

    Charge charge = Charge()
      ..amount = context.read<CartProvider>().totalPrice.toInt()
      ..reference = _getReference()
      ..putMetaData('order_id', orderID)
      ..email = email;
    try {
      CheckoutResponse response = await paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      if (response.status) {
        Map<String, dynamic> result =
            await updateOrderStatus(orderID: orderId, status: PLACED);

        addTransaction(response.reference, orderID, SUCCESS, msg, true);
      } else {
        deleteOrder(orderID);
        setSnackbar(response.message, _checkscaffoldKey);
        if (mounted) {
          context.read<CartProvider>().checkoutState!(
            () {
              _placeOrder = true;
            },
          );
        }
        context.read<CartProvider>().setProgress(false);
      }
    } catch (e) {
      context.read<CartProvider>().setProgress(false);
      rethrow;
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  fatoorahPayment(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        String amount = context.read<CartProvider>().totalPrice.toString();
        String successUrl =
            '${context.read<CartProvider>().myfatoorahSuccessUrl!}?order_id=$orderID&amount=${double.parse(amount)}';
        String errorUrl =
            '${context.read<CartProvider>().myfatoorahErrorUrl!}?order_id=$orderID&amount=${double.parse(amount)}';
        String token = context.read<CartProvider>().myfatoorahToken!;

        context.read<CartProvider>().setProgress(true);
        print("successUrl : ${successUrl} eroor : ${errorUrl}");
        var response = await MyFatoorah.startPayment(
          context: context,
          successChild: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Payment Done Successfully ...!',
                    style: TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 100,
                    child: Icon(
                      Icons.done,
                      size: 100,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          request: context.read<CartProvider>().myfatoorahPaymentMode == 'test'
              ? MyfatoorahRequest.test(
                  currencyIso: () {
                    if (context.read<CartProvider>().myfatoorahCountry ==
                        'Kuwait') {
                      return Country.Kuwait;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'UAE') {
                      return Country.UAE;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Egypt') {
                      return Country.Egypt;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Jordan') {
                      return Country.Jordan;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Oman') {
                      return Country.Oman;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  userDefinedField: orderID,
                  language: () {
                    if (context.read<CartProvider>().myfatoorahLanguage ==
                        'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                )
              : MyfatoorahRequest.live(
                  currencyIso: () {
                    if (context.read<CartProvider>().myfatoorahCountry ==
                        'Kuwait') {
                      return Country.Kuwait;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'UAE') {
                      return Country.UAE;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Egypt') {
                      return Country.Egypt;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Bahrain') {
                      return Country.Bahrain;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Jordan') {
                      return Country.Jordan;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'Oman') {
                      return Country.Oman;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.SaudiArabia;
                    } else if (context.read<CartProvider>().myfatoorahCountry ==
                        'SaudiArabia') {
                      return Country.Qatar;
                    }
                    return Country.SaudiArabia;
                  }(),
                  successUrl: successUrl,
                  userDefinedField: orderID,
                  errorUrl: errorUrl,
                  invoiceAmount: double.parse(amount),
                  language: () {
                    if (context.read<CartProvider>().myfatoorahLanguage ==
                        'english') {
                      return ApiLanguage.English;
                    }
                    return ApiLanguage.Arabic;
                  }(),
                  token: token,
                ),
        );
        context.read<CartProvider>().setProgress(false);
        if (response.status.toString() == 'PaymentStatus.Success') {
          context.read<CartProvider>().setProgress(true);

          await updateOrderStatus(orderID: orderId, status: PLACED);
          addTransaction(
            response.paymentId,
            orderID,
            PLACED,
            msg,
            true,
          );
        }
        if (response.status.toString() == 'PaymentStatus.None') {
          setSnackbar(response.status.toString(), _checkscaffoldKey);
          deleteOrder(orderId);
          //
        }
        if (response.status.toString() == 'PaymentStatus.Error') {
          setSnackbar(response.status.toString(), _checkscaffoldKey);
          deleteOrder(orderId);
        }
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  midTrasPayment(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        var parameter = {
          AMOUNT: context.read<CartProvider>().totalPrice.toString(),
          USER_ID: CUR_USERID,
          ORDER_ID: orderID
        };
        apiBaseHelper.postAPICall(createMidtransTransactionApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];
              String token = data['token'];
              String redirectUrl = data['redirect_url'];
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => MidTrashWebview(
                    url: redirectUrl,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) async {
                  isNetworkAvail = await isNetworkAvailable();
                  if (isNetworkAvail) {
                    try {
                      context.read<CartProvider>().setProgress(true);
                      var parameter = {
                        ORDER_ID: orderID,
                      };
                      apiBaseHelper
                          .postAPICall(
                              getMidtransTransactionStatusApi, parameter)
                          .then(
                        (getdata) async {
                          bool error = getdata['error'];
                          String? msg = getdata['message'];
                          var data = getdata['data'];
                          if (!error) {
                            String statuscode = data['status_code'];

                            if (statuscode == '404') {
                              deleteOrder(orderId);
                              if (mounted) {
                                context.read<CartProvider>().checkoutState!(
                                  () {
                                    _placeOrder = true;
                                  },
                                );
                              }
                              context.read<CartProvider>().setProgress(false);
                            }

                            if (statuscode == '200') {
                              String transactionStatus =
                                  data['transaction_status'];
                              String transactionId = data['transaction_id'];
                              if (transactionStatus == 'capture') {
                                Map<String, dynamic> result =
                                    await updateOrderStatus(
                                        orderID: orderId, status: PLACED);
                                if (!result['error']) {
                                  await addTransaction(
                                    transactionId,
                                    orderId,
                                    SUCCESS,
                                    rozorpayMsg,
                                    true,
                                  );
                                } else {
                                  setSnackbar('${result['message']}',
                                      _checkscaffoldKey);
                                }
                                if (mounted) {
                                  context
                                      .read<CartProvider>()
                                      .setProgress(false);
                                }
                              } else {
                                deleteOrder(orderId);
                                if (mounted) {
                                  context.read<CartProvider>().checkoutState!(
                                    () {
                                      _placeOrder = true;
                                    },
                                  );
                                }
                                context.read<CartProvider>().setProgress(false);
                              }
                            }
                          } else {
                            setSnackbar(msg!, _checkscaffoldKey);
                          }

                          context.read<CartProvider>().setProgress(false);
                        },
                        onError: (error) {
                          setSnackbar(error.toString(), _scaffoldKey);
                        },
                      );
                    } on TimeoutException catch (_) {
                      context.read<CartProvider>().setProgress(false);
                      setSnackbar(getTranslated(context, 'somethingMSg')!,
                          _checkscaffoldKey);
                    }
                  } else {
                    if (mounted) {
                      context.read<CartProvider>().checkoutState!(
                        () {
                          isNetworkAvail = false;
                        },
                      );
                    }
                  }
                  if (value == 'true') {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        _placeOrder = true;
                      },
                    );
                  } else {}
                },
              );
            } else {
              setSnackbar(msg!, _checkscaffoldKey);
            }
            context.read<CartProvider>().setProgress(false);
          },
          onError: (error) {
            setSnackbar(error.toString(), _scaffoldKey);
          },
        );
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  stripePayment(String? tranId, String orderID, String? status, String? msg,
      bool redirect) async {
    context.read<CartProvider>().setProgress(true);
    var response = await StripeService.payWithPaymentSheet(
        amount:
            (context.read<CartProvider>().totalPrice.toInt() * 100).toString(),
        currency: context.read<CartProvider>().stripeCurCode,
        from: 'order',
        context: context,
        awaitedOrderId: orderID);

    if (response.message == 'Transaction successful') {
      await updateOrderStatus(orderID: orderId, status: PLACED);
      addTransaction(context.read<CartProvider>().stripePayId, orderID,
          tranId == 'succeeded' ? PLACED : WAITING, msg, true);
    } else if (response.status == 'pending' || response.status == 'captured') {
      await updateOrderStatus(orderID: orderId, status: WAITING);
      addTransaction(
        context.read<CartProvider>().stripePayId,
        orderID,
        tranId == 'succeeded' ? PLACED : WAITING,
        msg,
        true,
      );
      if (mounted) {
        setState(
          () {
            _placeOrder = true;
          },
        );
      }
    } else {
      deleteOrder(orderID);
      if (mounted) {
        setState(
          () {
            _placeOrder = true;
          },
        );
      }

      context.read<CartProvider>().setProgress(false);
    }
    setSnackbar(response.message!, _checkscaffoldKey);
  }

  cartItems(List<SectionModel> cartList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return CartIteam(
          index: index,
          cartList: cartList,
          setState: setStateNow,
        );
      },
    );
  }

  Future<void> flutterwavePayment(
    String? tranId,
    String orderID,
    String? status,
    String? msg,
    bool redirect,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        var parameter = {
          AMOUNT: context.read<CartProvider>().totalPrice.toString(),
          USER_ID: CUR_USERID,
          ORDER_ID: orderID
        };
        apiBaseHelper.postAPICall(flutterwaveApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['link'];

              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (BuildContext context) => PaypalWebview(
                    url: data,
                    from: 'order',
                    orderId: orderID,
                  ),
                ),
              ).then(
                (value) {
                  if (value == 'true') {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        _placeOrder = true;
                      },
                    );
                  } else {
                    deleteOrder(orderID);
                  }
                },
              );
            } else {
              setSnackbar(msg!, _checkscaffoldKey);
            }

            context.read<CartProvider>().setProgress(false);
          },
          onError: (error) {
            setSnackbar(error.toString(), _scaffoldKey);
          },
        );
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        context.read<CartProvider>().checkoutState!(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  void confirmDialog() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: const GetContent(),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        _placeOrder = true;
                        context.read<CartProvider>().isPromoValid = false;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE')!,
                    style: const TextStyle(
                      color: colors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);
                    if (context.read<CartProvider>().payMethod ==
                        getTranslated(context, 'BANKTRAN')) {
                      bankTransfer();
                    } else {
                      placeOrder('');
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
    );
  }

  void bankTransfer() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: const GetBankTransferContent(),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    context.read<CartProvider>().checkoutState!(
                      () {
                        _placeOrder = true;
                      },
                    );
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'DONE')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);

                    context.read<CartProvider>().setProgress(true);

                    placeOrder('');
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
    );
  }

  Future<void> checkDeliverable() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: context.read<CartProvider>().selAddress,
        };

        apiBaseHelper.postAPICall(checkCartDelApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            var data = getdata['data'];
            context.read<CartProvider>().setProgress(false);

            if (error) {
              context.read<CartProvider>().deliverableList = (data as List)
                  .map((data) => Model.checkDeliverable(data))
                  .toList();

              context.read<CartProvider>().checkoutState!(
                () {
                  context.read<CartProvider>().deliverable = false;
                  _placeOrder = true;
                },
              );

              setSnackbar(msg!, _checkscaffoldKey);
            } else {
              context.read<CartProvider>().deliverableList = (data as List)
                  .map((data) => Model.checkDeliverable(data))
                  .toList();

              context.read<CartProvider>().checkoutState!(
                () {
                  context.read<CartProvider>().deliverable = true;
                },
              );
              confirmDialog();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), _scaffoldKey);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }
}
