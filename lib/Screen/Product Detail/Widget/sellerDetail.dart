import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../Provider/productDetailProvider.dart';
import '../../../Provider/sellerDetailProvider.dart';
import '../../Language/languageSettings.dart';

class SellerDetail extends StatelessWidget {
  Product? model;
  SellerDetail({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0),
      color: Theme.of(context).colorScheme.white,
      child: InkWell(
        onTap: () async {
          context
              .read<SellerDetailProvider>()
              .changeStatus(SellerDetailProviderStatus.isSuccsess);
          Routes.navigateToSellerProfileScreen(
            context,
            model!.seller_id!,
            model!.seller_profile!,
            model!.seller_name!,
            model!.seller_rating!,
            model!.store_name!,
            model!.store_description!,
            model!.totalProductsOfSeller,
          );
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: 8.0,
            top: 8.0,
            start: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    getTranslated(context, 'Seller Details')!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Ubuntu',
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    model!.store_name ?? '',
                    style: const TextStyle(
                      color: Color(0xfffc6a57),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Ubuntu',
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 30,
                color: Theme.of(context).colorScheme.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompareProduct extends StatelessWidget {
  Product? model;
  CompareProduct({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 5.0),
      color: Theme.of(context).colorScheme.white,
      child: InkWell(
        onTap: () {
          if (context.read<ProductDetailProvider>().compareList.length > 0 &&
              context
                  .read<ProductDetailProvider>()
                  .compareList
                  .contains(model)) {
            Routes.navigateToCompareListScreen(context);
          } else {
            context.read<ProductDetailProvider>().addCompareList(model!);
            Routes.navigateToCompareListScreen(context);
          }
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: 8.0,
            top: 8.0,
            start: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslated(context, 'COMPARE_PRO')!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.black,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Ubuntu',
                  fontStyle: FontStyle.normal,
                  fontSize: 16.0,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 30,
                color: Theme.of(context).colorScheme.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
