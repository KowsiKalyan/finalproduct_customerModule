import 'dart:async';
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

class ListIteamWidget extends StatefulWidget {
  List<Product>? productList;
  final int? index;
  SectionModel? section_model;
  final int from;
  int? length;
  Function setState;
  ListIteamWidget({
    this.productList,
    this.index,
    this.section_model,
    required this.from,
    required this.setState,
    this.length,
  });

  @override
  State<ListIteamWidget> createState() => _ListIteamWidgetState();
}

class _ListIteamWidgetState extends State<ListIteamWidget> {
  _removeFav(int index) async {
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
        apiBaseHelper.postAPICall(removeFavApi, parameter).then(
          (getdata) {
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

        apiBaseHelper.postAPICall(setFavoriteApi, parameter).then(
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
      model = widget.productList![index];
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
          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
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
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
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
      model = widget.productList![index];
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

          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
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
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
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
                setSnackbar(
                    "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                    context);
              }
            }
          } else {
            setSnackbar('only Single Seller Product Allow', context);
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
                  "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                  context);
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
    if (widget.index! < widget.length!) {
      Product model;
      if (widget.from == 1) {
        model = widget.section_model!.productList![widget.index!];
      } else {
        model = widget.productList![widget.index!];
      }
      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
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

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      if (controllerText.length < widget.index! + 1) {
        controllerText.add(TextEditingController());
      }

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
          return Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 10.0, end: 10.0, top: 5.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                              tag: "${widget.index}${model.id}",
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4)),
                                child: Stack(
                                  children: [
                                    DesignConfiguration.getCacheNotworkImage(
                                      boxFit: BoxFit.cover,
                                      context: context,
                                      heightvalue: 125.0,
                                      widthvalue: 110.0,
                                      placeHolderSize: 125,
                                      imageurlString: model.image!,
                                    ),
                                    model.availability == '0'
                                        ? Container(
                                            color: colors.white70,
                                            width: 110,
                                            padding: const EdgeInsets.all(2),
                                            height: 125,
                                            child: Center(
                                              child: Text(
                                                  getTranslated(context,
                                                      'OUT_OF_STOCK_LBL')!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2!
                                                      .copyWith(
                                                          color: colors.red,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                            ),
                                          )
                                        : Container(),
                                    off != 0 &&
                                            model
                                                    .prVarientList![
                                                        model.selVarient!]
                                                    .disPrice! !=
                                                '0'
                                        ? Container(
                                            decoration: const BoxDecoration(
                                              color: colors.red,
                                            ),
                                            margin: const EdgeInsets.all(5),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                '${off.round().toStringAsFixed(2)}%',
                                                style: const TextStyle(
                                                  color: colors.whiteTemp,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 2.0, start: 15.0),
                                      child: Text(
                                        model.name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.w400,
                                                fontStyle: FontStyle.normal,
                                                fontSize: textFontSize12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 15.0, top: 4.0),
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
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            double.parse(model.prVarientList![0]
                                                            .disPrice!) !=
                                                        0 &&
                                                    model.prVarientList![0]
                                                            .disPrice! !=
                                                        model.prVarientList![0]
                                                            .price
                                                ? DesignConfiguration
                                                    .getPriceFormat(
                                                        context,
                                                        double.parse(model
                                                            .prVarientList![0]
                                                            .price!))!
                                                : '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .overline!
                                                .copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough,
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
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 0.0, start: 15.0),
                                      child: StarRating(
                                        noOfRatings: model.noOfRating!,
                                        totalRating: model.rating!,
                                        needToShowNoOfRatings: true,
                                      ),
                                    ),
                                    controllerText[widget.index!].text != '0'
                                        ? Row(
                                            children: [
                                              model.availability == '0'
                                                  ? Container()
                                                  : cartBtnList
                                                      ? Row(
                                                          children: <Widget>[
                                                            Row(
                                                              children: <
                                                                  Widget>[
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
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    if (isProgress ==
                                                                            false &&
                                                                        (int.parse(controllerText[widget.index!].text)) >
                                                                            0) {
                                                                      removeFromCart(
                                                                          widget
                                                                              .index!);
                                                                    }
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: 37,
                                                                  height: 20,
                                                                  child: Stack(
                                                                    children: [
                                                                      TextField(
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        readOnly:
                                                                            true,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Theme.of(context).colorScheme.fontColor),
                                                                        controller:
                                                                            controllerText[widget.index!],
                                                                        decoration:
                                                                            const InputDecoration(
                                                                          border:
                                                                              InputBorder.none,
                                                                        ),
                                                                      ),
                                                                      PopupMenuButton<
                                                                          String>(
                                                                        tooltip:
                                                                            '',
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          size:
                                                                              0,
                                                                        ),
                                                                        onSelected:
                                                                            (String
                                                                                value) {
                                                                          if (isProgress ==
                                                                              false) {
                                                                            addToCart(
                                                                                widget.index!,
                                                                                value,
                                                                                2);
                                                                          }
                                                                        },
                                                                        itemBuilder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return model
                                                                              .itemsCounter!
                                                                              .map<PopupMenuItem<String>>((String value) {
                                                                            return PopupMenuItem(
                                                                                value: value,
                                                                                child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.fontColor)));
                                                                          }).toList();
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
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            15,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  onTap: () {
                                                                    if (isProgress ==
                                                                        false) {
                                                                      addToCart(
                                                                          widget
                                                                              .index!,
                                                                          (int.parse(controllerText[widget.index!].text) + int.parse(model.qtyStepSize!))
                                                                              .toString(),
                                                                          2);
                                                                    }
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
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ProductDetail(
                                  model: model,
                                  secPos: widget.index,
                                  index: widget.index,
                                  list: true,
                                )),
                      );
                    },
                  ),
                ),
                model.availability == '0' && !cartBtnList
                    ? Container()
                    : controllerText[widget.index!].text == '0'
                        ? Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 4,
                            end: 4,
                            child: InkWell(
                              onTap: () {
                                if (isProgress == false) {
                                  addToCart(
                                    widget.index!,
                                    (int.parse(controllerText[widget.index!]
                                                .text) +
                                            int.parse(model.qtyStepSize!))
                                        .toString(),
                                    1,
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  end: 4,
                  top: 4,
                  child: model.isFavLoading!
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: colors.primary,
                                strokeWidth: 0.7,
                              )),
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
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                if (CUR_USERID != null) {
                                  !data.contains(model.id)
                                      ? _setFav(widget.index!)
                                      : _removeFav(widget.index!);
                                } else {
                                  if (!data.contains(model.id)) {
                                    model.isFavLoading = true;
                                    model.isFav = '1';
                                    context
                                        .read<FavoriteProvider>()
                                        .addFavItem(model);
                                    db.addAndRemoveFav(model.id!, true);
                                    model.isFavLoading = false;
                                    setSnackbar(
                                        getTranslated(
                                            context, 'Added to favorite')!,
                                        context);
                                  } else {
                                    model.isFavLoading = true;
                                    model.isFav = '0';
                                    context
                                        .read<FavoriteProvider>()
                                        .removeFavItem(
                                            model.prVarientList![0].id!);
                                    db.addAndRemoveFav(model.id!, false);
                                    model.isFavLoading = false;
                                    setSnackbar(
                                        getTranslated(
                                            context, 'Removed from favorite')!,
                                        context);
                                  }
                                  widget.setState();
                                }
                              },
                            );
                          },
                          selector: (_, provider) => provider.favIdList,
                        ),
                ),
              ],
            ),
          );
        },
        selector: (_, provider) => Tuple2(
          provider.cartIdList,
          provider.qtyList(
            model.id!,
            model.prVarientList![0].id!,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
