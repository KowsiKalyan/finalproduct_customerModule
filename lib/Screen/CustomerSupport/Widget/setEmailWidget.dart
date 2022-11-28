import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/customerSupportProvider.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/validation.dart';

class SetEmailWidget extends StatefulWidget {
  const SetEmailWidget({Key? key}) : super(key: key);

  @override
  State<SetEmailWidget> createState() => _SetEmailWidgetState();
}

class _SetEmailWidgetState extends State<SetEmailWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 10.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: context.read<CustomerSupportProvider>().emailFocus,
        textInputAction: TextInputAction.next,
        controller: context.read<CustomerSupportProvider>().emailController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        validator: (val) => StringValidation.validateEmail(
          val!,
          getTranslated(context, 'EMAIL_REQUIRED'),
          getTranslated(context, 'VALID_EMAIL'),
        ),
        onSaved: (String? value) {
          context.read<CustomerSupportProvider>().email = value;
        },
        onFieldSubmitted: (v) {
          context.read<CustomerSupportProvider>().emailFocus!.unfocus();
          FocusScope.of(context)
              .requestFocus(context.read<CustomerSupportProvider>().nameFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'EMAILHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
