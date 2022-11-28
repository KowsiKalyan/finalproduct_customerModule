import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/ProductList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Model/Model.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../../Product Detail/productDetail.dart';
import '../../SubCategory/SubCategory.dart';

class CustomSlider extends StatefulWidget {
  CustomSlider({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  final _controller = PageController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    _animateSlider();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomePageProvider>(
      builder: (context, homeProvider, _) {
        return homeProvider.sliderLoading
            ? sliderLoading(context)
            : homeProvider.homeSliderList.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: PageView.builder(
                            itemCount: homeProvider.homeSliderList.length,
                            scrollDirection: Axis.horizontal,
                            controller: _controller,
                            physics: const AlwaysScrollableScrollPhysics(),
                            onPageChanged: (index) {
                              context
                                  .read<HomePageProvider>()
                                  .setCurSlider(index);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return buildImagePageItem(
                                homeProvider.homeSliderList[index],
                              );
                            },
                          ),
                        ),
                        _showSliderPosition()
                      ],
                    ),
                  );
      },
    );
  }

  static Widget sliderLoading(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = width / 2;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.white,
      ),
    );
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 1)).then(
      (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage ==
              context.read<HomePageProvider>().homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients) {
            _controller
                .animateToPage(
                  nextPage,
                  duration: const Duration(seconds: 3),
                  curve: Curves.linear,
                )
                .then(
                  (_) => _animateSlider(),
                );
          }
        }
      },
    );
  }

  Widget buildImagePageItem(Model slider) {
    double height = MediaQuery.of(context).size.width / 0.5;
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
          imageUrl: slider.image!,
          placeholder: (context, url) {
            return SvgPicture.asset(
              DesignConfiguration.setSvgPath('sliderph'),
              fit: BoxFit.fill,
              height: height,
              color: colors.primary,
            );
          },
          errorWidget: (context, error, stackTrace) {
            return SvgPicture.asset(
              DesignConfiguration.setSvgPath('sliderph'),
              fit: BoxFit.fill,
              height: height,
              color: colors.primary,
            );
          },
          fadeInCurve: Curves.linear,
          fadeOutCurve: Curves.linear,
          fadeInDuration: const Duration(
            milliseconds: 150,
          ),
          fadeOutDuration: const Duration(
            milliseconds: 150,
          ),
          fit: BoxFit.fill,
          height: height,
        ),
      ),
      onTap: () async {
        int curSlider = context.read<HomePageProvider>().curSlider;

        if (context.read<HomePageProvider>().homeSliderList[curSlider].type ==
            'products') {
          Product? item =
              context.read<HomePageProvider>().homeSliderList[curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ProductDetail(
                model: item,
                secPos: 0,
                index: 0,
                list: true,
              ),
            ),
          );
        } else if (context
                .read<HomePageProvider>()
                .homeSliderList[curSlider]
                .type ==
            'categories') {
          Product item =
              context.read<HomePageProvider>().homeSliderList[curSlider].list;
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
      },
    );
  }

  _showSliderPosition() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: map<Widget>(
          context.read<HomePageProvider>().homeSliderList,
          (index, url) {
            return Selector<HomePageProvider, int>(
              builder: (context, curSliderIndex, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: curSliderIndex == index ? 8.0 : 6.0,
                  height: curSliderIndex == index ? 8.0 : 6.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: curSliderIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.white,
                  ),
                );
              },
              selector: (_, slider) => slider.curSlider,
            );
          },
        ),
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(
        handler(i, list[i]),
      );
    }

    return result;
  }
}
