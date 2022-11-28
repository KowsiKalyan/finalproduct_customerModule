import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../repository/chatRepositry.dart';
import '../Screen/Language/languageSettings.dart';
import '../widgets/security.dart';
import '../widgets/snackbar.dart';
import 'SettingProvider.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatProvider extends ChangeNotifier {
  late Map<String?, String> downloadlist;
  String filePath = '';
  Future<List<Directory>?>? externalStorageDirectories;
  TextEditingController msgController = TextEditingController();
  List<File> files = [];
  List<Model> chatList = [];
  final ScrollController scrollController = ScrollController();
  StreamController<String>? chatstreamdata;

  Future<void> getMsg(
    BuildContext context,
    String? id,
    Function updateNow,
  ) async {
    try {
      var data = {
        TICKET_ID: id,
      };

      var result = await ChatRepository.getMsgAPi(parameter: data);

      bool error = result['error'];
      String? msg = result['message'];

      if (!error) {
        var data = result['data'];
        chatList = (data as List).map((data) => Model.fromChat(data)).toList();
      } else {
        if (msg != 'Ticket Message(s) does not exist') {
          setSnackbar(msg!, context);
        }
      }
      updateNow();
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, context);
    }
  }

  Future<void> sendMessage(
    String message,
    BuildContext context,
    Function update,
    String? id,
  ) async {
    SettingProvider settingsProvider =
        Provider.of<SettingProvider>(context, listen: false);
    msgController.text = '';
    update();
    var request = http.MultipartRequest('POST', sendMsgApi);
    request.headers.addAll(headers);
    request.fields[USER_ID] = settingsProvider.userId!;
    request.fields[TICKET_ID] = id!;
    request.fields[USER_TYPE] = USER;
    request.fields[MESSAGE] = message;

    for (int i = 0; i < files.length; i++) {
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

    bool error = getdata['error'];
    String? msg = getdata['message'];
    var data = getdata['data'];
    if (!error) {
      insertItem(responseString);
    }
  }

  void insertItem(String response) {
    if (chatstreamdata != null) chatstreamdata!.sink.add(response);
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
