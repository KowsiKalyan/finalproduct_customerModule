
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/validation.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Auth/SendOtp.dart';

class MyProfileDialog {
  static showLogoutDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            content: Text(
              getTranslated(context, 'LOGOUTTXT')!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  getTranslated(context, 'NO')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontWeight: FontWeight.bold),
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
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SettingProvider settingProvider =
                      Provider.of<SettingProvider>(context, listen: false);
                  settingProvider.clearUserSession(context);

                  context.read<FavoriteProvider>().setFavlist([]);

                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) => const Dashboard(),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }

  static showDeleteAccountDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, setState) {
      return DeleteAccountDialog();
    }));
  }

  static showDeleteWarningAccountDialog(BuildContext context) async {
    await DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'DeleteAccount')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  getTranslated(
                    context,
                    'DELETE_ACCOUNT_WARNING',
                  )!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(),
                )
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      getTranslated(context, 'NO')!,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold,
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
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onPressed: () {
                      Routes.pop(context);
                      MyProfileDialog.showDeleteAccountDialog(context);
                    },
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  DeleteAccountDialog({Key? key}) : super(key: key);

  final passwordController = TextEditingController();
  String? verifyPassword;
  FocusNode? passFocus = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated(context, 'Please Verify Password')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            height: 53,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightWhite,
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: Form(
              key: formKey,
              child: TextFormField(
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                onFieldSubmitted: (v) {
                  FocusScope.of(context).requestFocus(passFocus);
                },
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: passwordController,
                focusNode: passFocus,
                textInputAction: TextInputAction.next,
                onChanged: (String? value) {
                  verifyPassword = value;
                },
                onSaved: (String? value) {
                  verifyPassword = value;
                },
                validator: (val) => StringValidation.validatePass(
                    val!,
                    getTranslated(context, 'PWD_REQUIRED'),
                    getTranslated(context, 'PWD_LENGTH')),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 5,
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 40, maxHeight: 20),
                  hintText: getTranslated(context, 'PASSHINT_LBL')!,
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                  fillColor: Theme.of(context).colorScheme.lightWhite,
                  border: InputBorder.none,
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        Selector<UserProvider, String>(
          selector: (_, provider) => provider.mob,
          builder: (context, userMobile, child) {
            return TextButton(
              child: Text(
                getTranslated(context, 'DELETE_NOW')!,
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onPressed: () async {
                final form = formKey.currentState!;
                form.save();
                if (form.validate()) {
                  Routes.pop(context);
                  context
                      .read<UserProvider>()
                      .deleteUserAccount(
                          userId: CUR_USERID!,
                          mobileNumber: userMobile,
                          password: verifyPassword!)
                      .then(
                    (value) {
                      if (!value['error']) {
                        verifyPassword = '';
                        SettingProvider settingProvider =
                            Provider.of<SettingProvider>(context,
                                listen: false);
                        settingProvider.clearUserSession(context);

                        context.read<FavoriteProvider>().setFavlist([]);
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (BuildContext context) => SendOtp(
                              title: getTranslated(context, 'SEND_OTP_TITLE'),
                            ),
                          ),
                        );
                      } else {
                        verifyPassword = '';
                        setSnackbar(value['message'], context);
                      }
                    },
                  );
                }
              },
            );
          },
        )
      ],
    );
  }
}
