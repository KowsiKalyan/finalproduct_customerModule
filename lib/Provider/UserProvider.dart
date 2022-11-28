import 'dart:io';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/repository/userRepository.dart';
import 'package:flutter/material.dart';

import '../Helper/String.dart';

enum UserStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
  isMoreLoading,
}

class UserProvider extends ChangeNotifier {
  UserStatus _userStatus = UserStatus.initial;
  String errorMessage = '';
  String _userName = '',
      _cartCount = '',
      _curBal = '',
      _mob = '',
      _profilePic = '',
      _email = '';
  String? _userId = '';

  String? _curPincode = '';

  late SettingProvider settingsProvider;

  String get curUserName => _userName;

  String get curPincode => _curPincode ?? '';

  String get curCartCount => _cartCount;

  String get curBalance => _curBal;

  String get mob => _mob;

  String get profilePic => _profilePic;

  String? get userId => _userId;

  String get email => _email;

  void setPincode(String pin) {
    _curPincode = pin;
    notifyListeners();
  }

  void setCartCount(String count) {
    _cartCount = count;
    notifyListeners();
  }

  void setBalance(String bal) {
    _curBal = bal;
    notifyListeners();
  }

  void setName(String count) {
    _userName = count;
    notifyListeners();
  }

  void setMobile(String count) {
    _mob = count;
    notifyListeners();
  }

  void setProfilePic(String count) {
    _profilePic = count;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUserId(String? count) {
    _userId = count;
  }

  UserStatus get userStatus => _userStatus;

  changeStatus(UserStatus status) {
    _userStatus = status;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateUserProfile(
      {required String userID,
      oldPassword,
      newPassword,
      username,
      userEmail}) async {
    try {
      changeStatus(UserStatus.inProgress);
      Map result = await UserRepository.updateUser(
          userID: userID,
          newPwd: newPassword,
          oldPwd: oldPassword,
          userEmail: userEmail,
          username: username);
      changeStatus(UserStatus.isSuccsess);
      return {'error': result['error'], 'message': result['message']};
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(UserStatus.isFailure);
      return {'error': true, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUserProfilePicture(
      {required File image}) async {
    try {
      changeStatus(UserStatus.inProgress);
      Map result = await UserRepository.updateUserProfilePicture(
        image: image,
      );

      changeStatus(UserStatus.isSuccsess);
      return {
        'error': result['error'],
        'message': result['message'],
        'data': result['data']
      };
    } catch (e) {
      errorMessage = e.toString();
      changeStatus(UserStatus.isFailure);
      return {
        'error': true,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteUserAccount({
    required String userId,
    required String mobileNumber,
    required String password,
  }) async {
    try {
      var parameter = {
        USER_ID: userId,
        MOBILE: mobileNumber,
        PASSWORD: password
      };

      await UserRepository.deleteUserAccount(parameter: parameter).then(
        (value) {
          return value['error'];
        },
      );
    } catch (e) {
      return {
        'error': true,
        'message': e.toString(),
      };
    }
    return {
      'error': true,
      'message': 'Something went Wrong',
    };
  }
}
