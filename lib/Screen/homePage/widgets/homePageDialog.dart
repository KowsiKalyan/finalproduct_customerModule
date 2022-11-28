import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/UserProvider.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/security.dart';
import '../../../widgets/snackbar.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Language/languageSettings.dart';

class HomePageDialog {
  static showUnderMaintenanceDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
                ),
              ),
              title: Text(
                getTranslated(context, 'APP_MAINTENANCE')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  fontFamily: 'ubuntu',
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Lottie.asset(
                      DesignConfiguration.setLottiePath('app_maintenance'),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    MAINTENANCE_MESSAGE != ''
                        ? '$MAINTENANCE_MESSAGE'
                        : getTranslated(
                            context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      fontFamily: 'ubuntu',
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static clearYouCartDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    5.0,
                  ),
                ),
              ),
              title: Text(
                'You can add only One Seller Product In Cart At a Time.',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'ubuntu',
                  fontSize: 16,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SvgPicture.asset(
                        DesignConfiguration.setSvgPath('appbarCart'),
                        color: colors.primary,
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                          Routes.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Clear Cart',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                        onPressed: () {
                          if (CUR_USERID != null) {
                            context.read<UserProvider>().setCartCount('0');
                            context
                                .read<ProductDetailProvider>()
                                .clearCartNow()
                                .then(
                                  (value) {},
                                );
                            Future.delayed(const Duration(seconds: 1)).then(
                              (_) {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                    setSnackbar('Cart Clear successfully ...! ',
                                        context);
                                  } else {
                                    setSnackbar(
                                        context
                                            .read<ProductDetailProvider>()
                                            .snackbarmessage,
                                        context);
                                  }
                                } else {
                                  setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                      context);
                                }
                                Routes.pop(context);

                                offCartAdd() async {
                                  List cartOffList = await db.getOffCart();
                                  if (cartOffList.isNotEmpty) {
                                    for (int i = 0;
                                        i < cartOffList.length;
                                        i++) {
                                      try {
                                        var parameter = {
                                          PRODUCT_VARIENT_ID: cartOffList[i]
                                              ['VID'],
                                          USER_ID: CUR_USERID,
                                          QTY: cartOffList[i]['QTY'],
                                        };

                                        Response response = await post(
                                                manageCartApi,
                                                body: parameter,
                                                headers: headers)
                                            .timeout(const Duration(
                                                seconds: timeOut));
                                        if (response.statusCode == 200) {
                                          var getdata =
                                              json.decode(response.body);
                                        }
                                      } on TimeoutException catch (_) {
                                        setSnackbar(
                                            getTranslated(
                                                context, 'somethingMSg')!,
                                            context);
                                      }
                                    }
                                  }
                                  Future.delayed(const Duration(seconds: 1))
                                      .then((_) {
                                    db.clearCart();
                                  });
                                }
                              },
                            );
                          } else {
                            // context
                            //     .read<SettingProvider>()
                            //     .setCurrentSellerID('');
                            // CurrentSellerID = '';
                            // db.clearCart();
                            // context.read<UserProvider>().setCartCount('0');
                            // cartTotalClear();s
                            Routes.pop(context);
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static showAppUpdateDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            title: Text(getTranslated(context, 'UPDATE_APP')!),
            content: Text(
              getTranslated(context, 'UPDATE_AVAIL')!,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  getTranslated(context, 'NO')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text(
                  getTranslated(context, 'YES')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(false);

                  String url = '';
                  if (Platform.isAndroid) {
                    url = androidLink + packageName;
                  } else if (Platform.isIOS) {
                    url = iosLink;
                  }

                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }
}
