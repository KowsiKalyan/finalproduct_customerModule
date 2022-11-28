import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import '../../../Model/Transaction_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/validation.dart';

class WalletTransactionItem extends StatelessWidget {
  TransactionModel transactionData;
  WalletTransactionItem({Key? key, required this.transactionData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color back;
    if (transactionData.type == 'credit') {
      back = Colors.green;
    } else {
      back = Colors.red;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
              width: 0.5,
              color: Theme.of(context).disabledColor,
              style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${getTranslated(context, 'AMOUNT')!} : ${DesignConfiguration.getPriceFormat(context, double.parse(transactionData.amt!))!}',
                    style: TextStyle(
                      fontFamily: 'ubuntu',
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  transactionData.date!,
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
              ],
            ),
            const Divider(thickness: 0.5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${getTranslated(context, 'ID_LBL')!} : ${transactionData.id!}',
                  style: const TextStyle(
                    fontFamily: 'ubuntu',
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: back,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        4.0,
                      ),
                    ),
                  ),
                  child: Text(
                    StringValidation.capitalize(transactionData.type!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                )
              ],
            ),
            transactionData.msg != null && transactionData.msg!.isNotEmpty
                ? Text(
                    '${getTranslated(context, 'MSG')!} : ${transactionData.msg!}',
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
