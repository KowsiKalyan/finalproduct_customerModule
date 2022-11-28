import 'dart:async';
import 'package:eshop_multivendor/repository/ManageAdressRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/User.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/snackbar.dart';
import 'CartProvider.dart';

enum ManageAddrProviderStatus {
  initial,
  inProgress,
  isSuccess,
  isFailure,
  isMoreLoading,
}

class ManageAddrProvider extends ChangeNotifier {
  ManageAddrProviderStatus _ManageAddrProviderStatus =
      ManageAddrProviderStatus.initial;

  String errorMessage = '';
  String policy = "";

  get getCurrentStatus => _ManageAddrProviderStatus;

  changeStatus(ManageAddrProviderStatus status) {
    _ManageAddrProviderStatus = status;
    notifyListeners();
  }

  Future<void> getAddress(BuildContext context) async {
    try {
      changeStatus(ManageAddrProviderStatus.inProgress);
      context.read<CartProvider>().addressList.clear();
      var parameter = {
        USER_ID: CUR_USERID,
      };

      Map<String, dynamic> result =
          await ManageAddrRepository.fetchAddress(parameter: parameter);
      List<User> tempList = [];

      (result['addressList'] as List).forEach(
        (element) {
          tempList.add(element);
        },
      );

      context.read<CartProvider>().addressList.addAll(tempList);

      for (int i = 0;
          i < context.read<CartProvider>().addressList.length;
          i++) {
        if (context.read<CartProvider>().addressList[i].isDefault == '1') {
          context.read<CartProvider>().selectedAddress = i;
          context.read<CartProvider>().selAddress =
              context.read<CartProvider>().addressList[i].id;
          if (!ISFLAT_DEL) {
            if (context.read<CartProvider>().totalPrice <
                double.parse(
                    context.read<CartProvider>().addressList[i].freeAmt!)) {
              context.read<CartProvider>().deliveryCharge = double.parse(
                  context.read<CartProvider>().addressList[i].deliveryCharge!);
            } else {
              context.read<CartProvider>().deliveryCharge = 0;
            }
          }
        }
      }
      changeStatus(ManageAddrProviderStatus.isSuccess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(ManageAddrProviderStatus.isFailure);
    }
  }

  Future<void> setAsDefault(int index, BuildContext context) async {
    try {
      changeStatus(ManageAddrProviderStatus.inProgress);
      var data = {
        USER_ID: CUR_USERID,
        ID: context.read<CartProvider>().addressList[index].id,
        ISDEFAULT: '1',
      };

      Map<String, dynamic> result =
          await ManageAddrRepository.updateAddress(parameter: data);

      bool error = result['error'];
      String? msg = result['msg'];

      if (!error) {
        for (User i in context.read<CartProvider>().addressList) {
          i.isDefault = '0';
        }
        context.read<CartProvider>().addressList[index].isDefault = '1';
      } else {
        setSnackbar(msg!, context);
      }

      changeStatus(ManageAddrProviderStatus.isSuccess);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> deleteAddress(int index, BuildContext context) async {
    try {
      changeStatus(ManageAddrProviderStatus.inProgress);
      var parameter = {
        ID: context.read<CartProvider>().addressList[index].id,
      };
      Map<String, dynamic> result =
          await ManageAddrRepository.deleteAddress(parameter: parameter);

      bool error = result['error'];
      String? msg = result['msg'];
      if (!error) {
        if (!ISFLAT_DEL) {
          if (context.read<CartProvider>().addressList.length != 1) {
            if (context.read<CartProvider>().oriPrice <
                double.parse(context
                    .read<CartProvider>()
                    .addressList[context.read<CartProvider>().selectedAddress!]
                    .freeAmt!)) {
              context.read<CartProvider>().deliveryCharge = double.parse(context
                  .read<CartProvider>()
                  .addressList[context.read<CartProvider>().selectedAddress!]
                  .deliveryCharge!);
            } else {
              context.read<CartProvider>().deliveryCharge = 0;
            }
            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice -
                    context.read<CartProvider>().deliveryCharge;

            context.read<CartProvider>().addressList.removeWhere((item) =>
                item.id == context.read<CartProvider>().addressList[index].id);
            context.read<CartProvider>().selectedAddress = 0;
            context.read<CartProvider>().selAddress =
                context.read<CartProvider>().addressList[0].id;

            if (context.read<CartProvider>().totalPrice <
                double.parse(context
                    .read<CartProvider>()
                    .addressList[context.read<CartProvider>().selectedAddress!]
                    .freeAmt!)) {
              context.read<CartProvider>().deliveryCharge = double.parse(context
                  .read<CartProvider>()
                  .addressList[context.read<CartProvider>().selectedAddress!]
                  .deliveryCharge!);
            } else {
              context.read<CartProvider>().deliveryCharge = 0;
            }

            context.read<CartProvider>().totalPrice =
                context.read<CartProvider>().totalPrice +
                    context.read<CartProvider>().deliveryCharge;
          } else {
            context.read<CartProvider>().addressList.removeWhere((item) =>
                item.id == context.read<CartProvider>().addressList[index].id);
            context.read<CartProvider>().selAddress = null;
          }
        } else {
          context.read<CartProvider>().addressList.removeWhere((item) =>
              item.id == context.read<CartProvider>().addressList[index].id);
          context.read<CartProvider>().selAddress = null;
        }
      } else {
        setSnackbar(msg!, context);
      }
      changeStatus(ManageAddrProviderStatus.isSuccess);
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }
}
