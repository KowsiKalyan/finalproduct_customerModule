import 'dart:convert';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/Favourite/FavoriteProvider.dart';
import '../../../Provider/SettingProvider.dart';
import '../../../Provider/explore_provider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/snackbar.dart';
import '../../../widgets/star_rating.dart';
import '../../Dashboard/Dashboard.dart';
import '../../Product Detail/productDetail.dart';
import '../../SellerDetail/Seller_Details.dart' as sellerDetail;
import '../explore.dart' as explore;

class ListViewLayOut extends StatefulWidget {
  bool fromExplore;
  Function update;
  ListViewLayOut({
    Key? key,
    required this.fromExplore,
    required this.update,
  }) : super(key: key);

  @override
  State<ListViewLayOut> createState() => _ListViewLayOutState();
}

class _ListViewLayOutState extends State<ListViewLayOut> {
  showSanckBarNowForAdd(
    Response response,
    Product model,
    int index,
  ) {
    //
    var getdata = json.decode(response.body);

    bool error = getdata['error'];
    String? msg = getdata['message'];
    if (!error) {
      index == -1
          ? model.isFav = '1'
          : context.read<ExploreProvider>().productList[index].isFav = '1';
      context.read<FavoriteProvider>().addFavItem(model);
      setSnackbar(msg!, context);
    } else {
      setSnackbar(msg!, context);
    }
    index == -1
        ? model.isFavLoading = false
        : context.read<ExploreProvider>().productList[index].isFavLoading =
            false;
    widget.update();
    setState(() {});
  }

  showSanckBarNowForRemove(
    Response response,
    int index,
    Product model,
  ) {
    //
    var getdata = json.decode(response.body);
    bool error = getdata['error'];
    String? msg = getdata['message'];
    if (!error) {
      index == -1
          ? model.isFav = '0'
          : context.read<ExploreProvider>().productList[index].isFav = '0';
      context
          .read<FavoriteProvider>()
          .removeFavItem(model.prVarientList![0].id!);
      setSnackbar(msg!, context);
    } else {
      setSnackbar(msg!, context);
    }
    index == -1
        ? model.isFavLoading = false
        : context.read<ExploreProvider>().productList[index].isFavLoading =
            false;
    widget.update();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: ListView.builder(
        itemCount: context.read<ExploreProvider>().productList.length,
        shrinkWrap: true,
        controller: widget.fromExplore
            ? explore.productsController
            : sellerDetail.productsController,
        itemBuilder: (BuildContext context, int index) {
          String? offPer;
          double price = double.parse(context
              .read<ExploreProvider>()
              .productList[index]
              .prVarientList![0]
              .disPrice!);
          if (price == 0) {
            price = double.parse(context
                .read<ExploreProvider>()
                .productList[index]
                .prVarientList![0]
                .price!);
          } else {
            double off = double.parse(context
                    .read<ExploreProvider>()
                    .productList[index]
                    .prVarientList![0]
                    .price!) -
                price;
            offPer = ((off * 100) /
                    double.parse(context
                        .read<ExploreProvider>()
                        .productList[index]
                        .prVarientList![0]
                        .price!))
                .toStringAsFixed(2);
          }

          Product model = context.read<ExploreProvider>().productList[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(
                start: 10.0, end: 10.0, top: 5.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.white,
                borderRadius: BorderRadius.circular(circularBorderRadius10),
              ),
              child: InkWell(
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4)),
                            child: DesignConfiguration.getCacheNotworkImage(
                              boxFit: BoxFit.cover,
                              context: context,
                              heightvalue: 107,
                              widthvalue: 107,
                              placeHolderSize: 50,
                              imageurlString: context
                                  .read<ExploreProvider>()
                                  .productList[index]
                                  .image!,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    top: 15.0, start: 15.0),
                                child: Text(
                                  context
                                      .read<ExploreProvider>()
                                      .productList[index]
                                      .name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                          fontFamily: 'ubuntu',
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
                                    start: 15.0, top: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      DesignConfiguration.getPriceFormat(
                                          context, price)!,
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'ubuntu',
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      double.parse(context
                                                  .read<ExploreProvider>()
                                                  .productList[index]
                                                  .prVarientList![0]
                                                  .disPrice!) !=
                                              0
                                          ? DesignConfiguration.getPriceFormat(
                                              context,
                                              double.parse(context
                                                  .read<ExploreProvider>()
                                                  .productList[index]
                                                  .prVarientList![0]
                                                  .price!))!
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
                                              letterSpacing: 0),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    top: 8.0, start: 15.0),
                                child: StarRating(
                                  noOfRatings: context
                                      .read<ExploreProvider>()
                                      .productList[index]
                                      .noOfRating!,
                                  totalRating: context
                                      .read<ExploreProvider>()
                                      .productList[index]
                                      .rating!,
                                  needToShowNoOfRatings: true,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: 0,
                      end: 0,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: model.isFavLoading!
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
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
                                            ? context
                                                .read<ExploreProvider>()
                                                .setFav(
                                                  index,
                                                  model,
                                                  widget.update,
                                                  context,
                                                  showSanckBarNowForAdd,
                                                )
                                            : context
                                                .read<ExploreProvider>()
                                                .removeFav(
                                                  index,
                                                  model,
                                                  context,
                                                  widget.update,
                                                  context
                                                      .read<ExploreProvider>()
                                                      .productList,
                                                  showSanckBarNowForRemove,
                                                );
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
                                              getTranslated(context,
                                                  "Removed from favorite")!,
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
                                              getTranslated(context,
                                                  "Added to favorite")!,
                                              context);
                                        }
                                        setState(() {});
                                      }
                                    },
                                  );
                                },
                                selector: (_, provider) => provider.favIdList,
                              ),
                      ),
                    )
                  ],
                ),
                onTap: () async {
                  // SettingProvider settingsProvider =
                  //     Provider.of<SettingProvider>(context, listen: false);
                  Product model =
                      context.read<ExploreProvider>().productList[index];
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        secPos: 0,
                        index: index,
                        list: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
