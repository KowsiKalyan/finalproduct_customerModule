import 'package:flutter/cupertino.dart';
import '../Screen/Auth/Login.dart';
import '../Screen/Cart/Cart.dart';
import '../Screen/Chat/Chat.dart';
import '../Screen/CompareList/CompareList.dart';
import '../Screen/CustomerSupport/Customer_Support.dart';
import '../Screen/FAQsList/FaqsList.dart';
import '../Screen/Favourite/Favorite.dart';
import '../Screen/Manage Address/Manage_Address.dart';
import '../Screen/My Wallet/My_Wallet.dart';
import '../Screen/MyOrder/MyOrder.dart';
import '../Screen/OrderSuccess/Order_Success.dart';
import '../Screen/PrivacyPolicy/Privacy_Policy.dart';
import '../Screen/ProductPreview/productPreview.dart';
import '../Screen/PromoCode/PromoCode.dart';
import '../Screen/ReferAndEarn/ReferEarn.dart';
import '../Screen/ReviewGallary/reviewGallary.dart';
import '../Screen/ReviewPreview/review_Preview.dart';
import '../Screen/Search/Search.dart';
import '../Screen/SellerDetail/Seller_Details.dart';
import '../Screen/SplashScreen/Splash.dart';
import '../Screen/Transaction/userTransactionsScreen.dart';
import '../Screen/Language/languageSettings.dart';

// comman Rout For All Screen
class Routes {
  static navigateToSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Search(),
      ),
    );
  }

  static navigateToReviewGallaryScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReviewGallary(),
      ),
    );
  }

  static navigateToProductPreviewScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ProductPreview(),
      ),
    );
  }

  static navigateToCompareListScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CompareList(),
      ),
    );
  }

  static navigateToReferEarnScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReferEarn(),
      ),
    );
  }

  static navigateToFaqsListScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const FaqsList(),
      ),
    );
  }

  static navigateToReviewPreviewScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ReviewPreview(),
      ),
    );
  }

  static navigateToFavoriteScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Favorite(),
      ),
    );
  }

  static navigateToSplashScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Splash(),
      ),
    );
  }

  static navigateToCustomerSupportScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CustomerSupport(),
      ),
    );
  }

  static navigateToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  static navigateToUserTransactionsScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const UserTransactions(),
      ),
    );
  }

  static navigateToMyOrderScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MyOrder(),
      ),
    );
  }

  static navigateToMyWalletScreen(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const MyWallet(),
      ),
    );
  }

  static navigateToPrivacyPolicyScreen(
      {required BuildContext context, required String title}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PrivacyPolicy(
          title: getTranslated(context, title),
        ),
      ),
    );
  }

  // Push Replacement Routes

  static navigateToOrderSuccessScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => const OrderSuccess()),
        ModalRoute.withName('/home'));
  }

  // pop the current page
  static pop(BuildContext context) {
    Navigator.pop(context);
  }

  // Routes With Parameters
  static navigateToChatScreen(
      BuildContext context, String? id, String? status) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => Chat(
          id: id,
          status: status,
        ),
      ),
    );
  }

  static navigateToManageAddressScreen(BuildContext context, bool? home) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ManageAddress(
          home: home,
        ),
      ),
    );
  }

  static navigateToCartScreen(BuildContext context, bool from) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => Cart(
          fromBottom: from,
        ),
      ),
    );
  }

  static navigateToPromoCodeScreen(
      BuildContext context, String from, Function updateParentNow) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PromoCode(
          from: from,
          updateParent: updateParentNow,
        ),
      ),
    );
  }

  static navigateToSellerProfileScreen(
    BuildContext context,
    String? sellerId,
    String? sellerImage,
    String? sellerName,
    String? sellerRatting,
    String? sellerStorename,
    String? storeDescription,
    String? totalProductsOfSeller,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => SellerProfile(
          sellerID: sellerId,
          sellerImage: sellerImage,
          sellerName: sellerName,
          sellerRating: sellerRatting,
          sellerStoreName: sellerStorename,
          totalProductsOfSeller: totalProductsOfSeller,
          storeDesc: storeDescription,
        ),
      ),
    );
  }
}
