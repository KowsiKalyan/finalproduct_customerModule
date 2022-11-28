import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/User.dart';
import '../repository/addressRepositry.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/snackbar.dart';
import 'CartProvider.dart';
import 'SettingProvider.dart';

class AddressProvider extends ChangeNotifier {
  String? latitude,
      longitude,
      state,
      name,
      type = 'Home',
      mobile,
      city,
      address,
      pincode,
      landmark,
      altMob,
      area,
      country,
      selectedCity = '',
      selectedArea = '';
  int areaOffset = 0;
  int? selCityPos = -1;
  bool cityLoading = true;
  bool checkedDefault = false;
  bool? isLoadingMoreCity;
  bool isProgress = false;
  List<User> areaSearchList = [];
  List<User> areaList = [];
  AnimationController? buttonController;
  List<User> citySearchLIst = [];
  List<User> cityList = [];
  User? selArea;
  int? selAreaPos = -1;
  bool? isLoadingMoreArea;
  StateSetter? areaState;
  StateSetter? cityState;
  bool areaLoading = true;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  TextEditingController? pincodeC;
  bool isArea = false;
  int cityOffset = 0;
  setLatitude(String? value) {
    latitude = value;
    notifyListeners();
  }

  setLongitude(String? value) {
    longitude = value;
    notifyListeners();
  }

  setStateValue(String? value) {
    state = value;
    notifyListeners();
  }

  setCountry(String? value) {
    country = value;
    notifyListeners();
  }

