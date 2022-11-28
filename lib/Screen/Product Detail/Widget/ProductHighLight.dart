import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import '../../../Model/Section_Model.dart';

class ProductHighLightsDetail extends StatelessWidget {
  Product? model;
  Function update;
  ProductHighLightsDetail({Key? key, this.model, required this.update})
      : super(key: key);

  _desc(Product? model) {
    return model!.desc != '' && model.desc != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Html(
              data: model.desc,
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
                            getTranslated(context, 'Product Highlights')!,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _desc(model),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
