import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../SQLiteData/SqliteData.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/Favourite/UpdateFavProvider.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Product Detail/productDetail.dart';

class FavProductData extends StatefulWidget {
  int? index;
  List<Product> favList = [];
  Function updateNow;

  FavProductData({
    Key? key,
    required this.index,
    required this.updateNow,
    required this.favList,
  }) : super(key: key);

  @override
  State<FavProductData> createState() => _FavProductDataState();
}

class _FavProductDataState extends State<FavProductData> {
  var db = DatabaseHelper();

  removeFromCart(
    int index,
    List<Product> favList,
    BuildContext context,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted) {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
          // setState(() {});
        }
        int qty;
        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID:
              favList[index].prVarientList![favList[index].selVarient!].id,
          USER_ID: CUR_USERID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              favList[index]
                  .prVarientList![favList[index].selVarient!]
                  .cartCount = qty.toString();

              var cart = getdata['cart'];
              List<SectionModel> cartList = (cart as List)
                  .map((cart) => SectionModel.fromCart(cart))
                  .toList();
              context.read<CartProvider>().setCartlist(cartList);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              context
                  .read<UpdateFavProvider>()
                  .changeStatus(UpdateFavStatus.isSuccsess);
              widget.updateNow();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.isSuccsess);
            widget.updateNow();
          },
        );
      } else {
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.inProgress);
        // setState(() {

        // });

        int qty;

        qty = (int.parse(
                context.read<FavoriteProvider>().controllerText[index].text) -
            int.parse(favList[index].qtyStepSize!));

        if (qty < favList[index].minOrderQuntity!) {
          qty = 0;

          db.removeCart(
              favList[index].prVarientList![favList[index].selVarient!].id!,
              favList[index].id!,
              context);
        } else {
          db.updateCart(
            favList[index].id!,
            favList[index].prVarientList![favList[index].selVarient!].id!,
            qty.toString(),
          );
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.updateNow();
      }
    }
  }

  Future<void> addToCart(
    String qty,
    int from,
    List<Product> favList,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.inProgress);
            // setState(() {});
          }

          String qty =
              (int.parse(favList[widget.index!].prVarientList![0].cartCount!) +
                      int.parse(favList[widget.index!].qtyStepSize!))
                  .toString();

          if (int.parse(qty) < favList[widget.index!].minOrderQuntity!) {
            qty = favList[widget.index!].minOrderQuntity.toString();
            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            PRODUCT_VARIENT_ID: favList[widget.index!]
                .prVarientList![favList[widget.index!].selVarient!]
                .id,
            USER_ID: CUR_USERID,
            QTY: qty,
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];
                context.read<UserProvider>().setCartCount(data['cart_count']);

                favList[widget.index!]
                    .prVarientList![favList[widget.index!].selVarient!]
                    .cartCount = qty.toString();

                favList[widget.index!].prVarientList![0].cartCount =
                    qty.toString();
                context
                    .read<FavoriteProvider>()
                    .controllerText[widget.index!]
                    .text = qty.toString();
                var cart = getdata['cart'];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }

              if (mounted) {
                context
                    .read<UpdateFavProvider>()
                    .changeStatus(UpdateFavStatus.isSuccsess);
                // widget.updateNow();
              }
              // widget.updateNow();
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
              // widget.updateNow();
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          context.read<FavoriteProvider>().changeStatus(FavStatus.isSuccsess);
          widget.updateNow();
        }
      } else {
        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.favList[widget.index!].seller_id!) {
            CurrentSellerID = widget.favList[widget.index!].seller_id!;

            context
                .read<UpdateFavProvider>()
                .changeStatus(UpdateFavStatus.inProgress);
            // widget.updateNow();

            if (from == 1) {
              db.insertCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
                context,
              );
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              widget.updateNow();
              setSnackbar(getTranslated(context, 'Product Added Successfully')!,
                  context);
            } else {
              if (int.parse(qty) >
                  widget.favList[widget.index!].itemsCounter!.length) {
                setSnackbar(
                    '${getTranslated(context, "Max Quantity is")!}-${int.parse(qty) - 1}',
                    context);
              } else {
                db.updateCart(
                  widget.favList[widget.index!].id!,
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .id!,
                  qty,
                );
              }
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = qty.toString();
              setSnackbar(
                  getTranslated(context, 'Cart Update Successfully')!, context);
            }
          } else {
            setSnackbar('only Single Seller Product Allow', context);
          }
        } else {
          context
              .read<UpdateFavProvider>()
              .changeStatus(UpdateFavStatus.inProgress);
          // widget.updateNow();

          if (from == 1) {
            db.insertCart(
              widget.favList[widget.index!].id!,
              widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .id!,
              qty,
              context,
            );
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            widget.updateNow();
            setSnackbar(
                getTranslated(context, 'Product Added Successfully')!, context);
          } else {
            if (int.parse(qty) >
                widget.favList[widget.index!].itemsCounter!.length) {
              setSnackbar(
                  '${getTranslated(context, "Max Quantity is")!}-${int.parse(qty) - 1}',
                  context);
            } else {
              db.updateCart(
                widget.favList[widget.index!].id!,
                widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .id!,
                qty,
              );
            }
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = qty.toString();
            setSnackbar(
                getTranslated(context, 'Cart Update Successfully')!, context);
          }
        }
        context
            .read<UpdateFavProvider>()
            .changeStatus(UpdateFavStatus.isSuccsess);
        widget.updateNow();
      }
    } else {
      isNetworkAvail = false;

      widget.updateNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.favList.length && widget.favList.isNotEmpty) {
      if (context.read<FavoriteProvider>().controllerText.length <
          widget.index! + 1) {
        context
            .read<FavoriteProvider>()
            .controllerText
            .add(TextEditingController());
      }

      // return FutureBuilder(
      // future: db.checkCartItemExists(
      //     widget.favList[widget.index!].id!,
      //     widget.favList[widget.index!]
      //         .prVarientList![widget.favList[widget.index!].selVarient!].id!),
      // builder: (BuildContext context, AsyncSnapshot snapshot) {
      //   if (snapshot.hasData) {
      // double price = double.parse(widget
      //     .favList[widget.index!]
      //     .prVarientList![widget.favList[widget.index!].selVarient!]
      //     .disPrice!);
      // if (price == 0) {
      //   price = double.parse(widget
      //       .favList[widget.index!]
      //       .prVarientList![widget.favList[widget.index!].selVarient!]
      //       .price!);
      // }
      // double off = 0;
      // if (widget
      //         .favList[widget.index!]
      //         .prVarientList![widget.favList[widget.index!].selVarient!]
      //         .disPrice !=
      //     '0') {
      //   off = (double.parse(widget
      //               .favList[widget.index!]
      //               .prVarientList![
      //                   widget.favList[widget.index!].selVarient!]
      //               .price!) -
      //           double.parse(
      //             widget
      //                 .favList[widget.index!]
      //                 .prVarientList![
      //                     widget.favList[widget.index!].selVarient!]
      //                 .disPrice!,
      //           ))
      //       .toDouble();
      //   off = off *
      //       100 /
      //       double.parse(widget
      //           .favList[widget.index!]
      //           .prVarientList![widget.favList[widget.index!].selVarient!]
      //           .price!);
      // }

      return Selector<CartProvider, Tuple2<List<String?>, String?>>(
        builder: (context, data, child) {
          double price = double.parse(widget
              .favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!]
              .disPrice!);
          if (price == 0) {
            price = double.parse(widget
                .favList[widget.index!]
                .prVarientList![widget.favList[widget.index!].selVarient!]
                .price!);
          }
          double off = 0;
          if (widget
                  .favList[widget.index!]
                  .prVarientList![widget.favList[widget.index!].selVarient!]
                  .disPrice !=
              '0') {
            off = (double.parse(widget
                        .favList[widget.index!]
                        .prVarientList![
                            widget.favList[widget.index!].selVarient!]
                        .price!) -
                    double.parse(
                      widget
                          .favList[widget.index!]
                          .prVarientList![
                              widget.favList[widget.index!].selVarient!]
                          .disPrice!,
                    ))
                .toDouble();
            off = off *
                100 /
                double.parse(widget
                    .favList[widget.index!]
                    .prVarientList![widget.favList[widget.index!].selVarient!]
                    .price!);
          }
          if (data.item1.contains(widget.favList[widget.index!]
              .prVarientList![widget.favList[widget.index!].selVarient!].id)) {
            context
                .read<FavoriteProvider>()
                .controllerText[widget.index!]
                .text = data.item2.toString();
          } else {
            if (CUR_USERID != null) {
              context
                      .read<FavoriteProvider>()
                      .controllerText[widget.index!]
                      .text =
                  widget
                      .favList[widget.index!]
                      .prVarientList![widget.favList[widget.index!].selVarient!]
                      .cartCount!;
            } else {
              context
                  .read<FavoriteProvider>()
                  .controllerText[widget.index!]
                  .text = '0';
            }
          }
          return Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 10,
              start: 10,
              top: 5.0,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 0.1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    splashColor: colors.primary.withOpacity(0.2),
                    onTap: () {
                      Product model = widget.favList[widget.index!];
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ProductDetail(
                            model: model,
                            secPos: 0,
                            index: widget.index!,
                            list: true,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Hero(
                          tag:
                              '${widget.index}!${widget.favList[widget.index!].id}${widget.index} ${widget.favList[widget.index!].name}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                            child: Stack(
                              children: [
                                DesignConfiguration.getCacheNotworkImage(
                                  context: context,
                                  boxFit: BoxFit.cover,
                                  heightvalue: 100.0,
                                  widthvalue: 100.0,
                                  placeHolderSize: 125,
                                  imageurlString:
                                      widget.favList[widget.index!].image!,
                                ),
                                Positioned.fill(
                                  child: widget.favList[widget.index!]
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
                                                    fontFamily: 'ubuntu',
                                                    color: colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                                off != 0
                                    ? GetDicountLabel(discount: off)
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      top: 15.0,
                                      start: 15.0,
                                    ),
                                    child: Text(
                                      widget.favList[widget.index!].name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack,
                                            fontFamily: 'ubuntu',
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: textFontSize12,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 15.0,
                                      top: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          DesignConfiguration.getPriceFormat(
                                              context, price)!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .blue,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ubuntu',
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          double.parse(widget
                                                      .favList[widget.index!]
                                                      .prVarientList![0]
                                                      .disPrice!) !=
                                                  0
                                              ? DesignConfiguration
                                                  .getPriceFormat(
                                                  context,
                                                  double.parse(
                                                    widget
                                                        .favList[widget.index!]
                                                        .prVarientList![0]
                                                        .price!,
                                                  ),
                                                )!
                                              : '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline!
                                              .copyWith(
                                                fontFamily: 'ubuntu',
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    colors.darkColor3,
                                                decorationStyle:
                                                    TextDecorationStyle.solid,
                                                decorationThickness: 2,
                                                letterSpacing: 0,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  widget.favList[widget.index!].rating! !=
                                          '0.00'
                                      ? Padding(
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            top: 8.0,
                                            start: 15.0,
                                          ),
                                          child: StarRating(
                                            noOfRatings: widget
                                                .favList[widget.index!]
                                                .noOfRating!,
                                            totalRating: widget
                                                .favList[widget.index!].rating!,
                                            needToShowNoOfRatings: true,
                                          ),
                                        )
                                      : Container(),
                                  context
                                              .read<FavoriteProvider>()
                                              .controllerText[widget.index!]
                                              .text !=
                                          '0'
                                      ? Row(
                                          children: [
                                            widget.favList[widget.index!]
                                                        .availability ==
                                                    '0'
                                                ? Container()
                                                : cartBtnList
                                                    ? Row(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              InkWell(
                                                                child: Card(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                      50,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(
                                                                      8.0,
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 15,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  if (int.parse(context
                                                                          .read<
                                                                              FavoriteProvider>()
                                                                          .controllerText[
                                                                              widget.index!]
                                                                          .text) >
                                                                      0) {
                                                                    removeFromCart(
                                                                      widget
                                                                          .index!,
                                                                      widget
                                                                          .favList,
                                                                      context,
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width: 26,
                                                                height: 20,
                                                                child: Stack(
                                                                  children: [
                                                                    Selector<
                                                                        CartProvider,
                                                                        Tuple2<
                                                                            List<String?>,
                                                                            String?>>(
                                                                      builder: (context,
                                                                          data,
                                                                          child) {
                                                                        return TextField(
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          readOnly:
                                                                              true,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor,
                                                                          ),
                                                                          controller: context
                                                                              .read<FavoriteProvider>()
                                                                              .controllerText[widget.index!],
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            border:
                                                                                InputBorder.none,
                                                                          ),
                                                                        );
                                                                      },
                                                                      selector: (_, provider) => Tuple2(
                                                                          provider
                                                                              .cartIdList,
                                                                          provider.qtyList(
                                                                              widget.favList[widget.index!].id!,
                                                                              widget.favList[widget.index!].prVarientList![widget.favList[widget.index!].selVarient!].id!)),
                                                                    ),
                                                                    PopupMenuButton<
                                                                        String>(
                                                                      tooltip:
                                                                          '',
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_drop_down,
                                                                        size: 1,
                                                                      ),
                                                                      onSelected:
                                                                          (String
                                                                              value) {
                                                                        addToCart(
                                                                          value,
                                                                          2,
                                                                          widget
                                                                              .favList,
                                                                        );
                                                                      },
                                                                      itemBuilder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return widget
                                                                            .favList[widget.index!]
                                                                            .itemsCounter!
                                                                            .map<PopupMenuItem<String>>(
                                                                          (String
                                                                              value) {
                                                                            return PopupMenuItem(
                                                                              value: value,
                                                                              child: Text(
                                                                                value,
                                                                                style: TextStyle(
                                                                                  fontFamily: 'ubuntu',
                                                                                  color: Theme.of(context).colorScheme.fontColor,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ).toList();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              InkWell(
                                                                child: Card(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                  ),
                                                                  child:
                                                                      const Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      size: 15,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap:
                                                                    () async {
                                                                  await addToCart(
                                                                    (int.parse(context.read<FavoriteProvider>().controllerText[widget.index!].text) +
                                                                            int.parse(widget.favList[widget.index!].qtyStepSize!))
                                                                        .toString(),
                                                                    2,
                                                                    widget
                                                                        .favList,
                                                                  );
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                              Positioned.directional(
                                textDirection: Directionality.of(context),
                                end: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    right: 5,
                                    top: 5.0,
                                  ),
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                    child: const Icon(
                                      Icons.close,
                                    ),
                                    onTap: () {
                                      if (CUR_USERID != null) {
                                        Future.delayed(Duration.zero).then(
                                          (value) => context
                                              .read<UpdateFavProvider>()
                                              .removeFav(
                                                  widget.favList[widget.index!]
                                                      .id!,
                                                  widget.favList[widget.index!]
                                                      .prVarientList![0].id!,
                                                  context),
                                        );
                                      } else {
                                        db.addAndRemoveFav(
                                            widget.favList[widget.index!].id!,
                                            false);
                                        context
                                            .read<FavoriteProvider>()
                                            .removeFavItem(widget
                                                .favList[widget.index!]
                                                .prVarientList![0]
                                                .id!);

                                        setSnackbar(
                                            getTranslated(context,
                                                'Removed from favorite')!,
                                            context);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.favList[widget.index!].availability == '0'
                    ? Container()
                    : context
                                .read<FavoriteProvider>()
                                .controllerText[widget.index!]
                                .text ==
                            '0'
                        ? Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 4,
                            end: 4,
                            child: InkWell(
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40.0),
                                  color: Theme.of(context).colorScheme.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 12,
                                      color: Color.fromRGBO(0, 0, 0, 0.13),
                                      spreadRadius: 0.4,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 20,
                                ),
                              ),
                              onTap: () async {
                                await addToCart(
                                  '1',
                                  1,
                                  widget.favList,
                                ).then(
                                  (value) {
                                    Future.delayed(const Duration(seconds: 3))
                                        .then(
                                      (_) async {
                                        context
                                            .read<UserProvider>()
                                            .setCartCount(context
                                                    .read<UpdateFavProvider>()
                                                    .cartCount ??
                                                '');

                                        widget.updateNow();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        : Container()
              ],
            ),
          );
        },
        selector: (_, provider) => Tuple2(
          provider.cartIdList,
          provider.qtyList(
            widget.favList[widget.index!].id!,
            widget.favList[widget.index!].prVarientList![0].id!,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
