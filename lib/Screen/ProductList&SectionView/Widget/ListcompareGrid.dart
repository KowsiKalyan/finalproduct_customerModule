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
import '../../../Provider/UserProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/networkAvailablity.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Product Detail/productDetail.dart';
import '../ProductList.dart';

class GridViewProductListWidget extends StatefulWidget {
  List<Product>? productList;
  final int? index;
  bool pad;

  Function setState;
  GridViewProductListWidget({
    this.productList,
    this.index,
    required this.pad,
    required this.setState,
  });

  @override
  State<GridViewProductListWidget> createState() =>
      _GridViewProductListWidgetState();
}

class _GridViewProductListWidgetState extends State<GridViewProductListWidget> {
  _removeFav(int index, Product model) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          index == -1
              ? model.isFavLoading = true
              : widget.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        apiBaseHelper.postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            index == -1
                ? model.isFav = '0'
                : widget.productList![index].isFav = '0';
            context
                .read<FavoriteProvider>()
                .removeFavItem(model.prVarientList![0].id!);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            index == -1
                ? model.isFavLoading = false
                : widget.productList![index].isFavLoading = false;
            widget.setState();
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
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

  _setFav(int index, Product model) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        if (mounted) {
          index == -1
              ? model.isFavLoading = true
              : widget.productList![index].isFavLoading = true;
          widget.setState();
        }

