import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/authenticationProvider.dart';
import 'package:eshop_multivendor/Screen/NoInterNetWidget/NoInterNet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/validation.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = true;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode? nameFocus,
      emailFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);

    context
        .read<AuthenticationProvider>()
        .setMobileNumber(await settingsProvider.getPrefrence(MOBILE));
    context
        .read<AuthenticationProvider>()
        .setcountrycode(await settingsProvider.getPrefrence(COUNTRY_CODE));

    if (mounted) setState(() {});
  }

  setStateNow() {
    setState(() {});
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      Future.delayed(Duration.zero).then(
        (value) => context.read<AuthenticationProvider>().getSingUPData().then(
          (
            value,
          ) async {
            bool? error = value['error'];
            String? msg = value['message'];
            await buttonController!.reverse();
            SettingProvider settingsProvider =
                Provider.of<SettingProvider>(context, listen: false);
            if (!error!) {
              setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!);
              var i = value['data'][0];

              id = i[ID];
              name = i[USERNAME];
              email = i[EMAIL];
              mobile = i[MOBILE];
              CUR_USERID = id;

              UserProvider userProvider = context.read<UserProvider>();
              userProvider.setName(name ?? '');

              SettingProvider settingProvider = context.read<SettingProvider>();
              settingProvider.saveUserDetail(id!, name, email, mobile, city,
                  area, address, pincode, latitude, longitude, '', context);

              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
            } else {
              setSnackbar(
                msg!,
              );
            }
          },
        ),
      );
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
          await buttonController!.reverse();
        },
      );
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();

    buttonController!.dispose();
    super.dispose();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
          ),
        ),
        elevation: 1.0,
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
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
          if (mounted) setState(() {});
        }
      },
    );
  }

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 60.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'Create a new account')!,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: 23,
                fontFamily: 'ubuntu',
                letterSpacing: 0.8,
              ),
        ),
      ),
    );
  }

  signUpSubTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'INFO_FOR_NEW_ACCOUNT')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  setUserName() {
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
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 13),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          controller: nameController,
          focusNode: nameFocus,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'NAMEHINT_LBL'),
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => StringValidation.validateUserName(
              val!,
              getTranslated(context, 'USER_REQUIRED'),
              getTranslated(context, 'USER_LENGTH')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setUserName(value);
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, nameFocus!, emailFocus);
          },
        ),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
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
          keyboardType: TextInputType.emailAddress,
          focusNode: emailFocus,
          textInputAction: TextInputAction.next,
          controller: emailController,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 5,
              ),
              hintText: getTranslated(context, 'EMAILHINT_LBL'),
              hintStyle: TextStyle(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              fillColor: Theme.of(context).colorScheme.lightWhite,
              border: InputBorder.none),
          validator: (val) => StringValidation.validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL'),
          ),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setSingUp(value);
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(
              context,
              emailFocus!,
              passFocus,
            );
          },
        ),
      ),
    );
  }

  setRefer() {
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
          keyboardType: TextInputType.text,
          focusNode: referFocus,
          controller: referController,
          textInputAction: TextInputAction.done,
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setfriendCode(value);
          },
          onFieldSubmitted: (v) {
            referFocus!.unfocus();
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 5,
            ),
            hintText: getTranslated(context, 'REFER'),
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            fillColor: Theme.of(context).colorScheme.lightWhite,
            border: InputBorder.none,
          ),
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
          keyboardType: TextInputType.text,
          obscureText: _showPassword!,
          controller: passwordController,
          focusNode: passFocus,
          textInputAction: TextInputAction.next,
          validator: (val) => StringValidation.validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH')),
          onSaved: (String? value) {
            context.read<AuthenticationProvider>().setsinUpPassword(value);
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passFocus!, referFocus);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 5,
            ),
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  _showPassword = !_showPassword!;
                });
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: Icon(
                  !_showPassword! ? Icons.visibility : Icons.visibility_off,
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.4),
                  size: 22,
                ),
              ),
            ),
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

  verifyBtn() {
    return Center(
      child: AppBtn(
        title: getTranslated(context, 'SAVE_LBL'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        },
      ),
    );
  }

  loginTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            getTranslated(context, 'ALREADY_A_CUSTOMER')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () {
              Routes.navigateToLoginScreen(context);
            },
            child: Text(
              getTranslated(context, 'LOG_IN_LBL')!,
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

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: const EdgeInsetsDirectional.only(top: 20.0, start: 10.0),
            alignment: AlignmentDirectional.topStart,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: InkWell(
                  child: const Icon(Icons.keyboard_arrow_left,
                      color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          )
        : Container();
  }

  expandedBottomView() {
    return Expanded(
      flex: 8,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsetsDirectional.only(
                    start: 20.0, end: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    registerTxt(),
                    setUserName(),
                    setEmail(),
                    setPass(),
                    setRefer(),
                    verifyBtn(),
                    loginTxt(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithNoSpecification();

    super.initState();
    getUserDetails();
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

    context.read<AuthenticationProvider>().generateReferral(
          context,
          setStateNow,
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
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getLogo(),
                    registerTxt(),
                    signUpSubTxt(),
                    setUserName(),
                    setEmail(),
                    setPass(),
                    setRefer(),
                    verifyBtn(),
                    loginTxt(),
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

  Widget signUpTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 40.0,
      ),
      child: Text(
        getTranslated(context, 'Sign up')!,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: 23,
              letterSpacing: 0.8,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }
}
