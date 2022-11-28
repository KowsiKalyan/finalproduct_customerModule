import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Product%20Detail/productDetail.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/SectionList.dart';
import 'package:eshop_multivendor/Screen/SubCategory/SubCategory.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/offerImage.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/singleProductContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Helper/String.dart';
import '../../Language/languageSettings.dart';

class Section extends StatelessWidget {
  Section({Key? key}) : super(key: key);
  var provider = HomePageProvider();

  @override
  Widget build(BuildContext context) {
    return Selector<HomePageProvider, bool>(
      builder: (context, isLoading, child) {
        return isLoading || supportedLocale == null
            ? CircularProgressIndicator()
            : ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: context.read<HomePageProvider>().sectionList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return SingleSection(
                    index: index,
                    from: 1,
                    sectionTitle: context
                            .read<HomePageProvider>()
                            .sectionList[index]
                            .title ??
                        '',
                    sectionStyle: context
                            .read<HomePageProvider>()
                            .sectionList[index]
                            .style ??
                        '',
                    sectionSubTitle: context
                            .read<HomePageProvider>()
                            .sectionList[index]
                            .shortDesc ??
                        '',
                    productList: context
                            .read<HomePageProvider>()
                            .sectionList[index]
                            .productList ??
                        [],
                    wantToShowOfferImageBelowSection: true,
                  );
                },
              );
      },
      selector: (_, homePageProvider) => homePageProvider.secLoading,
    );
  }

  static Widget sectionLoadingShimmer(BuildContext context) {
    return Column(
      children: [0, 1, 2, 3, 4]
          .map(
            (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: double.infinity,
                            height: 18.0,
                            color: Theme.of(context).colorScheme.white,
                          ),
                          GridView.count(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 1.0,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            children: List.generate(
                              6,
                              (index) {
                                return Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Theme.of(context).colorScheme.white,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    height: (deviceWidth! / 2),
                    color: Theme.of(context).colorScheme.white,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class SectionHeadingContainer extends StatelessWidget {
  final String title;
  final String subTitle;
  final int index;
  final List<Product> productList;

  const SectionHeadingContainer({
    Key? key,
    required this.title,
    required this.index,
    required this.subTitle,
    required this.productList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 15.0,
        top: 5.0,
        left: 15.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontFamily: 'ubuntu',
              fontSize: textFontSize16,
              color: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  subTitle,
                  style: const TextStyle(
                    fontSize: textFontSize12,
                    fontFamily: 'ubuntu',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  child: Text(
                    getTranslated(context, 'Show All')!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize12,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                  onTap: () {
                    SectionModel model =
                        context.read<HomePageProvider>().sectionList[index];

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => SectionList(
                          index: index,
                          section_model: model,
                          from: title ==
                                  getTranslated(context, 'You might also like')!
                              ? 2
                              : 1,
                          productList: productList,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}

class SingleSection extends StatelessWidget {
  final int index;
  final String sectionTitle;
  final String sectionSubTitle;
  final String sectionStyle;
  final int from;
  final List<Product> productList;
  final bool wantToShowOfferImageBelowSection;

  const SingleSection({
    Key? key,
    required this.index,
    required this.productList,
    required this.from,
    required this.sectionTitle,
    required this.sectionSubTitle,
    required this.sectionStyle,
    required this.wantToShowOfferImageBelowSection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return productList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SectionHeadingContainer(
                      title: sectionTitle,
                      index: index,
                      subTitle: sectionSubTitle,
                      productList: productList,
                    ),
                    SingleSectionContainer(
                      index: index,
                      productList: productList,
                      sectionStyle: sectionStyle,
                    ),
                  ],
                ),
              ),
              context.read<HomePageProvider>().offerImagesList.length > index &&
                      wantToShowOfferImageBelowSection
                  ? Padding(
                      padding:
                          const EdgeInsets.only(top: 20, right: 10, left: 10),
                      child: OfferImage(
                        offerImage: context
                            .read<HomePageProvider>()
                            .offerImagesList[index]
                            .image!,
                        onOfferClick: () {
                          _onOfferImageClick(
                              context,
                              context
                                  .read<HomePageProvider>()
                                  .offerImagesList[index]);
                        },
                        placeHolderAssetImage: 'sliderph',
                      ),
                    )
                  : Container(),
            ],
          )
        : Container();
  }

  _onOfferImageClick(BuildContext context, Model offerImageData) {
    if (offerImageData.type == 'products') {
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetail(
                model: offerImageData.list, secPos: 0, index: 0, list: true)),
      );
    } else if (offerImageData.type == 'categories') {
      Product item = offerImageData.list;
      if (item.subList == null || item.subList!.isEmpty) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ProductList(
              name: item.name,
              id: item.id,
              tag: false,
              fromSeller: false,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => SubCategory(
              title: item.name!,
              subList: item.subList,
            ),
          ),
        );
      }
    }
  }
}

class SingleSectionContainer extends StatelessWidget {
  final int index;
  final List<Product> productList;
  final String sectionStyle;

  const SingleSectionContainer(
      {Key? key,
      required this.index,
      required this.productList,
      required this.sectionStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("sectionStyle : $sectionStyle");
    var orient = MediaQuery.of(context).orientation;

    return productList.isNotEmpty
        ? sectionStyle == DEFAULT
            ? Padding(
                padding: const EdgeInsets.only(top: 20, right: 10, left: 10),
                child: GridView.count(
                  padding: const EdgeInsetsDirectional.only(top: 5),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 0.750,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    productList.length < 4 ? productList.length : 4,
                    (productIndex) {
                      return SingleProductContainer(
                        sectionPosition: index,
                        index: productIndex,
                        pictureFlex: 10,
                        textFlex: 8,
                        productDetails: productList[productIndex],
                        length: productList.length,
                        showDiscountAtSameLine: false,
                      );
                    },
                  ),
                ),
              )
            : sectionStyle == STYLE1
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: 20, right: 10, left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: SizedBox(
                            height: orient == Orientation.portrait
                                ? deviceHeight! * 0.6
                                : deviceHeight!,
                            child: SingleProductContainer(
                              sectionPosition: index,
                              index: 0,
                              pictureFlex: 14,
                              textFlex: 3,
                              productDetails: productList[0],
                              length: productList.length,
                              showDiscountAtSameLine: true,
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                productList.length < 2
                                    ? Container()
                                    : SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.2975
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                          index: 1,
                                          pictureFlex: 5,
                                          textFlex: 4,
                                          productDetails: productList[1],
                                          length: productList.length,
                                          showDiscountAtSameLine: false,
                                        ),
                                      ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: productList.length < 3
                                        ? Container()
                                        : SizedBox(
                                            height:
                                                orient == Orientation.portrait
                                                    ? deviceHeight! * 0.2975
                                                    : deviceHeight! * 0.6,
                                            child: SingleProductContainer(
                                              sectionPosition: index,
                                              index: 2,
                                              pictureFlex: 5,
                                              textFlex: 4,
                                              productDetails: productList[2],
                                              length: productList.length,
                                              showDiscountAtSameLine: false,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : sectionStyle == STYLE2
                    ? Padding(
                        padding:
                            const EdgeInsets.only(top: 20, right: 10, left: 10),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.2975
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                          index: 0,
                                          pictureFlex: 5,
                                          textFlex: 4,
                                          productDetails: productList[0],
                                          length: productList.length,
                                          showDiscountAtSameLine: false,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: productList.length < 2
                                            ? Container()
                                            : SizedBox(
                                                height: orient ==
                                                        Orientation.portrait
                                                    ? deviceHeight! * 0.2975
                                                    : deviceHeight! * 0.6,
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 1,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[1],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              fit: FlexFit.loose,
                              child: productList.length < 3
                                  ? Container()
                                  : SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.6
                                          : deviceHeight!,
                                      child: SingleProductContainer(
                                        sectionPosition: index,
                                        index: 2,
                                        pictureFlex: 10,
                                        textFlex: 2,
                                        productDetails: productList[2],
                                        length: productList.length,
                                        showDiscountAtSameLine: true,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      )
                    : sectionStyle == STYLE3
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 20,
                              right: 10,
                              left: 10,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.loose,
                                  child: SizedBox(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.3
                                        : deviceHeight! * 0.6,
                                    child: SingleProductContainer(
                                      sectionPosition: index,
                                      index: 0,
                                      pictureFlex: 7,
                                      textFlex: 4,
                                      productDetails: productList[0],
                                      length: productList.length,
                                      showDiscountAtSameLine: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.3
                                      : deviceHeight! * 0.6,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 2
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 1,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[1],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 3
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 2,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[2],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.loose,
                                        child: productList.length < 4
                                            ? Container()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: SingleProductContainer(
                                                  sectionPosition: index,
                                                  index: 3,
                                                  pictureFlex: 5,
                                                  textFlex: 4,
                                                  productDetails:
                                                      productList[3],
                                                  length: productList.length,
                                                  showDiscountAtSameLine: false,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : sectionStyle == STYLE4
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 10, left: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.3
                                            : deviceHeight! * 0.6,
                                        child: SingleProductContainer(
                                          sectionPosition: index,
                                          index: 0,
                                          pictureFlex: 7,
                                          textFlex: 4,
                                          productDetails: productList[0],
                                          length: productList.length,
                                          showDiscountAtSameLine: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: orient == Orientation.portrait
                                          ? deviceHeight! * 0.3
                                          : deviceHeight! * 0.6,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: productList.length < 2
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 5,
                                                      top: 5,
                                                    ),
                                                    child:
                                                        SingleProductContainer(
                                                      sectionPosition: index,
                                                      index: 1,
                                                      pictureFlex: 5,
                                                      textFlex: 4,
                                                      productDetails:
                                                          productList[1],
                                                      length:
                                                          productList.length,
                                                      showDiscountAtSameLine:
                                                          false,
                                                    ),
                                                  ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.loose,
                                            child: productList.length < 3
                                                ? Container()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 5,
                                                    ),
                                                    child:
                                                        SingleProductContainer(
                                                      sectionPosition: index,
                                                      index: 2,
                                                      pictureFlex: 5,
                                                      textFlex: 4,
                                                      productDetails:
                                                          productList[2],
                                                      length:
                                                          productList.length,
                                                      showDiscountAtSameLine:
                                                          false,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: GridView.count(
                                  padding:
                                      const EdgeInsetsDirectional.only(top: 5),
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  childAspectRatio: 1.2,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 0,
                                  crossAxisSpacing: 0,
                                  children: List.generate(
                                    productList.length < 6
                                        ? productList.length
                                        : 6,
                                    (index) {
                                      return SingleProductContainer(
                                        sectionPosition: index,
                                        index: index,
                                        pictureFlex: 1,
                                        textFlex: 1,
                                        productDetails: productList[index],
                                        length: productList.length,
                                        showDiscountAtSameLine: false,
                                      );
                                    },
                                  ),
                                ),
                              )
        : Container();
  }
}
