import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/Favourite/FavoriteProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:eshop_multivendor/widgets/star_rating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/String.dart';
import '../../SQLiteData/SqliteData.dart';
import '../../../Provider/Favourite/UpdateFavProvider.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/snackbar.dart';

class SingleProductContainer extends StatelessWidget {
  int? sectionPosition;
  int? index;
  int? pictureFlex;
  int? textFlex;
  Product? productDetails;
  int? length;
  bool? showDiscountAtSameLine;

  SingleProductContainer({
    Key? key,
    required this.sectionPosition,
    required this.index,
    required this.pictureFlex,
    required this.textFlex,
    required this.productDetails,
    required this.length,
    required this.showDiscountAtSameLine,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var db = DatabaseHelper();
    if (length! > index!) {
      String? offPer;
      double price = double.parse(productDetails!.prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(productDetails!.prVarientList![0].price!);

        offPer = '0';
      } else {
        double off =
            double.parse(productDetails!.prVarientList![0].price!) - price;
        offPer = ((off * 100) /
                double.parse(productDetails!.prVarientList![0].price!))
            .toStringAsFixed(2);
      }
      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: pictureFlex!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: '$index${productDetails!.id}',
                        child: DesignConfiguration.getCacheNotworkImage(
                          boxFit: BoxFit.cover,
                          context: context,
                          heightvalue: double.maxFinite,
                          widthvalue: double.maxFinite,
                          placeHolderSize: width,
                          imageurlString: productDetails!.image!,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: textFlex!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 10.0,
                            top: 15,
                          ),
                          child: Text(
                            productDetails!.name!,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                  fontFamily: 'ubuntu',
                                  color:
                                      Theme.of(context).colorScheme.lightBlack,
                                  fontSize: textFontSize10,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                  color: Theme.of(context).colorScheme.blue,
                                  fontSize: textFontSize14,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                              showDiscountAtSameLine!
                                  ? Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsetsDirectional.only(
                                          start: 10.0,
                                          top: 5,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              double.parse(productDetails!
                                                          .prVarientList![0]
                                                          .disPrice!) !=
                                                      0
                                                  ? '${DesignConfiguration.getPriceFormat(context, double.parse(productDetails!.prVarientList![0].price!))}'
                                                  : '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .overline!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    decorationColor:
                                                        colors.darkColor3,
                                                    decorationStyle:
                                                        TextDecorationStyle
                                                            .solid,
                                                    decorationThickness: 2,
                                                    letterSpacing: 0,
                                                    fontSize: textFontSize10,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.normal,
                                                  ),
                                            ),
                                            Text(
                                              '  ${double.parse(offPer).round().toStringAsFixed(2)}%',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .overline!
                                                  .copyWith(
                                                    fontFamily: 'ubuntu',
                                                    color: colors.primary,
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
                                  : Container(),
                            ],
                          ),
                        ),
                        double.parse(productDetails!
                                        .prVarientList![0].disPrice!) !=
                                    0 &&
                                !showDiscountAtSameLine!
                            ? Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 10.0,
                                  top: 5,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      double.parse(productDetails!
                                                  .prVarientList![0]
                                                  .disPrice!) !=
                                              0
                                          ? '${DesignConfiguration.getPriceFormat(context, double.parse(productDetails!.prVarientList![0].price!))}'
                                          : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(
                                            fontFamily: 'ubuntu',
                                            decoration:
                                                TextDecoration.lineThrough,
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
                                    Flexible(
                                      child: Text(
                                        '   ${double.parse(offPer).round().toStringAsFixed(2)}%',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline!
                                            .copyWith(
                                              fontFamily: 'ubuntu',
                                              color: colors.primary,
                                              letterSpacing: 0,
                                              fontSize: textFontSize10,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 10.0,
                            top: 5,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                              top: 5,
                              bottom: 5,
                            ),
                            child: StarRating(
                              totalRating: productDetails!.rating!,
                              noOfRatings: productDetails!.noOfRating!,
                              needToShowNoOfRatings: true,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(circularBorderRadius10),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: productDetails!.isFavLoading!
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
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
                                  !data.contains(productDetails!.id)
                                      ? Icons.favorite_border
                                      : Icons.favorite,
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                if (CUR_USERID != null) {
                                  if (!data.contains(productDetails!.id)) {
                                    productDetails!.isFavLoading = true;
                                    productDetails!.isFav = '1';

                                    Future.delayed(Duration.zero)
                                        .then((value) => context
                                            .read<UpdateFavProvider>()
                                            .addFav(
                                                context, productDetails!.id!, 1,
                                                model: productDetails))
                                        .then(
                                      (value) {
                                        productDetails!.isFavLoading = false;
                                      },
                                    );
                                  } else {
                                    productDetails!.isFavLoading = true;
                                    productDetails!.isFav = '0';

                                    Future.delayed(Duration.zero)
                                        .then(
                                      (value) => context
                                          .read<UpdateFavProvider>()
                                          .removeFav(
                                            productDetails!.id!,
                                            productDetails!
                                                .prVarientList![0].id!,
                                            context,
                                          ),
                                    )
                                        .then(
                                      (value) {
                                        productDetails!.isFavLoading = false;
                                      },
                                    );
                                  }
                                } else {
                                  if (!data.contains(productDetails!.id)) {
                                    productDetails!.isFavLoading = true;
                                    productDetails!.isFav = '1';
                                    context
                                        .read<FavoriteProvider>()
                                        .addFavItem(productDetails);
                                    db.addAndRemoveFav(
                                        productDetails!.id!, true);
                                    productDetails!.isFavLoading = false;
                                    setSnackbar(
                                        getTranslated(
                                            context, 'Added to favorite')!,
                                        context);
                                  } else {
                                    productDetails!.isFavLoading = true;
                                    productDetails!.isFav = '0';
                                    context
                                        .read<FavoriteProvider>()
                                        .removeFavItem(productDetails!
                                            .prVarientList![0].id!);
                                    db.addAndRemoveFav(
                                        productDetails!.id!, false);
                                    productDetails!.isFavLoading = false;
                                    setSnackbar(
                                      getTranslated(
                                          context, 'Removed from favorite')!,
                                      context,
                                    );
                                  }
                                }
                              },
                            );
                          },
                          selector: (_, provider) => provider.favIdList,
                        ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                  model: productDetails,
                  secPos: sectionPosition,
                  index: index,
                  list: false,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container(
        color: Colors.blue,
        height: 50,
        width: 50,
      );
    }
  }
}
