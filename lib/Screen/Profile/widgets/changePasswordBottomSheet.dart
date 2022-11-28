import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../Auth/SendOtp.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  ChangePasswordBottomSheet({Key? key}) : super(key: key);

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final GlobalKey<FormState> _changePwdKey = GlobalKey<FormState>();

  final confirmPasswordTextController = TextEditingController();

  final newPasswordTextController = TextEditingController();

  final passwordController = TextEditingController();

  String? currentPwd, newPwd, confirmPwd;

  FocusNode confirmPwdFocus = FocusNode();
  bool onlyOneTimeTap = true;
  Future<bool> validateAndSave(
      GlobalKey<FormState> key, BuildContext context) async {
    final form = key.currentState!;
    form.save();
    if (form.validate()) {
      if (onlyOneTimeTap) {
        onlyOneTimeTap = false;
        await context
            .read<UserProvider>()
            .updateUserProfile(
              userID: CUR_USERID!,
              newPassword: newPasswordTextController.text,
              oldPassword: passwordController.text,
              username: '',
              userEmail: '',
            )
            .then(
          (value) {
            if (value['error'] == false) {
              setSnackbar(
                  getTranslated(context, 'PASS_CHANGED_SUCCESS')!, context);
            } else {
              setSnackbar(value['message'], context);
            }
          },
        );
        passwordController.clear();
        newPasswordTextController.clear();
        confirmPasswordTextController.clear();

        Routes.pop(context);
      }
      return true;
    }
    return false;
  }

  Widget setCurrentPasswordField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            obscuringCharacter: '*',
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
            ),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'CUR_PASS_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                border: InputBorder.none),
            onSaved: (String? value) {
              currentPwd = value;
            },
            validator: (val) => StringValidation.validatePass(
              val!,
              getTranslated(context, 'PWD_REQUIRED'),
              getTranslated(context, 'PWD_LENGTH'),
            ),
          ),
        ),
      ),
    );
  }

  Widget setForgotPasswordLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => SendOtp(
                  title: getTranslated(context, 'FORGOT_PASS_TITLE'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget newPwdField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: newPasswordTextController,
            obscureText: true,
            obscuringCharacter: '*',
            style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
            ),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'NEW_PASS_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                border: InputBorder.none),
            onSaved: (String? value) {
              newPwd = value;
            },
            validator: (val) => StringValidation.validatePass(
                val!,
                getTranslated(context, 'PWD_REQUIRED'),
                getTranslated(context, 'PWD_LENGTH')),
          ),
        ),
      ),
    );
  }

  Widget confirmPwdField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: confirmPasswordTextController,
            focusNode: confirmPwdFocus,
            obscureText: true,
            obscuringCharacter: '*',
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'CONFIRMPASSHINT_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                border: InputBorder.none),
            validator: (value) {
              if (value!.isEmpty) {
                return getTranslated(context, 'CON_PASS_REQUIRED_MSG');
              }
              if (value != newPwd) {
                confirmPasswordTextController.text = '';
                confirmPwdFocus.requestFocus();
                return getTranslated(context, 'CON_PASS_NOT_MATCH_MSG');
              } else {
                return null;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget saveButton(
      BuildContext context, String title, VoidCallback? onBtnSelected) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: InkWell(
              onTap: onBtnSelected,
              child: Container(
                height: 45.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.grad1Color, colors.grad2Color],
                    stops: [0, 1],
                  ),
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: textFontSize16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Form(
                key: _changePwdKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomBottomSheet.bottomSheetHandle(context),
                    CustomBottomSheet.bottomSheetLabel(
                        context, 'CHANGE_PASS_LBL'),
                    setCurrentPasswordField(context),
                    setForgotPasswordLabel(context),
                    newPwdField(context),
                    confirmPwdField(context),
                    saveButton(
                      context,
                      getTranslated(context, 'SAVE_LBL')!,
                      () {
                        validateAndSave(_changePwdKey, context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Selector<UserProvider, UserStatus>(
              builder: (context, status, child) {
                if (status == UserStatus.inProgress) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container();
              },
              selector: (_, provider) => provider.userStatus,
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    newPasswordTextController.dispose();
    confirmPasswordTextController.dispose();
    confirmPwdFocus.dispose();
    super.dispose();
  }
}
