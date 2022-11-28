import '../Helper/ApiBaseHelper.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class NotificationRepository {
  //
  static Future<Map<String, dynamic>> updateFcmID({
    required var parameter,
  }) async {
    try {
      var responseData = await ApiBaseHelper().postAPICall(
        updateFcmApi,
        parameter,
      );

      return responseData;
    } on Exception catch (e) {
      throw ApiException('$errorMesaage${e.toString()}');
    }
  }
}
