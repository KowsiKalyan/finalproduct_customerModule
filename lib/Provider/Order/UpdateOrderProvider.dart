import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshop_multivendor/repository/Order/UpdateOrderRepository.dart';
import 'package:flutter/material.dart';
import '../../Helper/String.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../../Screen/Language/languageSettings.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';

enum UpdateOrdStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class UpdateOrdProvider extends ChangeNotifier {
  UpdateOrdStatus _UpdateOrdStatus = UpdateOrdStatus.isSuccsess;
  String errorMessage = '';
  bool isReturnClick = true;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late TabController tabController;
  List<File> files = [];
  String updatedComment = '';
  List<File> reviewPhotos = [];
  double curRating = 0.0;
  TextEditingController commentTextController = TextEditingController();
  GlobalKey<FormState> commentTextFieldKey = GlobalKey<FormState>();

  get getCurrentStatus => _UpdateOrdStatus;

  // meesage of cancelation
  String? msg;

  changeStatus(UpdateOrdStatus status) {
    _UpdateOrdStatus = status;
    notifyListeners();
  }

  Future<void> cancelOrder(
      String ordId, Uri api, String status, BuildContext context) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var parameter = {ORDERID: ordId, STATUS: status};

      var result = await UpdateOrderRepository.cancelOrder(
          parameter: parameter, api: api);

      bool error = result['error'];
      setSnackbar(result['message'], context);
      if (!error) {
        Future.delayed(const Duration(seconds: 1)).then(
          (_) async {
            Navigator.pop(context, 'update');
          },
        );
      }
      isReturnClick = true;
      changeStatus(UpdateOrdStatus.isSuccsess);
    } catch (e) {
      errorMessage = e.toString();

      changeStatus(UpdateOrdStatus.isFailure);
    }
  }

  Future<void> sendBankProof(String id, BuildContext context) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);

      var request = await UpdateOrderRepository.sendBankProof();
      request.headers.addAll(headers);
      request.fields[ORDER_ID] = id;

      for (var i = 0; i < files.length; i++) {
        final mimeType = lookupMimeType(files[i].path);

        var extension = mimeType!.split('/');

        var pic = await http.MultipartFile.fromPath(
          ATTACH,
          files[i].path,
          contentType: MediaType('image', extension[1]),
        );

        request.files.add(pic);
      }

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);
      String msg = getdata['message'];

      files.clear();

      changeStatus(UpdateOrdStatus.inProgress);

      setSnackbar(msg, context);
    } on TimeoutException catch (_) {
      setSnackbar(
        getTranslated(context, 'somethingMSg')!,
        context,
      );
    }
  }

  Future<void> setRating(
    double rating,
    var productID,
    BuildContext context,
    Function snackbarprint,
  ) async {
    try {
      changeStatus(UpdateOrdStatus.inProgress);
      var request = await UpdateOrderRepository.setRating();
      request.headers.addAll(headers);
      request.fields[USER_ID] = CUR_USERID!;
      request.fields[PRODUCT_ID] = productID;

      if (reviewPhotos.isNotEmpty) {
        for (var i = 0; i < reviewPhotos.length; i++) {
          final mimeType = lookupMimeType(reviewPhotos[i].path);
          var extension = mimeType!.split('/');
          var pic = await http.MultipartFile.fromPath(
            IMGS,
            reviewPhotos[i].path,
            contentType: MediaType(
              'image',
              extension[1],
            ),
          );

          request.files.add(pic);
        }
      }

      if (updatedComment != '') request.fields[COMMENT] = updatedComment;
      if (rating != 0) request.fields[RATING] = rating.toString();
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var getdata = json.decode(responseString);

      bool error = getdata['error'];
      msg = getdata['message'];
      snackbarprint(msg);
    } on TimeoutException catch (_) {
      setSnackbar(
        getTranslated(context, 'somethingMSg')!,
        context,
      );
    }
  }
}
