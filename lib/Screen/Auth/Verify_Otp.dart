import 'dart:async';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Screen/Auth/Set_Password.dart';
import 'package:eshop_multivendor/Screen/Auth/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../Helper/String.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;

  const VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title})
      : super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = '';
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();
    Future.delayed(const Duration(seconds: 60)).then(
      (_) {
        _isClickable = true;
      },
    );
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

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    if (mounted) setState(() {});
  }

  Future<void> checkNetworkOtp() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(getTranslated(context, 'OTPWR')!);
      }
    } else {
      if (mounted) setState(() {});

      Future.delayed(const Duration(seconds: 60)).then(
        (_) async {
          isNetworkAvail = await isNetworkAvailable();
          if (isNetworkAvail) {
            if (_isClickable) {
              _onVerifyCode();
            } else {
              setSnackbar(getTranslated(context, 'OTPWR')!);
            }
          } else {
            await buttonController!.reverse();
            setSnackbar(getTranslated(context, 'somethingMSg')!);
          }
        },
      );
    }
  }

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
          title: getTranslated(context, 'VERIFY_AND_PROCEED'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            _onFormSubmitted();
          },
        ),
      ),
    );
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
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        elevation: 1.0,
      ),
    );
  }

  void _onVerifyCode() async {
    if (mounted) {
      setState(
        () {
          isCodeSent = true;
        },
      );
    }
    PhoneVerificationCompleted verificationCompleted() {
      return (AuthCredential phoneAuthCredential) {
        _firebaseAuth.signInWithCredential(phoneAuthCredential).then(
          (UserCredential value) {
            if (value.user != null) {
              SettingProvider settingsProvider =
                  Provider.of<SettingProvider>(context, listen: false);

              setSnackbar(getTranslated(context, 'OTPMSG')!);
              settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
              settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
              if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then((_) {
                  Navigator.pushReplacement(context,
                      CupertinoPageRoute(builder: (context) => const SignUp()));
                });
              } else if (widget.title ==
                  getTranslated(context, 'FORGOT_PASS_TITLE')) {
                Future.delayed(const Duration(seconds: 2)).then(
                  (_) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SetPass(
                          mobileNumber: widget.mobileNumber!,
                        ),
                      ),
                    );
                  },
                );
              }
            } else {
              setSnackbar(getTranslated(context, 'OTPERROR')!);
            }
          },
        ).catchError(
          (error) {
            setSnackbar(error.toString());
          },
        );
      };
    }

    PhoneVerificationFailed verificationFailed() {
      return (FirebaseAuthException authException) {
        if (mounted) {
          setState(
            () {
              isCodeSent = false;
            },
          );
        }
      };
    }

    PhoneCodeSent codeSent() {
      return (String verificationId, [int? forceResendingToken]) async {
        _verificationId = verificationId;
        if (mounted) {
          setState(
            () {
              _verificationId = verificationId;
            },
          );
        }
      };
    }

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout() {
      return (String verificationId) {
        _verificationId = verificationId;
        if (mounted) {
          setState(
            () {
              _isClickable = true;
              _verificationId = verificationId;
            },
          );
        }
      };
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+${widget.countryCode}${widget.mobileNumber}',
      timeout: const Duration(seconds: 60),
      verificationCompleted: verificationCompleted(),
      verificationFailed: verificationFailed(),
      codeSent: codeSent(),
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout(),
    );
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          SettingProvider settingsProvider =
              Provider.of<SettingProvider>(context, listen: false);

          await buttonController!.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG')!);
          settingsProvider.setPrefrence(MOBILE, widget.mobileNumber!);
          settingsProvider.setPrefrence(COUNTRY_CODE, widget.countryCode!);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(context,
                  CupertinoPageRoute(builder: (context) => const SignUp()));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(const Duration(seconds: 2)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SetPass(
                      mobileNumber: widget.mobileNumber!,
                    ),
                  ),
                );
              },
            );
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR')!);
          await buttonController!.reverse();
        }
      }).catchError((error) async {
        setSnackbar(getTranslated(context, 'WRONGOTP')!);

        await buttonController!.reverse();
      });
    } else {
      setSnackbar(getTranslated(context, 'ENTEROTP')!);
    }
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  monoVarifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 60.0,
      ),
      child: Text(
        getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
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

  otpText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 13.0,
      ),
      child: Text(
        getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0),
      child: Text(
        '+${widget.countryCode}-${widget.mobileNumber}',
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontFamily: 'ubuntu',
            ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30),
      child: PinFieldAutoFill(
        decoration: BoxLooseDecoration(
            textStyle: TextStyle(
                fontSize: 20, color: Theme.of(context).colorScheme.fontColor),
            radius: const Radius.circular(4.0),
            gapSpace: 15,
            bgColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.lightWhite.withOpacity(0.4)),
            strokeColorBuilder: FixedColorBuilder(
                Theme.of(context).colorScheme.fontColor.withOpacity(0.2))),
        currentCode: otp,
        codeLength: 6,
        onCodeChanged: (String? code) {
          otp = code;
        },
        onCodeSubmitted: (String code) {
          otp = code;
        },
      ),
    );
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30.0),
      child: Row(
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE')!,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'ubuntu',
                ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, 'RESEND_OTP')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
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

  expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: SingleChildScrollView(
            child: Card(
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  monoVarifyText(),
                  otpText(),
                  mobText(),
                  otpLayout(),
                  verifyBtn(),
                  resendText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              top: 23,
              left: 23,
              right: 23,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLogo(),
              monoVarifyText(),
              otpText(),
              mobText(),
              otpLayout(),
              resendText(),
              verifyBtn(),
            ],
          ),
        ),
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
}
