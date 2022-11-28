import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/ReviewGallleryProvider.dart';
import '../../../Provider/ReviewPreviewProvider.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../Provider/productPrevciewProvider.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import 'reviewStar.dart';

class ReviewWidget extends StatelessWidget {
  int? secPos;
  int? widgetindex;
  Product? model;
  ReviewWidget({Key? key, this.model, this.secPos, this.widgetindex})
      : super(key: key);

  _reviewTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5,
      ),
      child: Row(
        children: [
          Text(
            getTranslated(context, 'Product Ratings & Reviews')!,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Ubuntu',
              fontStyle: FontStyle.normal,
              fontSize: 16.0,
              color: Theme.of(context).colorScheme.lightBlack,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return context.read<ProductDetailProvider>().reviewList.isNotEmpty
        ? Container(
            color: Theme.of(context).colorScheme.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewTitle(context),
                CustomReviewStar(model: model!),
                context.read<ProductDetailProvider>().reviewImgList.isNotEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(
                          right: 8.0,
                          left: 8.0,
                        ),
                        child: Divider(),
                      )
                    : Container(),
                context.read<ProductDetailProvider>().reviewImgList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(
                          right: 15.0,
                          left: 15,
                          top: 19,
                          bottom: 5,
                        ),
                        child: Text(
                          getTranslated(context,
                              'Real images and videos from customers')!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.black,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : Container(),
                ReviewImageWidget(model: model),
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, left: 8.0),
                  child: Divider(),
                ),
                ReviewPart(
                  secPos: secPos,
                  widgetindex: widgetindex,
                ),
              ],
            ),
          )
        : Container();
  }
}

class ReviewImageWidget extends StatelessWidget {
  Product? model;
  ReviewImageWidget({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.read<ProductDetailProvider>().reviewImgList.isNotEmpty
        ? SizedBox(
            height: 60,
            child: ListView.builder(
              itemCount:
                  context.read<ProductDetailProvider>().reviewImgList.length > 6
                      ? 6
                      : context
                          .read<ProductDetailProvider>()
                          .reviewImgList
                          .length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5,
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      if (index == 5) {
                        context
                            .read<ReviewGallaryProvider>()
                            .setProductModel(model);
                        Routes.navigateToReviewGallaryScreen(context);
                      } else {
                        context
                            .read<ReviewPreviewProvider>()
                            .setProductModel(model);
                        context.read<ReviewPreviewProvider>().setIndex(index);
                        Routes.navigateToReviewPreviewScreen(context);
                      }
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          child: DesignConfiguration.getCacheNotworkImage(
                            boxFit: BoxFit.cover,
                            context: context,
                            heightvalue: 45.0,
                            widthvalue: 45.0,
                            placeHolderSize: 45.0,
                            imageurlString: context
                                .read<ProductDetailProvider>()
                                .reviewImgList[index]
                                .img!,
                          ),
                        ),
                        index == 5
                            ? Container(
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: colors.black54,
                                ),
                                height: 45.0,
                                width: 45.0,
                                child: Center(
                                  child: Text(
                                    '+${context.read<ProductDetailProvider>().reviewImgList.length - 6}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Container();
  }
}

class ReviewPart extends StatelessWidget {
  int? secPos;
  int? widgetindex;
  ReviewPart({Key? key, this.secPos, this.widgetindex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return context.read<ProductDetailProvider>().isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            itemCount:
                context.read<ProductDetailProvider>().reviewList.length >= 2
                    ? 2
                    : context.read<ProductDetailProvider>().reviewList.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Color(0xff048d63),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context
                                          .read<ProductDetailProvider>()
                                          .reviewList[index]
                                          .rating ??
                                      '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Ubuntu',
                                      fontStyle: FontStyle.normal,
                                      fontSize: 16.0),
                                ),
                                const Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                      .read<ProductDetailProvider>()
                                      .reviewList[index]
                                      .comment ??
                                  '',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Ubuntu',
                                fontStyle: FontStyle.normal,
                                fontSize: 14.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context
                                            .read<ProductDetailProvider>()
                                            .reviewList[index]
                                            .username ??
                                        '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Ubuntu',
                                        fontStyle: FontStyle.normal,
                                        fontSize: 12.0),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Ubuntu',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5),
                                    child: Text(
                                      context
                                          .read<ProductDetailProvider>()
                                          .reviewList[index]
                                          .date!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .lightBlack
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Ubuntu',
                                          fontStyle: FontStyle.normal,
                                          fontSize: 12.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  ReviewImagesWidget(
                    i: index,
                    secPos: secPos,
                    index: widgetindex,
                  ),
                ],
              );
            },
          );
  }
}

class ReviewImagesWidget extends StatelessWidget {
  int i;
  int? secPos;
  int? index;
  ReviewImagesWidget({Key? key, required this.i, this.index, this.secPos})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: SizedBox(
        height: context
                .read<ProductDetailProvider>()
                .reviewList[i]
                .imgList!
                .isNotEmpty
            ? 60
            : 0,
        child: ListView.builder(
          itemCount: context
              .read<ProductDetailProvider>()
              .reviewList[i]
              .imgList!
              .length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 5,
              ),
              child: InkWell(
                onTap: () {
                  context.read<ProductPreviewProvider>().posData(index);
                  context.read<ProductPreviewProvider>().secPosData(secPos);
                  context.read<ProductPreviewProvider>().indexData(index);
                  context.read<ProductPreviewProvider>().idData(
                      '$index${context.read<ProductDetailProvider>().reviewList[i].id}');
                  context.read<ProductPreviewProvider>().imgListData(context
                      .read<ProductDetailProvider>()
                      .reviewList[i]
                      .imgList);
                  context.read<ProductPreviewProvider>().listData(true);
                  context.read<ProductPreviewProvider>().fromData(false);
                  Routes.navigateToProductPreviewScreen(context);
                },
                child: Hero(
                  tag:
                      '$index${context.read<ProductDetailProvider>().reviewList[i].id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    child: DesignConfiguration.getCacheNotworkImage(
                      boxFit: BoxFit.cover,
                      context: context,
                      heightvalue: 45.0,
                      widthvalue: 45.0,
                      placeHolderSize: 45.0,
                      imageurlString: context
                          .read<ProductDetailProvider>()
                          .reviewList[i]
                          .imgList![index],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
