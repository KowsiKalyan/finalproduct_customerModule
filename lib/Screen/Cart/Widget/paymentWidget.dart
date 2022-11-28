import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider/CartProvider.dart';
import '../../Language/languageSettings.dart';
import '../../Payment/Payment.dart';

class SelectPayment extends StatelessWidget {
  Function updateCheckout;
  SelectPayment({Key? key, required this.updateCheckout}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      Payment(updateCheckout, '')));
          context.read<CartProvider>().checkoutState!(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.payment),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      getTranslated(context, 'SELECT_PAYMENT')!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  )
                ],
              ),
              context.read<CartProvider>().payMethod != null &&
                      context.read<CartProvider>().payMethod != ''
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(
                            context.read<CartProvider>().payMethod!,
                            style: const TextStyle(
                              fontFamily: 'ubuntu',
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
