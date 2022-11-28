import 'dart:async';
import 'dart:convert';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/SendOtp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/authenticationProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/validation.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;
  bool isShowPass = true;

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();

    super.initState();
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getLoginData().then(
          (
            value,
          ) async {
            bool error = value['error'];
            String? errorMessage = value['message'];
            await buttonController!.reverse();
            if (!error) {
              var getdata = value['data'][0];
              UserProvider userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.setName(getdata[USERNAME] ?? '');
              userProvider.setEmail(getdata[EMAIL] ?? '');
              userProvider.setProfilePic(getdata[IMAGE] ?? '');

              SettingProvider settingProvider =
                  Provider.of<SettingProvider>(context, listen: false);
              settingProvider.saveUserDetail(
                getdata[ID],
                getdata[USERNAME],
                getdata[EMAIL],
                getdata[MOBILE],
                getdata[CITY],
                getdata[AREA],
                getdata[ADDRESS],
                getdata[PINCODE],
                getdata[LATITUDE],
                getdata[LONGITUDE],
                getdata[IMAGE],
                context,
              );
              offFavAdd().then(
                (value) async {
                  db.clearFav();
                  context.read<FavoriteProvider>().setFavlist([]);
                  List cartOffList = await db.getOffCart();
                  if (singleSellerOrderSystem && cartOffList.isNotEmpty) {
                    forLoginPageSingleSellerSystem = true;
                    offSaveAdd().then(
                      (value) {
                        clearYouCartDialog();
                      },
                    );
                  } else {
                    offCartAdd().then(
                      (value) {
                        db.clearCart();
                        offSaveAdd().then(
                          (value) {
                            db.clearSaveForLater();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
                          },
                        );
                      },
                    );
                  }
                },
              );
            } else {
              setSnackbar(
                errorMessage!,
              );
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }

  clearYouCartDialog() async {
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
                'Your cart already has an items of another seller would you like to remove it ?',
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
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
                          db.clearSaveForLater();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (r) => false);
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
                              (value) async {
                                if (context
                                        .read<ProductDetailProvider>()
                                        .error ==
                                    false) {
                                  if (context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage ==
                                      'Data deleted successfully') {
                                    // setSnackbar(
                                    //   'Cart Clear successfully ...! ',
                                    // );
                                  } else {
                                    setSnackbar(
                                      context
                                          .read<ProductDetailProvider>()
                                          .snackbarmessage,
                                    );
                                  }
                                } else {
                                  setSnackbar(
                                    context
                                        .read<ProductDetailProvider>()
                                        .snackbarmessage,
                                  );
                                }
                                Routes.pop(context);
                                await offCartAdd();
                                db.clearSaveForLater();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (r) => false,
                                );
                              },
                            );
                          } else {
                            Routes.pop(context);
                            db.clearSaveForLater();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (r) => false,
                            );
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

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(
    String msg,
  ) {
    ScaffoldMessenger.of(this.context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        elevation: 1.0,
      ),
    );
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  Future<void> offFavAdd() async {
    List favOffList = await db.getOffFav();
    if (favOffList.isNotEmpty) {
      for (int i = 0; i < favOffList.length; i++) {
        _setFav(favOffList[i]['PID']);
      }
    }
  }

  _setFav(String pid) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: pid};
        Response response =
            await post(setFavoriteApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
          setSnackbar(
            msg!,
          );
        } else {
          setSnackbar(
            msg!,
          );
        }
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg')!,
        );
      }
    } else {
      if (mounted) {
        setState(() {
          isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> offCartAdd() async {
    print("we are here test 1");
    List cartOffList = await db.getOffCart();
    print("we are here test 2");
    print("cartOffList : ${cartOffList.length}");
    if (cartOffList.isNotEmpty) {
      for (int i = 0; i < cartOffList.length; i++) {
        print(
            "Current Calues : ${cartOffList[i]['VID']}  : ${cartOffList[i]['QTY']}");
        addToCartCheckout(cartOffList[i]['VID'], cartOffList[i]['QTY']);
      }
    }
  }

  Future<void> addToCartCheckout(String varId, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: varId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        print("response : ${response.body.toString()}");
        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          if (getdata['message'] == 'One of the product is out of stock.') {
            print("logint page api calle ");
            homePageSingleSellerMessage = true;
            print(
                "i am here , homePageSingleSellerMessage = $homePageSingleSellerMessage ");
            // setSnackbar(
            //   'One of the product is out of stock, We are not able To Add',
            // );
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg')!,
        );
      }
    } else {
      if (mounted) isNetworkAvail = false;

      setState(() {});
    }
  }

  Future<void> offSaveAdd() async {
    List saveOffList = await db.getOffSaveLater();

    if (saveOffList.isNotEmpty) {
      for (int i = 0; i < saveOffList.length; i++) {
        saveForLater(saveOffList[i]['VID'], saveOffList[i]['QTY']);
      }
    }
  }

  saveForLater(String vid, String qty) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          PRODUCT_VARIENT_ID: vid,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: '1'
        };

        Response response =
            await post(manageCartApi, body: parameter, headers: headers)
                .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata['error'];
        String? msg = getdata['message'];
        if (!error) {
        } else {
          setSnackbar(
            msg!,
          );
        }
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg')!,
        );
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

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  signInTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  signInSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'INFO_FOR_LOGIN')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(passFocus);
          },
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.number,
          controller: mobileController,
          focusNode: monoFocus,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(
                context,
                'MOBILEHINT_LBL',
              )!,
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => StringValidation.validateMob(
              val!,
              getTranslated(context, 'MOB_REQUIRED'),
              getTranslated(context, 'VALID_MOB')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setMobileNumber(value);
          },
        ),
      ),
    );
  }

  setPass() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        height: 53,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: TextFormField(
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          onFieldSubmitted: (v) {
            passFocus!.unfocus();
          },
          keyboardType: TextInputType.text,
          obscureText: isShowPass,
          controller: passwordController,
          focusNode: passFocus,
          textInputAction: TextInputAction.next,
          validator: (val) => StringValidation.validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setPassword(value);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 5,
            ),
            suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    isShowPass = !isShowPass;
                  });
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10.0),
                  child: Icon(
                    !isShowPass ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.4),
                    size: 22,
                  ),
                )),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, maxHeight: 20),
            hintText: getTranslated(context, 'PASSHINT_LBL')!,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                fontSize: 13),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  forgetPass() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => SendOtp(
                    title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'ubuntu',
                  ),
            ),
          ),
        ],
      ),
    );
  }

  setDontHaveAcc() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            getTranslated(context, 'DONT_HAVE_AN_ACC')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ),
              );
            },
            child: Text(
              getTranslated(context, 'SIGN_UP_LBL')!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
            ),
          )
        ],
      ),
    );
  }

  loginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Consumer<AuthenticationProvider>(
          builder: (context, value, child) {
            return AppBtn(
              title: getTranslated(context, 'SIGNIN_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                if (passFocus != null) {
                  passFocus!.unfocus();
                }
                if (monoFocus != null) {
                  monoFocus!.unfocus();
                }
                validateAndSubmit();
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: isNetworkAvail
          ? SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 23,
                left: 23,
                right: 23,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getLogo(),
                    signInTxt(),
                    signInSubTxt(),
                    setMobileNo(),
                    setPass(),
                    forgetPass(),
                    loginBtn(),
                    setDontHaveAcc(),
                  ],
                ),
              ),
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: SvgPicture.asset(
        DesignConfiguration.setSvgPath('homelogo'),
        alignment: Alignment.center,
        height: 90,
        width: 90,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: const TextStyle(
            color: colors.primary,
            fontSize: 30,
            fontFamily: 'ubuntu',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
