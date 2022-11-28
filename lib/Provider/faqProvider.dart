import 'package:flutter/material.dart';
import '../Helper/String.dart';
import '../repository/faqRepository.dart';

enum FaQProviderStatus {
  initial,
  inProgress,
  isSuccsess,
  isFailure,
}

class FaQProvider extends ChangeNotifier {
  FaQProviderStatus _systemProviderPolicyStatus = FaQProviderStatus.initial;
  String? currentProductId, question;
  String errorMessage = '';
  changeStatus(FaQProviderStatus status) {
    _systemProviderPolicyStatus = status;
    notifyListeners();
  }

  setProdId(String? value) {
    currentProductId = value;
    notifyListeners();
  }

  setquestion(String? value) {
    question = value;
    notifyListeners();
  }

  // add new Q.
  Future<Map<String, dynamic>> setFaqsQue() async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: currentProductId,
        QUESTION: question
      };

      var result =
          await FaqRepository.setFaqsQueOnProduct(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchProductFaqs() async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        PRODUCT_ID: currentProductId,
      };

      var result =
          await FaqRepository.getFaqsQueOnProduct(parameter: parameter);
      return result;
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }
}
