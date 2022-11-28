import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/CartProvider.dart';
import '../../Provider/paymentProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/snackbar.dart';
import 'Widget/PaymentRadio.dart';
import '../../widgets/appBar.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class Payment extends StatefulWidget {
  final Function update;
  final String? msg;

  const Payment(this.update, this.msg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePayment();
  }
}

class StatePayment extends State<Payment> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  setStateNow() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<PaymentProvider>().getdateTime(context, setStateNow);
    context.read<PaymentProvider>().timeSlotList.length = 0;
    context.read<PaymentProvider>().timeModel.clear();
    Future.delayed(
      Duration.zero,
      () {
        context.read<PaymentProvider>().paymentMethodList = [
          Platform.isIOS
              ? getTranslated(context, 'APPLEPAY')
              : getTranslated(context, 'GPAY'),
          getTranslated(context, 'COD_LBL'),
          getTranslated(context, 'PAYPAL_LBL'),
          getTranslated(context, 'PAYUMONEY_LBL'),
          getTranslated(context, 'RAZORPAY_LBL'),
          getTranslated(context, 'PAYSTACK_LBL'),
          getTranslated(context, 'FLUTTERWAVE_LBL'),
          getTranslated(context, 'STRIPE_LBL'),
          getTranslated(context, 'PAYTM_LBL'),
          getTranslated(context, 'BANKTRAN'),
          getTranslated(context, 'MidTrans')!,
          'My Fatoorah',
        ];
      },
    );
    if (widget.msg != '') {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setSnackbar(
          widget.msg!,
          context,
        ),
      );
    }
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

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          context.read<PaymentProvider>().getdateTime(
                context,
                setStateNow,
              );
        } else {
          await buttonController!.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(
          getTranslated(context, 'PAYMENT_METHOD_LBL')!, context),
      body: isNetworkAvail
          ? context.read<PaymentProvider>().isLoading
              ? DesignConfiguration.getProgress()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, _) {
                                  return Card(
                                    elevation: 0,
                                    child: userProvider.curBalance != '0' &&
                                            userProvider
                                                .curBalance.isNotEmpty &&
                                            userProvider.curBalance != ''
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: CheckboxListTile(
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(0),
                                              value: context
                                                  .read<CartProvider>()
                                                  .isUseWallet,
                                              onChanged: (bool? value) {
                                                if (mounted) {
                                                  setState(
                                                    () {
                                                      context
                                                          .read<CartProvider>()
                                                          .isUseWallet = value;
                                                      if (value!) {
                                                        if (context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice <=
                                                            double.parse(
                                                                userProvider
                                                                    .curBalance)) {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .remWalBal = (double
                                                                  .parse(userProvider
                                                                      .curBalance) -
                                                              context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice);
                                                          context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance =
                                                              context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .totalPrice;
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .payMethod = 'Wallet';

                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .isPayLayShow = false;
                                                        } else {
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .remWalBal = 0;
                                                          context
                                                                  .read<
                                                                      CartProvider>()
                                                                  .usedBalance =
                                                              double.parse(
                                                                  userProvider
                                                                      .curBalance);
                                                          context
                                                              .read<
                                                                  CartProvider>()
                                                              .isPayLayShow = true;
                                                        }

                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .totalPrice = context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice -
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .usedBalance;
                                                      } else {
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .totalPrice = context
                                                                .read<
                                                                    CartProvider>()
                                                                .totalPrice +
                                                            context
                                                                .read<
                                                                    CartProvider>()
                                                                .usedBalance;
                                                        context
                                                                .read<
                                                                    CartProvider>()
                                                                .remWalBal =
                                                            double.parse(
                                                                userProvider
                                                                    .curBalance);
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .payMethod = null;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .selectedMethod = null;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .usedBalance = 0;
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .isPayLayShow = true;
                                                      }

                                                      widget.update();
                                                    },
                                                  );
                                                }
                                              },
                                              title: Text(
                                                getTranslated(
                                                    context, 'USE_WALLET')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1,
                                              ),
                                              subtitle: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: Text(
                                                  context
                                                          .read<CartProvider>()
                                                          .isUseWallet!
                                                      ? '${getTranslated(context, 'REMAIN_BAL')!} : ${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().remWalBal)}'
                                                      : '${getTranslated(context, 'TOTAL_BAL')!} : ${DesignConfiguration.getPriceFormat(context, double.parse(userProvider.curBalance))!}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  );
                                },
                              ),
                              context.read<CartProvider>().isTimeSlot!
                                  ? Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'PREFERED_TIME')!,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: textFontSize16,
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          Container(
                                            height: 90,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: int.parse(context
                                                  .read<PaymentProvider>()
                                                  .allowDay!),
                                              itemBuilder: (context, index) {
                                                return dateCell(index);
                                              },
                                            ),
                                          ),
                                          const Divider(),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: context
                                                .read<PaymentProvider>()
                                                .timeModel
                                                .length,
                                            itemBuilder: (context, index) {
                                              return timeSlotItem(index);
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              context.read<CartProvider>().isPayLayShow!
                                  ? Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              getTranslated(
                                                  context, 'SELECT_PAYMENT')!,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: textFontSize16,
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: context
                                                .read<PaymentProvider>()
                                                .paymentMethodList
                                                .length,
                                            itemBuilder: (context, index) {
                                              if (index == 1 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .cod) {
                                                return paymentItem(index);
                                              } else if (index == 2 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paypal) {
                                                return paymentItem(index);
                                              } else if (index == 3 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paumoney) {
                                                return paymentItem(index);
                                              } else if (index == 4 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .razorpay) {
                                                return paymentItem(index);
                                              } else if (index == 5 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paystack) {
                                                return paymentItem(index);
                                              } else if (index == 6 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .flutterwave) {
                                                return paymentItem(index);
                                              } else if (index == 7 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .stripe) {
                                                return paymentItem(index);
                                              } else if (index == 8 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .paytm) {
                                                return paymentItem(index);
                                              } else if (index == 0 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .gpay) {
                                                return paymentItem(index);
                                              } else if (index == 9 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .bankTransfer) {
                                                return paymentItem(index);
                                              } else if (index == 10 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .midtrans) {
                                                return paymentItem(index);
                                              } else if (index == 11 &&
                                                  context
                                                      .read<PaymentProvider>()
                                                      .myfatoorah) {
                                                return paymentItem(index);
                                              } else {
                                                return Container();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                      SimBtn(
                        borderRadius: circularBorderRadius5,
                        size: 0.8,
                        title: getTranslated(context, 'DONE'),
                        onBtnSelected: () {
                          Routes.pop(context);
                        },
                      ),
                    ],
                  ),
                )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  dateCell(int index) {
    DateTime today =
        DateTime.parse(context.read<PaymentProvider>().startingDate!);
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: context.read<CartProvider>().selectedDate == index
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.grad1Color, colors.grad2Color],
                  stops: [0, 1],
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                DateFormat('dd').format(
                  today.add(
                    Duration(days: index),
                  ),
                ),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.read<CartProvider>().selectedDate == index
                      ? Theme.of(context).colorScheme.white
                      : Theme.of(context).colorScheme.lightBlack2,
                ),
              ),
            ),
            Text(
              DateFormat('MMM').format(
                today.add(
                  Duration(
                    days: index,
                  ),
                ),
              ),
              style: TextStyle(
                color: context.read<CartProvider>().selectedDate == index
                    ? Theme.of(context).colorScheme.white
                    : Theme.of(context).colorScheme.lightBlack2,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        DateTime date = today.add(Duration(days: index));

        if (mounted) context.read<CartProvider>().selectedDate = index;
        context.read<CartProvider>().selectedTime = null;
        context.read<CartProvider>().selTime = null;
        context.read<CartProvider>().selDate =
            DateFormat('yyyy-MM-dd').format(date);
        context.read<PaymentProvider>().timeModel.clear();
        DateTime cur = DateTime.now();
        DateTime tdDate = DateTime(cur.year, cur.month, cur.day);
        if (date == tdDate) {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              DateTime cur = DateTime.now();
              String time =
                  context.read<PaymentProvider>().timeSlotList[i].lastTime!;
              DateTime last = DateTime(
                cur.year,
                cur.month,
                cur.day,
                int.parse(time.split(':')[0]),
                int.parse(time.split(':')[1]),
                int.parse(time.split(':')[2]),
              );

              if (cur.isBefore(last)) {
                context.read<PaymentProvider>().timeModel.add(
                      RadioModel(
                        isSelected:
                            i == context.read<CartProvider>().selectedTime
                                ? true
                                : false,
                        name: context
                            .read<PaymentProvider>()
                            .timeSlotList[i]
                            .name,
                        img: '',
                      ),
                    );
              }
            }
          }
        } else {
          if (context.read<PaymentProvider>().timeSlotList.isNotEmpty) {
            for (int i = 0;
                i < context.read<PaymentProvider>().timeSlotList.length;
                i++) {
              context.read<PaymentProvider>().timeModel.add(
                    RadioModel(
                      isSelected: i == context.read<CartProvider>().selectedTime
                          ? true
                          : false,
                      name:
                          context.read<PaymentProvider>().timeSlotList[i].name,
                      img: '',
                    ),
                  );
            }
          }
        }
        setState(() {});
      },
    );
  }

  Widget timeSlotItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              context.read<CartProvider>().selectedTime = index;
              context.read<CartProvider>().selTime = context
                  .read<PaymentProvider>()
                  .timeModel[context.read<CartProvider>().selectedTime!]
                  .name;
              for (var element in context.read<PaymentProvider>().timeModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().timeModel[index].isSelected =
                  true;
            },
          );
        }
      },
      child: RadioItem(context.read<PaymentProvider>().timeModel[index]),
    );
  }

  Widget paymentItem(int index) {
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(
            () {
              context.read<CartProvider>().selectedMethod = index;
              context.read<CartProvider>().payMethod =
                  context.read<PaymentProvider>().paymentMethodList[
                      context.read<CartProvider>().selectedMethod!];

              for (var element in context.read<PaymentProvider>().payModel) {
                element.isSelected = false;
              }
              context.read<PaymentProvider>().payModel[index].isSelected = true;
            },
          );
        }
      },
      child: RadioItem(
        context.read<PaymentProvider>().payModel[index],
      ),
    );
  }
}
