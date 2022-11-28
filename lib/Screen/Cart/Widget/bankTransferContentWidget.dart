import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/paymentProvider.dart';
import '../../Language/languageSettings.dart';

class GetBankTransferContent extends StatelessWidget {
  const GetBankTransferContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
          child: Text(
            getTranslated(context, 'BANKTRAN')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.lightBlack),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20.0,
            0,
            20.0,
            0,
          ),
          child: Text(getTranslated(context, 'BANK_INS')!,
              style: Theme.of(context).textTheme.caption),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            getTranslated(context, 'ACC_DETAIL')!,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'ACCNAME')!} : ${context.read<PaymentProvider>().acName!}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'ACCNO')!} : ${context.read<PaymentProvider>().acNo!}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'BANKNAME')!} : ${context.read<PaymentProvider>().bankName!}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'BANKCODE')!} : ${context.read<PaymentProvider>().bankNo!}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Text(
            '${getTranslated(context, 'EXTRADETAIL')!} : ${context.read<PaymentProvider>().exDetails!}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontFamily: 'ubuntu',
                ),
          ),
        )
      ],
    );
  }
}
