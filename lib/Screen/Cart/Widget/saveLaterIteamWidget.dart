import 'package:eshop_multivendor/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Provider/CartProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../Dashboard/Dashboard.dart';

class SaveLatterIteam extends StatefulWidget {
  int index;
  Function setState;
  Function cartFunc;
  SaveLatterIteam({
    Key? key,
    required this.index,
    required this.setState,
    required this.cartFunc,
  }) : super(key: key);

  @override
  State<SaveLatterIteam> createState() => _SaveLatterIteamState();
}

class _SaveLatterIteamState extends State<SaveLatterIteam> {
  @override
  Widget build(BuildContext context) {
    int index = widget.index;
    int selectedPos = 0;
    for (int i = 0;
        i <
            context
                .read<CartProvider>()
                .saveLaterList[index]
                .productList![0]
                .prVarientList!
                .length;
        i++) {
      if (context.read<CartProvider>().saveLaterList[index].varientId ==
          context
              .read<CartProvider>()
              .saveLaterList[index]
              .productList![0]
              .prVarientList![i]
              .id) {
        selectedPos = i;
      }
    }
    double price = double.parse(context
        .read<CartProvider>()
        .saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .disPrice!);
    if (price == 0) {
      price = double.parse(context
          .read<CartProvider>()
          .saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!);
    }
    double off = (double.parse(context
                .read<CartProvider>()
                .saveLaterList[index]
                .productList![0]
                .prVarientList![selectedPos]
                .price!) -
            double.parse(context
                .read<CartProvider>()
                .saveLaterList[index]
                .productList![0]
                .prVarientList![selectedPos]
                .disPrice!))
        .toDouble();
    off = off *
        100 /
        double.parse(context
            .read<CartProvider>()
            .saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .price!);
    context.read<CartProvider>().saveLaterList[index].perItemPrice =
        price.toString();
    if (context
            .read<CartProvider>()
            .saveLaterList[index]
            .productList![0]
            .availability !=
        '0') {
      context.read<CartProvider>().saveLaterList[index].perItemTotal = (price *
              double.parse(
                  context.read<CartProvider>().saveLaterList[index].qty!))
          .toString();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag:
                      '$cartHero$index${context.read<CartProvider>().saveLaterList[index].productList![0].id}',
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child: Stack(
                          children: [
                            DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: 100.0,
                              widthvalue: 100.0,
                              imageurlString: context
                                              .read<CartProvider>()
                                              .saveLaterList[index]
                                              .productList![0]
                                              .type ==
                                          'variable_product' &&
                                      context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .images!
                                          .isNotEmpty
                                  ? context
                                      .read<CartProvider>()
                                      .saveLaterList[index]
                                      .productList![0]
                                      .prVarientList![selectedPos]
                                      .images![0]
                                  : context
                                      .read<CartProvider>()
                                      .saveLaterList[index]
                                      .productList![0]
                                      .image!,
                              placeHolderSize: 100,
                            ),
                            Positioned.fill(
                              child: context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .productList![0]
                                          .availability ==
                                      '0'
                                  ? Container(
                                      height: 55,
                                      color: colors.white70,
                                      padding: const EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                              context, 'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'ubuntu',
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      off != 0 &&
                              context
                                      .read<CartProvider>()
                                      .saveLaterList[index]
                                      .productList![0]
                                      .prVarientList![selectedPos]
                                      .disPrice! !=
                                  '0'
                          ? GetDicountLabel(discount: off)
                          : Container()
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  context
                                      .read<CartProvider>()
                                      .saveLaterList[index]
                                      .productList![0]
                                      .name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontFamily: 'ubuntu',
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 8.0,
                                  end: 8,
                                  bottom: 8,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                ),
                              ),
                              onTap: () async {
                                if (context.read<CartProvider>().isProgress ==
                                    false) {
                                  if (CUR_USERID != null) {
                                    context.read<CartProvider>().removeFromCart(
                                          index: index,
                                          remove: true,
                                          cartList: context
                                              .read<CartProvider>()
                                              .saveLaterList,
                                          move: true,
                                          selPos: selectedPos,
                                          context: context,
                                          update: widget.setState,
                                          promoCode: context
                                              .read<CartProvider>()
                                              .promoC
                                              .text,
                                        );
                                  } else {
                                    db.removeSaveForLater(
                                        context
                                            .read<CartProvider>()
                                            .saveLaterList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .id!,
                                        context
                                            .read<CartProvider>()
                                            .saveLaterList[index]
                                            .productList![0]
                                            .id!);
                                    context
                                        .read<CartProvider>()
                                        .productIds
                                        .remove(context
                                            .read<CartProvider>()
                                            .saveLaterList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .id!);

                                    context
                                        .read<CartProvider>()
                                        .saveLaterList
                                        .removeAt(index);
                                    widget.setState();
                                  }
                                }
                              },
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              double.parse(context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .productList![0]
                                          .prVarientList![selectedPos]
                                          .disPrice!) !=
                                      0
                                  ? DesignConfiguration.getPriceFormat(
                                      context,
                                      double.parse(
                                        context
                                            .read<CartProvider>()
                                            .saveLaterList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .price!,
                                      ),
                                    )!
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .overline!
                                  .copyWith(
                                      fontFamily: 'ubuntu',
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: colors.darkColor3,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      decorationThickness: 2,
                                      letterSpacing: 0.7),
                            ),
                            Text(
                              ' ${DesignConfiguration.getPriceFormat(context, price)!} ',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ubuntu',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          context
                          .read<CartProvider>()
                          .saveLaterList[index]
                          .productList![0]
                          .availability ==
                      '1' ||
                  context
                          .read<CartProvider>()
                          .saveLaterList[index]
                          .productList![0]
                          .stockType ==
                      ''
              ? Positioned.directional(
                  textDirection: Directionality.of(context),
                  bottom: 12,
                  end: 5,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: InkWell(
                      onTap: !context.read<CartProvider>().addCart &&
                              !context.read<CartProvider>().isProgress
                          ? () {
                              if (CUR_USERID != null) {
                                context.read<CartProvider>().addCart = true;
                                widget.setState();
                                context.read<CartProvider>().saveForLater(
                                      update: widget.setState,
                                      fromSave: true,
                                      id: context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .varientId,
                                      price: double.parse(context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .perItemTotal!),
                                      context: context,
                                      qty: context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .qty,
                                      save: '0',
                                      curItem: context
                                          .read<CartProvider>()
                                          .saveLaterList[index],
                                      promoCode: context
                                          .read<CartProvider>()
                                          .promoC
                                          .text,
                                    );
                              } else {
                                () async {
                                  if (singleSellerOrderSystem) {
                                    if (CurrentSellerID == '' ||
                                        CurrentSellerID ==
                                            context
                                                .read<CartProvider>()
                                                .saveLaterList[index]
                                                .sellerId!) {
                                      CurrentSellerID = context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .sellerId!;
                                      context.read<CartProvider>().addCart =
                                          true;
                                      context
                                          .read<CartProvider>()
                                          .setProgress(true);
                                      widget.cartFunc(
                                        index: index,
                                        selectedPos: selectedPos,
                                        total: double.parse(context
                                            .read<CartProvider>()
                                            .saveLaterList[index]
                                            .perItemTotal!),
                                      );
                                    } else {
                                      setSnackbar(
                                          'only Single Seller Product Allow',
                                          context);
                                    }
                                  } else {
                                    context.read<CartProvider>().addCart = true;
                                    context
                                        .read<CartProvider>()
                                        .setProgress(true);
                                    widget.cartFunc(
                                      index: index,
                                      selectedPos: selectedPos,
                                      total: double.parse(context
                                          .read<CartProvider>()
                                          .saveLaterList[index]
                                          .perItemTotal!),
                                    );
                                  }
                                }();

                                widget.setState();
                              }
                            }
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
