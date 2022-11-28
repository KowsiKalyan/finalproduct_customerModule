import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Screen/Product Detail/productDetail.dart';
import '../repository/productListRespository.dart';
import '../repository/pushnotificationRepositry.dart';
import 'SettingProvider.dart';

class PushNotificationProvider extends ChangeNotifier {
  void registerToken(String? token, BuildContext context) async {
    SettingProvider settingsProvider =
         Provider.of<SettingProvider>(context, listen: false);
    var parameter = {
      USER_ID: settingsProvider.userId,
      FCM_ID: token,
    };
    await NotificationRepository.updateFcmID(parameter: parameter);
  }

  Future<void> getProduct(
      String id, int index, int secPos, bool list, BuildContext context) async {
    try {
      var parameter = {
        ID: id,
      };

      var result = await ProductListRepository.getList(parameter: parameter);

      bool error = result['error'];
      if (!error) {
        var data = result['data'];

        List<Product> items = [];

        items = (data as List).map((data) => Product.fromJson(data)).toList();
        currentHero = notifyHero;
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductDetail(
              index: int.parse(id),
              model: items[0],
              secPos: secPos,
              list: list,
            ),
          ),
        );
      } else {}
    } on Exception {}
  }
}
