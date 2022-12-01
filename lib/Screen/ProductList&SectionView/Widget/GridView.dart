import 'dart:async';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/CartProvider.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Product Detail/productDetail.dart';
import '../SectionList.dart';

class GridViewWidget extends StatefulWidget {
  final int? index;
  SectionModel? section_model;
  final int from;
  Function setState;
  GridViewWidget({
    Key? key,
    this.index,
    this.section_model,
    required this.from,
    required this.setState,
  });

  @override
  State<GridViewWidget> createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  removeFav(
    int index,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        widget.section_model!.productList![index].isFavLoading = true;
        widget.setState();

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model!.productList![index].id
        };
        ApiBaseHelper().postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            widget.section_model!.productList![index].isFav = '0';

            context.read<FavoriteProvider>().removeFavItem(widget
                .section_model!.productList![index].prVarientList![0].id!);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          widget.section_model!.productList![index].isFavLoading = false;
          widget.setState();
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      isNetworkAvail = false;
      widget.setState();
    }
  }

  _setFav(int index) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          widget.section_model!.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: widget.section_model!.productList![index].id
        };

        ApiBaseHelper().postAPICall(setFavoriteApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              widget.section_model!.productList![index].isFav = '1';
              context
                  .read<FavoriteProvider>()
                  .addFavItem(widget.section_model!.productList![index]);
              setSnackbar(msg!, context);
            } else {
              setSnackbar(msg!, context);
            }

            if (mounted) {
              widget.section_model!.productList![index].isFavLoading = false;
              widget.setState();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  removeFromCart(int index) async {
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          int qty;

          qty = (int.parse(controllerText[index].text) -
              int.parse(model.qtyStepSize!));

          if (qty < model.minOrderQuntity!) {
            qty = 0;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };
          ApiBaseHelper().postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];

                userProvider.setCartCount(data['cart_count']);
                model.prVarientList![model.selVarient!].cartCount =
                    qty.toString();

                var cart = getdata['cart'];
                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                isProgress = false;
                widget.setState();
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty = (int.parse(controllerText[index].text) -
            int.parse(model.qtyStepSize!));

        if (qty < model.minOrderQuntity!) {
          qty = 0;
          context
              .read<CartProvider>()
              .removeCartItem(model.prVarientList![model.selVarient!].id!);
          db.removeCart(
              model.prVarientList![model.selVarient!].id!, model.id!, context);
        } else {
          context.read<CartProvider>().updateCartItem(model.id!, qty.toString(),
              model.selVarient!, model.prVarientList![model.selVarient!].id!);
          db.updateCart(
            model.id!,
            model.prVarientList![model.selVarient!].id!,
            qty.toString(),
          );
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  Future<void> addToCart(int index, String qty, int from) async {
    Product model;
    if (widget.from == 1) {
      model = widget.section_model!.productList![index];
    } else {
      model = widget.section_model!.productList![index];
    }
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        try {
          if (mounted) {
            isProgress = true;
            widget.setState();
          }

          if (int.parse(qty) < model.minOrderQuntity!) {
            qty = model.minOrderQuntity.toString();

            setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
          }

          var parameter = {
            USER_ID: CUR_USERID,
            PRODUCT_VARIENT_ID: model.prVarientList![model.selVarient!].id,
            QTY: qty
          };

          ApiBaseHelper().postAPICall(manageCartApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                var data = getdata['data'];

                String? qty = data['total_quantity'];

                userProvider.setCartCount(data['cart_count']);
                model.prVarientList![model.selVarient!].cartCount =
                    qty.toString();

                var cart = getdata['cart'];

                List<SectionModel> cartList = (cart as List)
                    .map((cart) => SectionModel.fromCart(cart))
                    .toList();
                context.read<CartProvider>().setCartlist(cartList);
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                isProgress = false;
                widget.setState();
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, context);
          if (mounted) {
            isProgress = false;
            widget.setState();
          }
        }
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' || CurrentSellerID == model.seller_id) {
            CurrentSellerID = model.seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(model);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId: model.prVarientList![model.selVarient!].id!,
                      id: model.id,
                      sellerId: model.seller_id,
                    ),
                  );
              db.insertCart(
                model.id!,
                model.prVarientList![model.selVarient!].id!,
                qty,
                context,
              );
              setSnackbar(getTranslated(context, 'Product Added Successfully')!,
                  context);
            } else {
              if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
                setSnackbar(
                    "${getTranslated(context, 'MAXQTY')!} ${int.parse(model.itemsCounter!.last)}",
                    context);
              } else {
                context.read<CartProvider>().updateCartItem(
                    model.id!,
                    qty,
                    model.selVarient!,
                    model.prVarientList![model.selVarient!].id!);
                db.updateCart(
                  model.id!,
                  model.prVarientList![model.selVarient!].id!,
                  qty,
                );
                setSnackbar(getTranslated(context, 'Cart Update Successfully')!,
                    context);
              }
            }
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(model);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: model.prVarientList![model.selVarient!].id!,
                    id: model.id,
                    sellerId: model.seller_id,
                  ),
                );
            db.insertCart(
              model.id!,
              model.prVarientList![model.selVarient!].id!,
              qty,
              context,
            );
            setSnackbar(
                getTranslated(context, 'Product Added Successfully')!, context);
          } else {
            if (int.parse(qty) > int.parse(model.itemsCounter!.last)) {
              setSnackbar(
                  "${getTranslated(context, 'MAXQTY')!} ${int.parse(model.itemsCounter!.last)}",
                  context);
            } else {
              context.read<CartProvider>().updateCartItem(
                  model.id!,
                  qty,
                  model.selVarient!,
                  model.prVarientList![model.selVarient!].id!);
              db.updateCart(
                model.id!,
                model.prVarientList![model.selVarient!].id!,
                qty,
              );
              setSnackbar(
                  getTranslated(context, 'Cart Update Successfully')!, context);
            }
          }
        }
        isProgress = false;
        widget.setState();
      }
    } else {
      if (mounted) {
        isNetworkAvail = false;
        widget.setState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index! < widget.section_model!.productList!.length) {
      Product model = widget.section_model!.productList![widget.index!];

      double width = deviceWidth! * 0.5 - 20;
      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }

      if (controllerText.length < widget.index! + 1) {
        controllerText.add(TextEditingController());
      }

      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = (double.parse(
                  model.prVarientList![model.selVarient!].price!) -
              double.parse(model.prVarientList![model.selVarient!].disPrice!))
          .toDouble();
      off = off *
          100 /
          double.parse(model.prVarientList![model.selVarient!].price!);
      return Selector<CartProvider, Tuple2<List<String?>, String?>>(
        builder: (context, data, child) {
          if (data.item1.contains(model.prVarientList![model.selVarient!].id)) {
            controllerText[widget.index!].text = data.item2.toString();
          } else {
            if (CUR_USERID != null) {
              controllerText[widget.index!].text =
                  model.prVarientList![model.selVarient!].cartCount!;
            } else {
              controllerText[widget.index!].text = '0';
            }
          }

          return Card(
            elevation: 0,
            child: InkWell(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        Hero(
                          tag: '${widget.index}!${model.image}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              imageurlString: model.image!,
                              placeHolderSize: width,
                            ),
                          ),
                        ),
                        model.availability == '0'
                            ? Container(
                                constraints: const BoxConstraints.expand(),
                                color: colors.white70,
                                width: double.maxFinite,
                                padding: const EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                          color: colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container(),
                        off != 0 &&
                                model.prVarientList![model.selVarient!]
                                        .disPrice! !=
                                    '0'
                            ? Align(
                                alignment: AlignmentDirectional.topStart,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: colors.red,
                                  ),
                                  margin: const EdgeInsets.all(5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      '${off.round().toStringAsFixed(2)}%',
                                      style: const TextStyle(
                                          color: colors.whiteTemp,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        const Divider(
                          height: 1,
                        ),
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              controllerText[widget.index!].text == '0'
                                  ? InkWell(
                                      onTap: () {
                                        if (isProgress == false) {
                                          addToCart(
                                            widget.index!,
                                            (int.parse(controllerText[
                                                            widget.index!]
                                                        .text) +
                                                    int.parse(
                                                        model.qtyStepSize!))
                                                .toString(),
                                            1,
                                          );
                                        }
                                      },
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 3.0, bottom: 5, top: 3),
                                      child: model.availability == '0'
                                          ? Container()
                                          : cartBtnList
                                              ? Row(
                                                  children: <Widget>[
                                                    InkWell(
                                                      child: Card(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (isProgress ==
                                                                false &&
                                                            (int.parse(controllerText[
                                                                        widget
                                                                            .index!]
                                                                    .text)) >
                                                                0) {
                                                          removeFromCart(
                                                            widget.index!,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    Container(
                                                      width: 37,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: colors.white70,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          TextField(
                                                            textAlign: TextAlign
                                                                .center,
                                                            readOnly: true,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .fontColor),
                                                            controller:
                                                                controllerText[
                                                                    widget
                                                                        .index!],
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                            ),
                                                          ),
                                                          PopupMenuButton<
                                                              String>(
                                                            tooltip: '',
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              size: 0,
                                                            ),
                                                            onSelected:
                                                                (String value) {
                                                              if (isProgress ==
                                                                  false) {
                                                                addToCart(
                                                                    widget
                                                                        .index!,
                                                                    value,
                                                                    2);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (BuildContext
                                                                    context) {
                                                              return model
                                                                  .itemsCounter!
                                                                  .map<
                                                                      PopupMenuItem<
                                                                          String>>(
                                                                (String value) {
                                                                  return PopupMenuItem(
                                                                      value:
                                                                          value,
                                                                      child: Text(
                                                                          value,
                                                                          style:
                                                                              TextStyle(color: Theme.of(context).colorScheme.fontColor)));
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
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        if (isProgress ==
                                                            false) {
                                                          addToCart(
                                                            widget.index!,
                                                            (int.parse(controllerText[widget
                                                                            .index!]
                                                                        .text) +
                                                                    int.parse(model
                                                                        .qtyStepSize!))
                                                                .toString(),
                                                            2,
                                                          );
                                                        }
                                                      },
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                    ),
                            ],
                          ),
                        ),
                        Positioned.directional(
                          top: 0,
                          end: 0,
                          textDirection: Directionality.of(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                              borderRadius: const BorderRadiusDirectional.only(
                                bottomStart: Radius.circular(
                                  circularBorderRadius10,
                                ),
                                topEnd: Radius.circular(
                                  4,
                                ),
                              ),
                            ),
                            child: model.isFavLoading!
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: colors.primary,
                                        strokeWidth: 0.7,
                                      ),
                                    ),
                                  )
                                : Selector<FavoriteProvider, List<String?>>(
                                    builder: (context, data, child) {
                                      return InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            !data.contains(model.id)
                                                ? Icons.favorite_border
                                                : Icons.favorite,
                                            size: 15,
                                          ),
                                        ),
                                        onTap: () {
                                          if (CUR_USERID != null) {
                                            !data.contains(model.id)
                                                ? _setFav(widget.index!)
                                                : removeFav(
                                                    widget.index!,
                                                  );
                                          } else {
                                            if (!data.contains(model.id)) {
                                              model.isFavLoading = true;
                                              model.isFav = '1';
                                              context
                                                  .read<FavoriteProvider>()
                                                  .addFavItem(model);
                                              db.addAndRemoveFav(
                                                  model.id!, true);
                                              model.isFavLoading = false;
                                              setSnackbar(
                                                  getTranslated(context,
                                                      "Added to favorite")!,
                                                  context);
                                            } else {
                                              model.isFavLoading = true;
                                              model.isFav = '0';
                                              context
                                                  .read<FavoriteProvider>()
                                                  .removeFavItem(model
                                                      .prVarientList![0].id!);
                                              db.addAndRemoveFav(
                                                  model.id!, false);
                                              model.isFavLoading = false;
                                              setSnackbar(
                                                  getTranslated(context,
                                                      'Removed from favorite')!,
                                                  context);
                                            }
                                            widget.setState();
                                          }
                                        },
                                      );
                                    },
                                    selector: (_, provider) =>
                                        provider.favIdList,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10.0,
                      top: 15,
                    ),
                    child: Text(
                      model.name!,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize12,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        Text(
                          ' ${DesignConfiguration.getPriceFormat(context, price)!}',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: textFontSize14,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 10.0,
                              top: 5,
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  double.parse(model
                                                  .prVarientList![
                                                      model.selVarient!]
                                                  .disPrice!) !=
                                              0 &&
                                          double.parse(model
                                                  .prVarientList![
                                                      model.selVarient!]
                                                  .disPrice!) !=
                                              double.parse(model
                                                  .prVarientList![
                                                      model.selVarient!]
                                                  .price!)
                                      ? DesignConfiguration.getPriceFormat(
                                          context,
                                          double.parse(model
                                              .prVarientList![model.selVarient!]
                                              .price!))!
                                      : '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: colors.darkColor3,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        decorationThickness: 2,
                                        letterSpacing: 0,
                                        fontSize: textFontSize10,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10.0,
                      top: 10,
                      bottom: 5,
                    ),
                    child: StarRating(
                      totalRating: model.rating!,
                      noOfRatings: model.noOfRating!,
                      needToShowNoOfRatings: true,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Product model =
                    widget.section_model!.productList![widget.index!];
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProductDetail(
                      model: model,
                      secPos: widget.index,
                      index: widget.index!,
                      list: false,
                    ),
                  ),
                );
              },
            ),
          );
        },
        selector: (_, provider) => Tuple2(
          provider.cartIdList,
          provider.qtyList(model.id!, model.prVarientList![0].id!),
        ),
      );
    } else {
      return Container();
    }
  }
}
