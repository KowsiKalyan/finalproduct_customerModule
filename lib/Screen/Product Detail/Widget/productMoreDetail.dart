import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import '../../../Helper/String.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../Language/languageSettings.dart';

class ProductMoreDetail extends StatelessWidget {
  Product? model;
  Function update;
  ProductMoreDetail({Key? key, this.model, required this.update})
      : super(key: key);

  _desc(Product? model) {
    return model!.shortDescription != '' && model.shortDescription != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Html(
              data: model.shortDescription,
              onLinkTap: (String? url, RenderContext context,
                  Map<String, String> attributes, dom.Element? element) async {
                if (await canLaunchUrl(Uri.parse(url!))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.platformDefault,
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          )
        : Container();
  }

  _attr(Product? model) {
    return model!.attributeList!.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.attributeList!.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 25.0,
                    top: 10.0,
                    bottom: model.madein != '' && model.madein!.isNotEmpty
                        ? 0.0
                        : 7.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        model.attributeList![i].name!,
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.7),
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 5.0),
                        child: Text(
                          model.attributeList![i].value!,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : Container();
  }

  _madeIn(Product? model, BuildContext context) {
    String? madeIn = model!.madein;

    return madeIn != '' && madeIn!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              trailing: Text(madeIn),
              dense: true,
              title: Text(
                getTranslated(context, 'MADE_IN')!,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return model!.attributeList!.isNotEmpty ||
            (model!.desc != '' && model!.desc != null) ||
            model!.madein != '' && model!.madein!.isNotEmpty
        ? Container(
            color: Theme.of(context).colorScheme.white,
            padding: const EdgeInsets.only(top: 10.0),
            child: InkWell(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 15.0,
                      end: 15.0,
                      bottom: 15,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            getTranslated(context, 'Product Details')!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Ubuntu',
                                fontStyle: FontStyle.normal,
                                fontSize: 16.0,
                                color:
                                    Theme.of(context).colorScheme.lightBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                  !context.read<ProductDetailProvider>().seeView
                      ? SizedBox(
                          height: 100,
                          width: deviceWidth! - 10,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _desc(model),
                                model!.desc != '' && model!.desc != null
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                        child: Divider(
                                          height: 3.0,
                                        ),
                                      )
                                    : Container(),
                                _attr(model),
                                model!.madein != '' && model!.madein!.isNotEmpty
                                    ? const Divider()
                                    : Container(),
                                _madeIn(model, context),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _desc(model),
                              model!.desc != '' && model!.desc != null
                                  ? const Divider(
                                      height: 3.0,
                                    )
                                  : Container(),
                              _attr(model),
                              model!.madein != '' && model!.madein!.isNotEmpty
                                  ? const Divider()
                                  : Container(),
                              _madeIn(model, context),
                            ],
                          ),
                        ),
                  Row(
                    children: [
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 15, top: 10, end: 2, bottom: 15),
                          child: Text(
                            !context.read<ProductDetailProvider>().seeView
                                ? getTranslated(context, 'See More')!
                                : getTranslated(context, 'See Less')!,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Ubuntu',
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14.0),
                          ),
                        ),
                        onTap: () {
                          context.read<ProductDetailProvider>().seeView =
                              !context.read<ProductDetailProvider>().seeView;

                          update();
                        },
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
