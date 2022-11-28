import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import '../Screen/Language/languageSettings.dart';

class CustomBottomSheet {
  static Future<dynamic> showBottomSheet(
      {required Widget child,
      required BuildContext context,
      bool? enableDrag}) async {
    final result = await showModalBottomSheet(
      enableDrag: enableDrag ?? false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      context: context,
      builder: (_) => child,
    );

    return result;
  }

  static Widget bottomSheetHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).colorScheme.lightBlack,
        ),
        height: 5,
        width: MediaQuery.of(context).size.width * 0.3,
      ),
    );
  }

  static Widget bottomSheetLabel(BuildContext context, String labelName) =>
      Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 20),
        child: Text(
          getTranslated(context, labelName)!,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.fontColor,
                fontFamily: 'ubuntu',
              ),
        ),
      );
}
