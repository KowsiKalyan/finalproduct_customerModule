import 'dart:core';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';
import '../Model/Notification_Model.dart';

class NotificationRepository {
  ///This method is used to getNotifi
  static Future<Map<String, dynamic>> fetchNotification({
    required Map<String, dynamic> parameter,
  }) async {
    try {
      var notificationList =
          await ApiBaseHelper().postAPICall(getNotificationApi, parameter);

      return {
        'totalNoti': notificationList['total'].toString(),
        'notiList': (notificationList['data'] as List)
            .map((NotifiData) => (NotificationModel.fromJson(NotifiData)))
            .toList()
      };
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
