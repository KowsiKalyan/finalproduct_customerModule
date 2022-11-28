import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import '../../../Helper/Constant.dart';
import '../../../widgets/desing.dart';
import '../../../widgets/star_rating.dart';

class GetSellerProfile extends StatefulWidget {
  String? sellerImage,
      sellerStoreName,
      sellerRating,
      storeDesc,
      totalProductsOfSeller;
  GetSellerProfile({
    Key? key,
    this.sellerImage,
    this.sellerStoreName,
    this.sellerRating,
    this.storeDesc,
    this.totalProductsOfSeller,
  }) : super(key: key);

  @override
  State<GetSellerProfile> createState() => _GetSellerProfileState();
}

class _GetSellerProfileState extends State<GetSellerProfile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 10.0, end: 10.0, top: 20.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            borderRadius: BorderRadius.circular(circularBorderRadius10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7.0),
                    child: DesignConfiguration.getCacheNotworkImage(
                      boxFit: BoxFit.cover,
                      context: context,
                      heightvalue: 75,
                      widthvalue: 75,
                      imageurlString: widget.sellerImage!,
                      placeHolderSize: 75,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 15.0),
                        child: Text(
                          widget.sellerStoreName!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                                fontSize: textFontSize16,
                                fontFamily: 'ubuntu',
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 8.0,
                          start: 15.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: StarRating(
                                noOfRatings: '0',
                                totalRating: widget.sellerRating!,
                                needToShowNoOfRatings: false,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '| ${widget.totalProductsOfSeller!} ${getTranslated(context, 'PRODUCTS')!}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  fontSize: textFontSize14,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 10.0,
                end: 10.0,
                top: 10.0,
              ),
              child: Text(
                widget.storeDesc!,
                style: const TextStyle(
                  fontFamily: 'ubuntu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
