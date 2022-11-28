import 'dart:async';
import 'package:eshop_multivendor/Screen/Profile/widgets/editProfileBottomSheet.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/myProfileDialog.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/userInformationContainer.dart';
import 'package:eshop_multivendor/widgets/bottomSheet.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/changePasswordBottomSheet.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/UserProvider.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import 'widgets/languageBottomSheet.dart';
import 'widgets/themeBottomSheet.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProfile();
}

class StateProfile extends State<MyProfile> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final InAppReview _inAppReview = InAppReview.instance;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  setStateNow() {
    setState(() {});
  }

  _getDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      children: <Widget>[
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'MY_ORDERS_LBL')!, 'pro_myorder'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'MANAGE_ADD_LBL')!, 'pro_address'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(getTranslated(context, 'MYWALLET')!, 'pro_wh'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(getTranslated(context, 'YOUR_PROM_CO')!, 'promo'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'MYTRANSACTION')!, 'pro_th'),
        _getDrawerItem(
            getTranslated(context, 'CHANGE_THEME_LBL')!, 'pro_theme'),
        _getDrawerItem(
            getTranslated(context, 'CHANGE_LANGUAGE_LBL')!, 'pro_language'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'CHANGE_PASS_LBL')!, 'pro_pass'),
        CUR_USERID == '' || CUR_USERID == null || !refer
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'REFEREARN')!, 'pro_referral'),
        _getDrawerItem(
            getTranslated(context, 'CUSTOMER_SUPPORT')!, 'pro_customersupport'),
        _getDrawerItem(getTranslated(context, 'ABOUT_LBL')!, 'pro_aboutus'),
        _getDrawerItem(
            getTranslated(context, 'CONTACT_LBL')!, 'pro_contact_us'),
        _getDrawerItem(getTranslated(context, 'FAQS')!, 'pro_faq'),
        _getDrawerItem(getTranslated(context, 'PRIVACY')!, 'pro_pp'),
        _getDrawerItem(getTranslated(context, 'TERM')!, 'pro_tc'),
        _getDrawerItem(getTranslated(context, 'SHIPPING_POLICY_LBL')!,
            'pro_shipping_policy'),
        _getDrawerItem(
            getTranslated(context, 'RETURN_POLICY_LBL')!, 'pro_return_policy'),
        _getDrawerItem(getTranslated(context, 'RATE_US')!, 'pro_rateus'),
        _getDrawerItem(getTranslated(context, 'Share App')!, 'pro_share'),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(
                getTranslated(context, 'DeleteAcoountNow')!,
                'delete_user',
              ),
        CUR_USERID == '' || CUR_USERID == null
            ? Container()
            : _getDrawerItem(getTranslated(context, 'LOGOUT')!, 'pro_logout'),
      ],
    );
  }

  _getDrawerItem(String title, String img) {
    return Card(
      elevation: 0.1,
      child: ListTile(
        trailing: const Icon(
          Icons.navigate_next,
          color: colors.primary,
        ),
        leading: title == getTranslated(context, 'YOUR_PROM_CO')
            ? Image.asset(
                DesignConfiguration.setPngPath(img),
                height: 25,
                width: 25,
                color: colors.primary,
              )
            : SvgPicture.asset(
                DesignConfiguration.setSvgPath(img),
                height: 25,
                width: 25,
                color: colors.primary,
              ),
        dense: true,
        title: Text(
          title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.lightBlack, fontSize: 15),
        ),
        onTap: () {
          if (title == getTranslated(context, 'MY_ORDERS_LBL')) {
            Routes.navigateToMyOrderScreen(context);
          } else if (title == getTranslated(context, 'MYTRANSACTION')) {
            Routes.navigateToUserTransactionsScreen(context);
          } else if (title == getTranslated(context, 'MYWALLET')) {
            Routes.navigateToMyWalletScreen(context);
          } else if (title == getTranslated(context, 'YOUR_PROM_CO')) {
            Routes.navigateToPromoCodeScreen(context, 'Profile', setStateNow);
          } else if (title == getTranslated(context, 'MANAGE_ADD_LBL')) {
            CUR_USERID == null
                ? Routes.navigateToLoginScreen(context)
                : Routes.navigateToManageAddressScreen(context, true);
          } else if (title == getTranslated(context, 'REFEREARN')) {
            Routes.navigateToReferEarnScreen(context);
          } else if (title == getTranslated(context, 'CONTACT_LBL')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'CONTACT_LBL');
          } else if (title == getTranslated(context, 'CUSTOMER_SUPPORT')) {
            CUR_USERID == null
                ? Routes.navigateToLoginScreen(context)
                : Routes.navigateToCustomerSupportScreen(context);
          } else if (title == getTranslated(context, 'TERM')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'TERM');
          } else if (title == getTranslated(context, 'PRIVACY')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'PRIVACY');
          } else if (title == getTranslated(context, 'RATE_US')) {
            _openStoreListing();
          } else if (title == getTranslated(context, 'Share App')) {
            var str =
                "$appName\n\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n ${getTranslated(context, 'IOSLBL')}\n$iosLink";
            Share.share(str);
          } else if (title == getTranslated(context, 'ABOUT_LBL')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'ABOUT_LBL');
          } else if (title == getTranslated(context, 'SHIPPING_POLICY_LBL')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'SHIPPING_POLICY_LBL');
          } else if (title == getTranslated(context, 'RETURN_POLICY_LBL')) {
            Routes.navigateToPrivacyPolicyScreen(
                context: context, title: 'RETURN_POLICY_LBL');
          } else if (title == getTranslated(context, 'FAQS')) {
            Routes.navigateToFaqsListScreen(context);
          } else if (title == getTranslated(context, 'CHANGE_THEME_LBL')) {
            CustomBottomSheet.showBottomSheet(
                    child: ThemeBottomSheet(),
                    context: context,
                    enableDrag: true)
                .then((value) {
              setState(() {});
              Future.delayed(const Duration(seconds: 3)).then((_) {
                setState(() {});
              });
            });
          } else if (title == getTranslated(context, 'LOGOUT')) {
            MyProfileDialog.showLogoutDialog(context);
          } else if (title == getTranslated(context, 'CHANGE_PASS_LBL')) {
            CustomBottomSheet.showBottomSheet(
                child: ChangePasswordBottomSheet(),
                context: context,
                enableDrag: true);
          } else if (title == getTranslated(context, 'CHANGE_LANGUAGE_LBL')) {
            CustomBottomSheet.showBottomSheet(
                child: LanguageBottomSheet(),
                context: context,
                enableDrag: true);
          } else if (title == getTranslated(context, 'DeleteAcoountNow')) {
            MyProfileDialog.showDeleteWarningAccountDialog(context);
          }
        },
      ),
    );
  }

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: 'microsoftStoreId',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.only(bottom: 10.0, top: 10),
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 10.0,
                  ),
                  child: Row(
                    children: [
                      Selector<UserProvider, String>(
                        selector: (_, provider) => provider.profilePic,
                        builder: (context, profileImage, child) {
                          return getUserImage(profileImage, context,
                              () => openEditBottomSheet(context));
                        },
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Selector<UserProvider, String>(
                            selector: (_, provider) => provider.curUserName,
                            builder: (context, userName, child) {
                              return Text(
                                userName == ''
                                    ? getTranslated(context, 'GUEST')!
                                    : userName,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                              );
                            },
                          ),
                          Selector<UserProvider, String>(
                            selector: (_, provider) => provider.mob,
                            builder: (context, userMobile, child) {
                              return userMobile != ''
                                  ? Text(
                                      userMobile,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                    )
                                  : Container(
                                      height: 0,
                                    );
                            },
                          ),
                          Selector<UserProvider, String>(
                            selector: (_, provider) => provider.email,
                            builder: (context, userEmail, child) {
                              return userEmail != ''
                                  ? Text(
                                      userEmail,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    )
                                  : Container(
                                      height: 0,
                                    );
                            },
                          ),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              return userProvider.curUserName == ''
                                  ? Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 7),
                                      child: InkWell(
                                        child: Text(
                                          getTranslated(
                                              context, 'LOGIN_REGISTER_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                color: colors.primary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                        onTap: () {
                                          Routes.navigateToLoginScreen(context);
                                        },
                                      ),
                                    )
                                  : Container();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _getDrawer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getUserImage(
    String profileImage,
    BuildContext context,
    VoidCallback? onBtnSelected,
  ) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (CUR_USERID != null) {
              onBtnSelected!();
            }
          },
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 20),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 1.0,
                color: Theme.of(context).colorScheme.black,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return userProvider.profilePic != ''
                      ? DesignConfiguration.getCacheNotworkImage(
                          boxFit: BoxFit.cover,
                          context: context,
                          heightvalue: 64.0,
                          widthvalue: 64.0,
                          placeHolderSize: 64.0,
                          imageurlString: userProvider.profilePic,
                        )
                      : DesignConfiguration.imagePlaceHolder(62, context);
                },
              ),
            ),
          ),
        ),
        if (CUR_USERID != null)
          Positioned.directional(
            textDirection: Directionality.of(context),
            end: 20,
            bottom: 5,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                border: Border.all(color: colors.primary),
              ),
              child: InkWell(
                child: const Icon(
                  Icons.edit,
                  color: colors.whiteTemp,
                  size: 10,
                ),
                onTap: () {
                  onBtnSelected!();
                },
              ),
            ),
          ),
      ],
    );
  }

  openChangeUserDetailsBottomSheet(BuildContext context) {
    CustomBottomSheet.showBottomSheet(
      child: const EditProfileBottomSheet(),
      context: context,
      enableDrag: true,
    );
  }

  openEditBottomSheet(BuildContext context) {
    return openChangeUserDetailsBottomSheet(context);
  }
}
