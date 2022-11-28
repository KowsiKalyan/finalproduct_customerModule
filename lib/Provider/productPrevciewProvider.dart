import 'package:flutter/material.dart';

class ProductPreviewProvider extends ChangeNotifier {
  //data for preview screen
  int? pos, secPos, index;
  String? id, video, videoType;
  bool? list, from;
  List<String?>? imgList;

  //get data here
  get posData => pos;
  get secPosData => secPos;
  get indexData => index;
  get idData => id;
  get videoData => video;
  get videoTypeData => videoType;
  get listData => list;
  get fromData => from;
  get imgListData => imgList;

// int data

  setposData(int? value) {
    pos = value;
    notifyListeners();
  }

  setsecPosData(int? value) {
    secPos = value;
    notifyListeners();
  }

  setindexData(int? value) {
    index = value;
    notifyListeners();
  }

// string data
  setidData(String? value) {
    id = value;
    notifyListeners();
  }

  setvideoData(String? value) {
    video = value;
    notifyListeners();
  }

  setvideoTypeData(String? value) {
    videoType = value;
    notifyListeners();
  }

// bool data
  setlistData(bool? value) {
    list = value;
    notifyListeners();
  }

  setfromData(bool? value) {
    from = value;
    notifyListeners();
  }

// image list
  setImageList(List<String?>? value) {
    imgList = value;
    notifyListeners();
  }
}
