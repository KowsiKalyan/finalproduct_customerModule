import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/SQLiteData/SqliteData.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/systemProvider.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/MostLikeSection.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/hideAppBarBottom.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/homePageDialog.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/horizontalCategoryList.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/section.dart';
import 'package:eshop_multivendor/Screen/homePage/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:version/version.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Provider/Favourite/FavoriteProvider.dart';
import '../../Provider/homePageProvider.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/security.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var db = DatabaseHelper();
  final ScrollController _scrollBottomBarController = ScrollController();

  DateTime? currentBackPressTime;
  HomePageProvider? _homePageProvider;

  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  int count = 1;

  @override
  bool get wantKeepAlive => true;

  setStateNow() {
    setState(() {});
  }

  setSnackBarFunctionForCartMessage() {
    print("Above the If Condition  Condition : $homePageSingleSellerMessage");
    Future.delayed(Duration(seconds: 6)).then(
      (value) {
        print("After Delay Condition :  $homePageSingleSellerMessage");

        if (homePageSingleSellerMessage) {
          print(
              "in if condition execution , homePageSingleSellerMessage = $homePageSingleSellerMessage ");

          homePageSingleSellerMessage = false;

          showOverlay(
            'One of the product is out of stock, We are not able To Add In Cart',
            context,
          );
        }
      },
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (value) {
        _homePageProvider =
            Provider.of<HomePageProvider>(context, listen: false);
      },
    );
    UserProvider user = Provider.of<UserProvider>(context, listen: false);

    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);
    user.setMobile(setting.mobile);
    user.setName(setting.userName);
    user.setEmail(setting.email);
    user.setProfilePic(setting.profileUrl);
    Future.delayed(Duration.zero).then(
      (value) {
        callApi();
      },
    );

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    setSnackBarFunctionForCartMessage();
    Future.delayed(Duration.zero).then(
      (value) {
        hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: onWillPopScope,
        child: SafeArea(
          child: isNetworkAvail
              ? RefreshIndicator(
                  color: colors.primary,
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollBottomBarController,
                    slivers: [
                      SliverPersistentHeader(
                        floating: false,
                        pinned: true,
                        delegate: SearchBarHeaderDelegate(),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            CustomSlider(),
                            const HorizontalCategoryList(),
                            Section(),
                            const MostLikeSection(),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : NoInterNet(
                  buttonController: buttonController,
                  buttonSqueezeanimation: buttonSqueezeanimation,
                  setStateNoInternate: setStateNoInternate,
                ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().proIds.clear();
    context.read<HomePageProvider>().sliderList.clear();
    context.read<HomePageProvider>().offerImagesList.clear();
    context.read<HomePageProvider>().sectionList.clear();
    return callApi();
  }

  Future<void> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      getSetting();
      context.read<HomePageProvider>().getSliderImages();
      context.read<HomePageProvider>().getCategories(context);
      context.read<HomePageProvider>().getOfferImages();
      context.read<HomePageProvider>().getSections();
      context.read<HomePageProvider>().getMostLikeProducts();
      context.read<HomePageProvider>().getMostFavouriteProducts();
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
    return;
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    context.read<SystemProvider>().getSystemSettings(userID: CUR_USERID).then(
      (systemConfigData) async {
        if (!systemConfigData['error']) {
          //
          //Tag list from system API
          if (systemConfigData['tagList'] != null) {
            context.read<SearchProvider>().tagList =
                systemConfigData['tagList'];
          }
          //check whether app is under maintenance
          if (systemConfigData['isAppUnderMaintenance'] == '1') {
            HomePageDialog.showUnderMaintenanceDialog(context);
          }
          // if (singleSellerOrderSystem && forLoginPageSingleSellerSystem) {
          // if (CUR_USERID != null) {
          //   if (true) {
          //     forLoginPageSingleSellerSystem = false;

          //     getDialogForClearCart()!.then((value) {
          //       //
          //       print("data");
          //     });
          //   }
          // }
          //if user logged in then
          if (CUR_USERID != null) {
            context
                .read<UserProvider>()
                .setCartCount(systemConfigData['cartCount']);
            context
                .read<UserProvider>()
                .setBalance(systemConfigData['userBalance']);
            context
                .read<UserProvider>()
                .setPincode(systemConfigData['pinCode']);

            if (systemConfigData['referCode'] == null ||
                systemConfigData['referCode'] == '' ||
                systemConfigData['referCode']!.isEmpty) {
              generateReferral();
            }

            context.read<HomePageProvider>().getFav(context, setStateNow);
            context.read<CartProvider>().getUserCart(save: '0');
            _getOffFav();
            context.read<CartProvider>().getUserOfflineCart();
          }
          if (systemConfigData['isVersionSystemOn'] == '1') {
            String? androidVersion = systemConfigData['androidVersion'];
            String? iOSVersion = systemConfigData['iOSVersion'];

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String version = packageInfo.version;

            final Version currentVersion = Version.parse(version);
            final Version latestVersionAnd = Version.parse(androidVersion!);
            final Version latestVersionIos = Version.parse(iOSVersion!);

            if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
                (Platform.isIOS && latestVersionIos > currentVersion)) {
              HomePageDialog.showAppUpdateDialog(context);
            }
          }
          setState(() {});
        } else {
          setSnackbar(systemConfigData['message']!, context);
        }
      },
    ).onError(
      (error, stackTrace) {
        setSnackbar(error.toString(), context);
      },
    );
  }

  Future<void>? getDialogForClearCart() {
    HomePageDialog.clearYouCartDialog(context);
  }

  Future<void> _getOffFav() async {
    if (CUR_USERID == null || CUR_USERID == '') {
      List<String>? proIds = (await db.getFav())!;
      if (proIds.isNotEmpty) {
        isNetworkAvail = await isNetworkAvailable();

        if (isNetworkAvail) {
          try {
            var parameter = {'product_ids': proIds.join(',')};

            Response response =
                await post(getProductApi, body: parameter, headers: headers)
                    .timeout(const Duration(seconds: timeOut));

            var getdata = json.decode(response.body);
            bool error = getdata['error'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();

              context.read<FavoriteProvider>().setFavlist(tempList);
            }
            if (mounted) {
              setState(() {
                context.read<FavoriteProvider>().setLoading(false);
              });
            }
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg')!, context);
            context.read<FavoriteProvider>().setLoading(false);
          }
        } else {
          if (mounted) {
            setState(() {
              isNetworkAvail = false;
              context.read<FavoriteProvider>().setLoading(false);
            });
          }
        }
      } else {
        context.read<FavoriteProvider>().setFavlist([]);
        setState(() {
          context.read<FavoriteProvider>().setLoading(false);
        });
      }
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then(
      (getdata) {
        bool error = getdata['error'];
        if (!error) {
          REFER_CODE = refer;

          Map parameter = {
            USER_ID: CUR_USERID,
            REFERCODE: refer,
          };

          apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
        } else {
          if (count < 5) generateReferral();
          count++;
        }

        context.read<HomePageProvider>().secLoading = false;
      },
      onError: (error) {
        setSnackbar(error.toString(), context);
        context.read<HomePageProvider>().secLoading = false;
      },
    );
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            HorizontalCategoryList.catLoading(context),
            sliderLoading(),
            Section.sectionLoadingShimmer(context),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.simmerBase,
      highlightColor: Theme.of(context).colorScheme.simmerHigh,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.white,
      ),
    );
  }

  setStateNoInternate() async {
    context.read<HomePageProvider>().catLoading = true;
    context.read<HomePageProvider>().secLoading = true;
    context.read<HomePageProvider>().offerLoading = true;
    context.read<HomePageProvider>().mostLikeLoading = true;
    context.read<HomePageProvider>().sliderLoading = true;
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = true;
              },
            );
          }
          callApi();
        } else {
          await buttonController.reverse();
          if (mounted) setState(() {});
        }
      },
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  Future<bool> onWillPopScope() {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      setSnackbar(getTranslated(context, "Press back again to Exit")!, context);
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Theme.of(context).colorScheme.lightWhite,
        padding: EdgeInsets.fromLTRB(
          10,
          context.watch<HomePageProvider>().getBars ? 10 : 30,
          10,
          0,
        ),
        child: GestureDetector(
          child: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: TextField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                ),
                enabled: false,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.lightWhite,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  isDense: true,
                  hintText: getTranslated(context, 'searchHint'),
                  hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontSize: textFontSize12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      DesignConfiguration.setSvgPath('homepage_search'),
                      height: 15,
                      width: 15,
                    ),
                  ),
                  suffixIcon: Selector<ThemeNotifier, ThemeMode>(
                    selector: (_, themeProvider) =>
                        themeProvider.getThemeMode(),
                    builder: (context, data, child) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: (data == ThemeMode.system &&
                                    MediaQuery.of(context).platformBrightness ==
                                        Brightness.light) ||
                                data == ThemeMode.light
                            ? SvgPicture.asset(
                                DesignConfiguration.setSvgPath('voice_search'),
                                height: 15,
                                width: 15,
                              )
                            : SvgPicture.asset(
                                DesignConfiguration.setSvgPath(
                                    'voice_search_white'),
                                height: 15,
                                width: 15,
                              ),
                      );
                    },
                  ),
                  fillColor: Theme.of(context).colorScheme.white,
                  filled: true,
                ),
              ),
            ),
          ),
          onTap: () async {
            Routes.navigateToSearchScreen(context);
          },
        ),
      ),
    );
  }

  @override
  double get maxExtent => 75;

  @override
  double get minExtent => 75;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
