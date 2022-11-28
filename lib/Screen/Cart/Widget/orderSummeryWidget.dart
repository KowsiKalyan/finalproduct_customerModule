import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class OrderSummery extends StatelessWidget {
  List<SectionModel> cartList;
  OrderSummery({Key? key, required this.cartList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getTranslated(context, 'ORDER_SUMMARY')!} (${cartList.length} items)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'ubuntu',
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'SUBTOTAL')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.lightBlack2,
                    fontFamily: 'ubuntu',
                  ),
                ),
                Text(
                  '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().oriPrice)!} ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'DELIVERY_CHARGE')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.lightBlack2,
                    fontFamily: 'ubuntu',
                  ),
                ),
                Text(
                  '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().deliveryCharge)!} ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ubuntu',
                  ),
                )
              ],
            ),
            context.read<CartProvider>().isPromoValid!
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                      Text(
                        '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().promoAmt)!} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ubuntu',
                        ),
                      )
                    ],
                  )
                : Container(),
            context.read<CartProvider>().isUseWallet!
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, 'WALLET_BAL')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                      Text(
                        '${DesignConfiguration.getPriceFormat(context, context.read<CartProvider>().usedBalance)!} ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ubuntu',
                        ),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
