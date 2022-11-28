import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import '../../../Helper/String.dart';
import '../ProductList.dart' as Plist;
import '../SectionList.dart';

class PriceRangeValueWidget extends StatelessWidget {
  String minPrice;
  String maxPrice;
  bool fromList;
  Function setState;
  PriceRangeValueWidget({
    Key? key,
    required this.fromList,
    required this.maxPrice,
    required this.minPrice,
    required this.setState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: deviceWidth,
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                getTranslated(context, 'Price Range')!,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.normal),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
        RangeSlider(
          values: fromList ? Plist.currentRangeValues! : currentRangeValues!,
          min: double.parse(minPrice),
          max: double.parse(maxPrice),
          divisions: 10,
          labels: RangeLabels(
            fromList
                ? Plist.currentRangeValues!.start.round().toString()
                : currentRangeValues!.start.round().toString(),
            fromList
                ? Plist.currentRangeValues!.end.round().toString()
                : currentRangeValues!.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            fromList
                ? Plist.currentRangeValues = values
                : currentRangeValues = values;
            setState();
          },
        ),
      ],
    );
  }
}
