import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import '../../../Helper/String.dart';
import '../../../widgets/ButtonDesing.dart';
import '../../Product Detail/Widget/postFaq.dart';

class BorromBtnWidget extends StatelessWidget {
  String? id;
  Function update;
  BorromBtnWidget({Key? key, this.id, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CUR_USERID != '' && CUR_USERID != null
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  getTranslated(
                      context, 'Have doubts regarding this product?')!,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.fontColor,
                    fontFamily: 'ubuntu',
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 10, bottom: 5),
                  child: SimBtn(
                    onBtnSelected: () {
                      openPostQueBottomSheet(
                        context,
                        id,
                        update,
                      );
                    },
                    title: getTranslated(context, "POST YOUR QUESTION")!,
                    height: 38.5,
                    size: deviceWidth! * 0.5,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
