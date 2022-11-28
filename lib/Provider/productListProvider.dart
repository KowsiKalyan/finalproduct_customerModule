import 'dart:async';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/ApiBaseHelper.dart';
import '../Model/Section_Model.dart';
import '../repository/productListRespository.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/networkAvailablity.dart';
import '../widgets/snackbar.dart';
import 'Favourite/FavoriteProvider.dart';

enum ProductListProviderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class ProductListProvider extends ChangeNotifier {
  ProductListProviderStatus _systemProviderPolicyStatus =
      ProductListProviderStatus.initial;
  // ======================= parameter for List Product ================

  var productListParameter = {};

  setProductListParameter(value) {
    productListParameter = value;

    notifyListeners();
  }
  // ======================= parameter for List Product ================

  var sectionListParameter = {};

  setSectionListParameter(value) {
    sectionListParameter = value;
    notifyListeners();
  }

  changeStatus(ProductListProviderStatus status) {
    _systemProviderPolicyStatus = status;
    notifyListeners();
  }

  // Product List call
  Future<Map<String, dynamic>> getProductList() async {
    try {
      changeStatus(ProductListProviderStatus.inProgress);

      var result =
          await ProductListRepository.getList(parameter: productListParameter);
      return result;
    } catch (e) {
      return {};
    }
  }

  // Product List call
  Future<Map<String, dynamic>> getSectionList() async {
    try {
      changeStatus(ProductListProviderStatus.inProgress);
      var result = await ProductListRepository.getSection(
          parameter: sectionListParameter);
      return result;
    } catch (e) {
      return {};
    }
  }

  removeFav(
    int index,
    BuildContext context,
    SectionModel? section_model,
    Function updateNow,
  ) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        section_model!.productList![index].isFavLoading = true;
        updateNow();

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: section_model.productList![index].id
        };
        ApiBaseHelper().postAPICall(removeFavApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            section_model.productList![index].isFav = '0';

            context.read<FavoriteProvider>().removeFavItem(
                section_model.productList![index].prVarientList![0].id!);
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }

          section_model.productList![index].isFavLoading = false;
          updateNow();
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      isNetworkAvail = false;
      updateNow();
    }
  }
}