        var parameter = {USER_ID: CUR_USERID, PRODUCT_ID: model.id};
        apiBaseHelper.postAPICall(setFavoriteApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            index == -1
                ? model.isFav = '1'
                : widget.productList![index].isFav = '1';

            context.read<FavoriteProvider>().addFavItem(model);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          if (mounted) {
            index == -1
                ? model.isFavLoading = false
                : widget.productList![index].isFavLoading = false;
            widget.setState();
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
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
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        int qty;

        qty = (int.parse(controllerText[index].text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
        }

        var parameter = {
          PRODUCT_VARIENT_ID: widget.productList![index]
              .prVarientList![widget.productList![index].selVarient!].id,
          USER_ID: CUR_USERID,
          QTY: qty.toString()
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            String? qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            widget
                .productList![index]
                .prVarientList![widget.productList![index].selVarient!]
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
            isProgress = false;
            widget.setState();
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          isProgress = false;
        });
        widget.setState();
      } else {
        isProgress = true;
        widget.setState();

        int qty;

        qty = (int.parse(controllerText[index].text) -
            int.parse(widget.productList![index].qtyStepSize!));

        if (qty < widget.productList![index].minOrderQuntity!) {
          qty = 0;
          db.removeCart(
              widget.productList![index]
                  .prVarientList![widget.productList![index].selVarient!].id!,
              widget.productList![index].id!,
              context);
          context.read<CartProvider>().removeCartItem(widget.productList![index]
              .prVarientList![widget.productList![index].selVarient!].id!);
        } else {
          context.read<CartProvider>().updateCartItem(
              widget.productList![index].id!,
              qty.toString(),
              widget.productList![index].selVarient!,
              widget.productList![index]
                  .prVarientList![widget.productList![index].selVarient!].id!);
          db.updateCart(
            widget.productList![index].id!,
            widget.productList![index]
                .prVarientList![widget.productList![index].selVarient!].id!,
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
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != null) {
        if (mounted) {
          isProgress = true;
          widget.setState();
        }

        if (int.parse(qty) < widget.productList![index].minOrderQuntity!) {
          qty = widget.productList![index].minOrderQuntity.toString();

          setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty", context);
        }

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_VARIENT_ID: widget.productList![index]
              .prVarientList![widget.productList![index].selVarient!].id,
          QTY: qty
        };

        apiBaseHelper.postAPICall(manageCartApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];
              context.read<UserProvider>().setCartCount(data['cart_count']);
              widget
                  .productList![index]
                  .prVarientList![widget.productList![index].selVarient!]
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
              isProgress = false;
              widget.setState();
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), context);
            if (mounted) {
              isProgress = false;
              widget.setState();
            }
          },
        );
      } else {
        isProgress = true;
        widget.setState();

        if (singleSellerOrderSystem) {
          if (CurrentSellerID == '' ||
              CurrentSellerID == widget.productList![index].seller_id) {
            CurrentSellerID = widget.productList![index].seller_id!;
            if (from == 1) {
              List<Product>? prList = [];
              prList.add(widget.productList![index]);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId: widget
                          .productList![index]
                          .prVarientList![
                              widget.productList![index].selVarient!]
                          .id!,
                      id: widget.productList![index].id,
                      sellerId: widget.productList![index].seller_id,
                    ),
                  );
              db.insertCart(
                widget.productList![index].id!,
                widget.productList![index]
                    .prVarientList![widget.productList![index].selVarient!].id!,
                qty,
                context,
              );
              setSnackbar(
                  "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                  context);
            } else {
              if (int.parse(qty) >
                  int.parse(widget.productList![index].itemsCounter!.last)) {
                setSnackbar(
                    "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                    context);
              } else {
                context.read<CartProvider>().updateCartItem(
                    widget.productList![index].id!,
                    qty,
                    widget.productList![index].selVarient!,
                    widget
                        .productList![index]
                        .prVarientList![widget.productList![index].selVarient!]
                        .id!);
                db.updateCart(
                  widget.productList![index].id!,
                  widget
                      .productList![index]
                      .prVarientList![widget.productList![index].selVarient!]
                      .id!,
                  qty,
                );
                setSnackbar(getTranslated(context, 'Cart Update Successfully')!,
                    context);
              }
            }
          } else {
            setSnackbar('only Single Seller Product Allow', context);
          }
        } else {
          if (from == 1) {
            List<Product>? prList = [];
            prList.add(widget.productList![index]);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: widget
                        .productList![index]
                        .prVarientList![widget.productList![index].selVarient!]
                        .id!,
                    id: widget.productList![index].id,
                    sellerId: widget.productList![index].seller_id,
                  ),
                );
            db.insertCart(
              widget.productList![index].id!,
              widget.productList![index]
                  .prVarientList![widget.productList![index].selVarient!].id!,
              qty,
              context,
            );
            setSnackbar(
                "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                context);
          } else {
            if (int.parse(qty) >
                int.parse(widget.productList![index].itemsCounter!.last)) {
              setSnackbar(
                  "${getTranslated(context, 'MAXQTY')!} ${widget.productList![index].itemsCounter!.last}",
                  context);
            } else {
              context.read<CartProvider>().updateCartItem(
                  widget.productList![index].id!,
                  qty,
                  widget.productList![index].selVarient!,
                  widget
                      .productList![index]
                      .prVarientList![widget.productList![index].selVarient!]
                      .id!);
              db.updateCart(
                widget.productList![index].id!,
                widget.productList![index]
                    .prVarientList![widget.productList![index].selVarient!].id!,
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
    if (widget.index! < widget.productList!.length) {
      Product model = widget.productList![widget.index!];

      totalProduct = model.total;

      if (controllerText.length < widget.index! + 1) {
        controllerText.add(TextEditingController());
      }

      double price =
          double.parse(model.prVarientList![model.selVarient!].disPrice!);
      if (price == 0) {
        price = double.parse(model.prVarientList![model.selVarient!].price!);
      }

      double off = 0;
      if (model.prVarientList![model.selVarient!].disPrice! != '0') {
        off = (double.parse(model.prVarientList![model.selVarient!].price!) -
                double.parse(model.prVarientList![model.selVarient!].disPrice!))
            .toDouble();
        off = off *
            100 /
            double.parse(model.prVarientList![model.selVarient!].price!);
      }

      if (controllerText.length < widget.index! + 1) {
        controllerText.add(TextEditingController());
      }

      controllerText[widget.index!].text =
          model.prVarientList![model.selVarient!].cartCount!;

      List att = [], val = [];
      if (model.prVarientList![model.selVarient!].attr_name != null) {
        att = model.prVarientList![model.selVarient!].attr_name!.split(',');
        val = model.prVarientList![model.selVarient!].varient_value!.split(',');
      }
      double width = deviceWidth! * 0.5;

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

          return InkWell(
            child: Card(
              elevation: 0.2,
              margin: EdgeInsetsDirectional.only(
                  bottom: 10, end: 10, start: widget.pad ? 10 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                          child: Hero(
                            tag: '${widget.index}${model.id}',
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: double.maxFinite,
                              widthvalue: double.maxFinite,
                              placeHolderSize: width,
                              imageurlString: model.image!,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: model.availability == '0'
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
                                            color: colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ubuntu',
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        off != 0
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
                                        fontFamily: 'ubuntu',
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        const Divider(
                          height: 1,
                        ),
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          end: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              model.availability == '0' && !cartBtnList
                                  ? Container()
                                  : controllerText[widget.index!].text == '0'
                                      ? InkWell(
                                          onTap: () {
                                            if (isProgress == false) {
                                              addToCart(
                                                widget.index!,
                                                (int.parse(controllerText[
                                                                widget.index!]
                                                            .text) +
                                                        int.parse(
                                                          model.qtyStepSize!,
                                                        ))
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
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                            start: 3.0,
                                            bottom: 5,
                                            top: 3,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              InkWell(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (isProgress == false &&
                                                      (int.parse(controllerText[
                                                                  widget.index!]
                                                              .text) >
                                                          0)) {
                                                    removeFromCart(
                                                        widget.index!);
                                                  }
                                                },
                                              ),
                                              Container(
                                                width: 37,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: colors.white70,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Selector<
                                                        CartProvider,
                                                        Tuple2<List<String?>,
                                                            String?>>(
                                                      builder: (context, data,
                                                          child) {
                                                        return TextField(
                                                          textAlign:
                                                              TextAlign.center,
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
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                        );
                                                      },
                                                      selector: (_, provider) =>
                                                          Tuple2(
                                                              provider
                                                                  .cartIdList,
                                                              provider.qtyList(
                                                                  model.id!,
                                                                  model
                                                                      .prVarientList![
                                                                          0]
                                                                      .id!)),
                                                    ),
                                                    PopupMenuButton<String>(
                                                      tooltip: '',
                                                      icon: const Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 0,
                                                      ),
                                                      onSelected:
                                                          (String value) {
                                                        if (isProgress ==
                                                            false) {
                                                          addToCart(
                                                              widget.index!,
                                                              value,
                                                              2);
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return model
                                                            .itemsCounter!
                                                            .map<
                                                                PopupMenuItem<
                                                                    String>>(
                                                          (String value) {
                                                            return PopupMenuItem(
                                                              value: value,
                                                              child: Text(
                                                                value,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .fontColor,
                                                                  fontFamily:
                                                                      'ubuntu',
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
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  if (isProgress == false) {
                                                    addToCart(
                                                        widget.index!,
                                                        (int.parse(controllerText[
                                                                        widget
                                                                            .index!]
                                                                    .text) +
                                                                int.parse(model
                                                                    .qtyStepSize!))
                                                            .toString(),
                                                        2);
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                            ],
                          ),
                        ),
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          top: 0,
                          end: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                borderRadius:
                                    const BorderRadiusDirectional.only(
                                  bottomStart:
                                      Radius.circular(circularBorderRadius10),
                                  topEnd: Radius.circular(
                                    5,
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
                                                  ? _setFav(-1, model)
                                                  : _removeFav(-1, model);
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
                                                        'Added to favorite')!,
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
                                    )),
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
                      widget.productList![widget.index!].name!,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontSize: textFontSize12,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'ubuntu',
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
                            fontFamily: 'ubuntu',
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
                                  double.parse(widget
                                              .productList![widget.index!]
                                              .prVarientList![0]
                                              .disPrice!) !=
                                          0
                                      ? '${DesignConfiguration.getPriceFormat(context, double.parse(widget.productList![widget.index!].prVarientList![0].price!))}'
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
                        start: 10.0, top: 10, bottom: 5),
                    child: StarRating(
                      totalRating: widget.productList![widget.index!].rating!,
                      noOfRatings:
                          widget.productList![widget.index!].noOfRating!,
                      needToShowNoOfRatings: true,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Product model = widget.productList![widget.index!];
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                    model: model,
                    index: widget.index,
                    secPos: 0,
                    list: true,
                  ),
                ),
              );
            },
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