  Future<void> getArea(
    String? city,
    bool clear,
    bool isSearchArea,
    BuildContext context,
    Function setStateNow,
    bool? update,
  ) async {
    try {
      var parameter = {
        ID: city,
        OFFSET: areaOffset.toString(),
        LIMIT: perPage.toString()
      };

      if (isSearchArea) {
        parameter[SEARCH] = areaController.text;
        parameter[OFFSET] = '0';
        areaSearchList.clear();
      }
      dynamic result = await AddressRepository.getArea(parameter: parameter);

      bool error = result['error'];
      String? msg = result['message'];

      if (!error) {
        var data = result['data'];
        areaList.clear();
        if (clear) {
          area = null;
          selArea = null;
        }
        areaList = (data as List).map((data) => User.fromJson(data)).toList();

        areaSearchList.addAll(areaList);

        if (update!) {
          for (User item in context.read<CartProvider>().addressList) {
            for (int i = 0; i < areaSearchList.length; i++) {
              if (areaSearchList[i].id == item.areaId) {
                selArea = areaSearchList[i];
                selAreaPos = i;
                selectedArea = areaSearchList[selAreaPos!].name!;
              }
            }
          }
        }
      } else {
        if (msg != null) {
          setSnackbar(msg, context);
        }
      }
      areaLoading = false;
      isLoadingMoreArea = false;
      areaOffset += perPage;
      if (areaState != null) {
        areaState!(
          () {},
        );
      }
      isArea = true;
      setStateNow();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> getCities(
    bool isSearchCity,
    BuildContext context,
    Function updateNow,
    bool? update,
    int? index,
  ) async {
    try {
      var parameter = {
        LIMIT: perPage.toString(),
        OFFSET: cityOffset.toString(),
      };

      if (isSearchCity) {
        parameter[SEARCH] = cityController.text;
        parameter[OFFSET] = '0';
        citySearchLIst.clear();
      }
      dynamic result = await AddressRepository.getCitys(
        parameter: parameter,
      );

      bool error = result['error'];
      String? msg = result['message'];
      if (!error) {
        var data = result['data'];
        cityList = (data as List).map((data) => User.fromJson(data)).toList();
        citySearchLIst.addAll(cityList);
      } else {
        if (msg != null) {
          setSnackbar(msg, context);
        }
      }
      cityLoading = false;
      isLoadingMoreCity = false;
      isProgress = false;
      cityOffset += perPage;
      if (cityState != null) cityState!(() {});
      updateNow();
      if (update!) {
        selCityPos = citySearchLIst.indexWhere((f) =>
            f.id == context.read<CartProvider>().addressList[index!].cityId);

        if (selCityPos == -1) {
          selCityPos = null;
        }
        selectedCity = citySearchLIst[selCityPos!].name!;
      }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> addNewAddress(
    BuildContext context,
    Function updateNow,
    bool? update,
    int index,
  ) async {
    isProgress = true;
    updateNow();
    try {
      var parameter = {
        USER_ID: context.read<SettingProvider>().userId,
        NAME: name,
        MOBILE: mobile,
        PINCODE: pincodeC!.text,
        CITY_ID: city,
        AREA_ID: area,
        ADDRESS: address,
        STATE: state,
        COUNTRY: country,
        TYPE: type,
        ISDEFAULT: checkedDefault.toString() == 'true' ? '1' : '0',
        LATITUDE: latitude,
        LONGITUDE: longitude
      };
      if (update!) {
        parameter[ID] = context.read<CartProvider>().addressList[index].id;
      }

      dynamic result = await AddressRepository.addAndUpdateAddress(
        parameter: parameter,
        update: update,
      );
      bool error = result['error'];
      String? msg = result['message'];

      await buttonController!.reverse();

      if (!error) {
        var data = result['data'];

        if (update) {
          if (checkedDefault.toString() == 'true' ||
              context.read<CartProvider>().addressList.length == 1) {
            for (User i in context.read<CartProvider>().addressList) {
              i.isDefault = '0';
            }

            context.read<CartProvider>().addressList[index].isDefault = '1';

            if (!ISFLAT_DEL) {
              if (context.read<CartProvider>().oriPrice <
                  double.parse(context
                      .read<CartProvider>()
                      .addressList[
                          context.read<CartProvider>().selectedAddress!]
                      .freeAmt!)) {
                context.read<CartProvider>().deliveryCharge = double.parse(
                    context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .deliveryCharge!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }

              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().totalPrice -
                      context.read<CartProvider>().deliveryCharge;
            }

            User value = User.fromAddress(data[0]);

            context.read<CartProvider>().addressList[index] = value;

            context.read<CartProvider>().selectedAddress = index;
            context.read<CartProvider>().selAddress =
                context.read<CartProvider>().addressList[index].id;

            if (!ISFLAT_DEL) {
              if (context.read<CartProvider>().oriPrice <
                  double.parse(context
                      .read<CartProvider>()
                      .addressList[
                          context.read<CartProvider>().selectedAddress!]
                      .freeAmt!)) {
                context.read<CartProvider>().deliveryCharge = double.parse(
                    context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .deliveryCharge!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().totalPrice +
                      context.read<CartProvider>().deliveryCharge;
            }
          }
        } else {
          User value = User.fromAddress(data[0]);
          context.read<CartProvider>().addressList.add(value);

          if (checkedDefault.toString() == 'true' ||
              context.read<CartProvider>().addressList.length == 1) {
            for (User i in context.read<CartProvider>().addressList) {
              i.isDefault = '0';
            }

            context.read<CartProvider>().addressList[index].isDefault = '1';

            if (!ISFLAT_DEL &&
                context.read<CartProvider>().addressList.length != 1) {
              if (context.read<CartProvider>().oriPrice <
                  double.parse(context
                      .read<CartProvider>()
                      .addressList[
                          context.read<CartProvider>().selectedAddress!]
                      .freeAmt!)) {
                context.read<CartProvider>().deliveryCharge = double.parse(
                    context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .deliveryCharge!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }

              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().totalPrice -
                      context.read<CartProvider>().deliveryCharge;
            }

            context.read<CartProvider>().selectedAddress = index;
            context.read<CartProvider>().selAddress =
                context.read<CartProvider>().addressList[index].id;

            if (!ISFLAT_DEL) {
              if (context.read<CartProvider>().totalPrice <
                  double.parse(context
                      .read<CartProvider>()
                      .addressList[
                          context.read<CartProvider>().selectedAddress!]
                      .freeAmt!)) {
                context.read<CartProvider>().deliveryCharge = double.parse(
                    context
                        .read<CartProvider>()
                        .addressList[
                            context.read<CartProvider>().selectedAddress!]
                        .deliveryCharge!);
              } else {
                context.read<CartProvider>().deliveryCharge = 0;
              }
              context.read<CartProvider>().totalPrice =
                  context.read<CartProvider>().totalPrice +
                      context.read<CartProvider>().deliveryCharge;
            }
          }
        }
        isProgress = false;
        updateNow();

        Navigator.of(context).pop();
      } else {
        setSnackbar(msg!, context);
      }
    } on TimeoutException catch (_) {
      setSnackbar(
        getTranslated(context, 'somethingMSg')!,
        context,
      );
    }
  }
}
