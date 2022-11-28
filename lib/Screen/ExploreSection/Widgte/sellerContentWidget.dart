import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/Constant.dart';
import '../../../Helper/routes.dart';
import '../../../Model/Section_Model.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';
import '../../../widgets/star_rating.dart';
import '../explore.dart';

class ShowContentOfSellers extends StatelessWidget {
  List<Product> sellerList;
  ShowContentOfSellers({Key? key, required this.sellerList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return sellerList.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            controller: sellerListController,
            itemCount: sellerList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.white,
                  child: ListTile(
                    title: Text(
                      sellerList[index].store_name!,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Theme.of(context).colorScheme.lightBlack,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ubuntu',
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: StarRating(
                              noOfRatings:
                                  sellerList[index].noOfRatingsOnSeller!,
                              totalRating: sellerList[index].seller_rating!,
                              needToShowNoOfRatings: false),
                        ),
                        Text(
                          '| ${sellerList[index].totalProductsOfSeller} ${getTranslated(context, 'PRODUCTS')} ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            fontSize: textFontSize14,
                            fontFamily: 'ubuntu',
                          ),
                        ),
                      ],
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child: sellerList[index].seller_profile == ''
                          ? Image.asset(
                              DesignConfiguration.setPngPath('placeholder'),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : DesignConfiguration.getCacheNotworkImage(
                              context: context,
                              boxFit: BoxFit.cover,
                              heightvalue: 50,
                              widthvalue: 50,
                              placeHolderSize: 50,
                              imageurlString: sellerList[index].seller_profile!,
                            ),
                    ),
                    trailing: Container(
                      width: 80,
                      height: 35,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(3.0, 0, 3.0, 0),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: colors.primary),
                        borderRadius:
                            BorderRadius.circular(circularBorderRadius10),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, 'VIEW_STORE')!,
                          style: const TextStyle(
                            color: colors.primary,
                            fontFamily: 'ubuntu',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ),
                    ),
                    onTap: () async {
                      Routes.navigateToSellerProfileScreen(
                        context,
                        sellerList[index].seller_id!,
                        sellerList[index].seller_profile!,
                        sellerList[index].seller_name!,
                        sellerList[index].seller_rating!,
                        sellerList[index].store_name!,
                        sellerList[index].store_description!,
                        sellerList[index].totalProductsOfSeller,
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Selector<HomePageProvider, bool>(
            builder: (context, data, child) {
              return !data
                  ? Center(
                      child: Text(
                        getTranslated(context, 'No Seller/Store Found')!,
                        style: const TextStyle(
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    )
                  : Container();
            },
            selector: (_, provider) => provider.sellerLoading,
          );
  }
}
