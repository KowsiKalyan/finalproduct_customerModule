import 'dart:math';
import 'package:eshop_multivendor/Provider/Theme.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/explore_provider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/productListProvider.dart';
import '../../Provider/sellerDetailProvider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widgte/gridViewLayOut.dart';
import 'Widgte/listViewLayOut.dart';
import 'Widgte/sellerContentWidget.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

ScrollController? sellerListController;
ScrollController? productsController;

class _SearchState extends State<Explore> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pos = 0;
  final bool _isProgress = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  String query = '';
  int notificationoffset = 0;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  late AnimationController _animationController;
  Timer? _debounce;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String _currentLocaleId = '';
  String lastWords = '';
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  ChoiceChip? tagChip;
  late UserProvider userProvider;
  late TabController _tabController;
  late AnimationController listViewIconController;
  var filterList;
  String minPrice = '0', maxPrice = '0';
  List<String>? attributeNameList,
      attributeSubList,
      attributeIDList,
      selectedId = [];
  bool initializingFilterDialogFirstTime = true;

  RangeValues? _currentRangeValues;

  ChoiceChip? choiceChip;

  String selId = '';

  String sortBy = 'p.date_added', orderBy = 'DESC';
  update() {
    setState(() {});
  }

  @override
  void initState() {
    context.read<SellerDetailProvider>().doSellerListEmpty();
    context.read<SellerDetailProvider>().setOffsetvalue(0);
    notificationoffset = 0;
    productsController = ScrollController(keepScrollOffset: true);
    productsController!.addListener(_productsListScrollListener);
    sellerListController = ScrollController(keepScrollOffset: true);
    sellerListController!.addListener(_sellerListController);
    context.read<ExploreProvider>().productList = [];
    listViewIconController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ),
    );

    _controller.addListener(
      () {
        if (_controller.text.isEmpty) {
          if (mounted) {
            setState(
              () {
                query = '';
                notificationoffset = 0;
              },
            );
          }
          getProduct('0');
        } else {
          if (_tabController.index == 0) {
            query = _controller.text;
            notificationoffset = 0;
            notificationisnodata = false;

            if (query.trim().isNotEmpty) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 500),
                () {
                  if (query.trim().isNotEmpty) {
                    notificationisloadmore = true;
                    notificationoffset = 0;
                    getProduct('0');
                  }
                },
              );
            }
          } else {
            String search = '';
            search = _controller.text;
            context.read<SellerDetailProvider>().setOffsetvalue(0);
            context.read<HomePageProvider>().setSellerLoading(true);
            if (search.trim().isNotEmpty) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 500),
                () {
                  if (search.trim().isNotEmpty) {
                    context.read<SellerDetailProvider>().doSellerListEmpty();
                    context.read<SellerDetailProvider>().setOffsetvalue(0);
                    context.read<HomePageProvider>().setSellerLoading(true);
                    Future.delayed(Duration.zero).then(
                      (value) => context.read<SellerDetailProvider>().getSeller(
                            '',
                            _controller.text.trim(),
                          ),
                    );
                  }
                },
              );
            }
          }
        }
        ScaffoldMessenger.of(context).clearSnackBars();
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
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
    getProduct('0');
    Future.delayed(Duration.zero).then(
      (value) => context.read<SellerDetailProvider>().getSeller(
            '',
            _controller.text.trim(),
          ),
    );
    super.initState();
  }

  _productsListScrollListener() {
    if (productsController!.offset >=
            productsController!.position.maxScrollExtent &&
        !productsController!.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            getProduct('0');
          },
        );
      }
    }
  }

  _sellerListController() {
    if (sellerListController!.offset >=
            sellerListController!.position.maxScrollExtent &&
        !sellerListController!.position.outOfRange) {
      if (mounted) {
        if (context.read<SellerDetailProvider>().sellerListOffsetValue <
            context.read<SellerDetailProvider>().totalSellerCountValue) {
          Future.delayed(Duration.zero).then(
            (value) => context.read<SellerDetailProvider>().getSeller(
                  '',
                  _controller.text.trim(),
                ),
          );
          setState(
            () {},
          );
        }
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    productsController!.dispose();
    sellerListController!.dispose();
    _tabController.dispose();
    _controller.dispose();
    listViewIconController.dispose();

    _animationController.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: isNetworkAvail
          ? Consumer<SellerDetailProvider>(
              builder: (context, value, child) {
                if (value.getCurrentStatus ==
                    SellerDetailProviderStatus.isSuccsess) {
                  return Column(
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                circularBorderRadius10,
                              ),
                            ),
                            height: 44,
                            child: TextField(
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.normal,
                              ),
                              controller: _controller,
                              autofocus: false,
                              enabled: true,
                              textAlign: TextAlign.left,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightWhite),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                    15.0, 5.0, 0, 5.0),
                                border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                fillColor:
                                    Theme.of(context).colorScheme.lightWhite,
                                filled: true,
                                isDense: true,
                                hintText: getTranslated(context, 'searchHint'),
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontSize: textFontSize12,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                    ),
                                prefixIcon: const Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Icon(Icons.search)),
                                suffixIcon: _controller.text != ''
                                    ? IconButton(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          _controller.text = '';
                                          notificationoffset = 0;
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: colors.primary,
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            lastWords = '';
                                            if (!_hasSpeech) {
                                              initSpeechState();
                                            } else {
                                              showSpeechDialog();
                                            }
                                          },
                                          child: Selector<ThemeNotifier,
                                              ThemeMode>(
                                            selector: (_, themeProvider) =>
                                                themeProvider.getThemeMode(),
                                            builder: (context, data, child) {
                                              return (data ==
                                                              ThemeMode
                                                                  .system &&
                                                          MediaQuery.of(context)
                                                                  .platformBrightness ==
                                                              Brightness
                                                                  .light) ||
                                                      data == ThemeMode.light
                                                  ? SvgPicture.asset(
                                                      DesignConfiguration
                                                          .setSvgPath(
                                                              'voice_search'),
                                                      height: 15,
                                                      width: 15,
                                                    )
                                                  : SvgPicture.asset(
                                                      DesignConfiguration
                                                          .setSvgPath(
                                                              'voice_search_white'),
                                                      height: 15,
                                                      width: 15,
                                                    );
                                            },
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Theme.of(context).colorScheme.white,
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              child: Text(
                                getTranslated(context, 'ALL_PRODUCTS')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      fontFamily: 'ubuntu',
                                    ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                getTranslated(context, 'ALL_SELLERS')!,
                                style: const TextStyle(
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                          ],
                          indicatorColor: colors.primary,
                          labelColor: Theme.of(context).colorScheme.fontColor,
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor:
                              Theme.of(context).colorScheme.lightBlack,
                          labelStyle: const TextStyle(
                            fontSize: textFontSize16,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Stack(
                              children: <Widget>[
                                _showContentOfProducts(),
                                Center(
                                  child:
                                      DesignConfiguration.showCircularProgress(
                                    _isProgress,
                                    colors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: <Widget>[
                                ShowContentOfSellers(
                                  sellerList: value.sellerList,
                                ),
                                Center(
                                  child:
                                      DesignConfiguration.showCircularProgress(
                                    _isProgress,
                                    colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (value.getCurrentStatus ==
                    SellerDetailProviderStatus.isFailure) {
                  return Center(
                    child: Text(
                      value.geterrormessage,
                      style: const TextStyle(
                        fontFamily: 'ubuntu',
                      ),
                    ),
                  );
                }
                return const ShimmerEffect();
              },
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  void getAvailVarient(List<Product> tempList) {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == '2') {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == '1') {
            tempList[j].selVarient = i;
            break;
          }
        }
      }
    }
    if (notificationoffset == 0) {
      context.read<ExploreProvider>().productList = [];
    }

    context.read<ExploreProvider>().productList.addAll(tempList);
    notificationisloadmore = true;
    notificationoffset = notificationoffset + perPage;
  }

  Future getProduct(String? showTopRated) async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (notificationisloadmore) {
        if (mounted) {
          setState(
            () {
              notificationisloadmore = false;
              notificationisgettingdata = true;
            },
          );
        }

        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: notificationoffset.toString(),
          SORT: sortBy,
          ORDER: orderBy,
          TOP_RETAED: showTopRated,
        };

        if (selId != '') {
          parameter[ATTRIBUTE_VALUE_ID] = selId;
        }

        if (query.trim() != '') {
          parameter[SEARCH] = query.trim();
        }

        if (_currentRangeValues != null &&
            _currentRangeValues!.start.round().toString() != '0') {
          parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
        }

        if (_currentRangeValues != null &&
            _currentRangeValues!.end.round().toString() != '0') {
          parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
        }

        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

        context.read<ProductListProvider>().setProductListParameter(parameter);
        Future.delayed(Duration.zero).then(
          (value) => context.read<ProductListProvider>().getProductList().then(
            (
              value,
            ) async {
              bool error = value['error'];
              String? search = value['search'];
              context.read<ExploreProvider>().setProductTotal(value['total'] ??
                  context.read<ExploreProvider>().totalProducts);
              notificationisgettingdata = false;
              if (notificationoffset == 0) notificationisnodata = error;

              if (!error && search!.trim() == query.trim()) {
                if (mounted) {
                  if (initializingFilterDialogFirstTime) {
                    filterList = value['filters'];

                    minPrice = value[MINPRICE].toString();
                    maxPrice = value[MAXPRICE].toString();
                    _currentRangeValues = RangeValues(
                        double.parse(minPrice), double.parse(maxPrice));
                    initializingFilterDialogFirstTime = false;
                  }

                  Future.delayed(
                    Duration.zero,
                    () => setState(
                      () {
                        List mainlist = value['data'];
                        if (mainlist.isNotEmpty) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(mainlist
                              .map((data) => Product.fromJson(data))
                              .toList());

                          allitems.addAll(items);

                          getAvailVarient(allitems);
                        } else {
                          notificationisloadmore = false;
                        }
                      },
                    ),
                  );
                }
              } else {
                notificationisloadmore = false;
                if (mounted) setState(() {});
              }
            },
          ),
        );
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  clearAll() {
    setState(
      () {
        query = _controller.text;
        notificationoffset = 0;
        notificationisloadmore = true;
        context.read<ExploreProvider>().productList.clear();
      },
    );
  }

  _showContentOfProducts() {
    return Column(
      children: <Widget>[
        sortAndFilterOption(),
        searchResult(),
        Expanded(
          child: notificationisnodata
              ? DesignConfiguration.getNoItem(context)
              : Stack(
                  children: [
                    context.watch<ExploreProvider>().getCurrentView !=
                            'GridView'
                        ? ListViewLayOut(
                            fromExplore: true,
                            update: update,
                          )
                        : getGridviewLayoutOfProducts(),
                    notificationisgettingdata
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  void errorListener(SpeechRecognitionError error) {}

  void statusListener(String status) {
    setStater(
      () {
        lastStatus = status;
      },
    );
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(
      () {},
    );
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(
      () {
        this.level = level;
      },
    );
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(
      () {
        level = 0.0;
      },
    );
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords;
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then(
        (_) async {
          clearAll();

          _controller.text = lastWords;
          _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length));

          setState(() {});
          Navigator.of(context).pop();
        },
      );
    }
  }

  showSpeechDialog() {
    return DesignConfiguration.dialogAnimate(
      context,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
          setStater = setStater1;
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.lightWhite,
            title: Text(
              getTranslated(context, 'SEarchHint')!,
              style: TextStyle(
                fontFamily: 'ubuntu',
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color: Theme.of(context)
                              .colorScheme
                              .black
                              .withOpacity(.05))
                    ],
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.mic,
                      color: colors.primary,
                    ),
                    onPressed: () {
                      if (!_hasSpeech) {
                        initSpeechState();
                      } else {
                        !_hasSpeech || speech.isListening
                            ? null
                            : startListening();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    lastWords,
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                  child: Center(
                    child: speech.isListening
                        ? Text(
                            getTranslated(context, "I'm listening...")!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                ),
                          )
                        : Text(
                            getTranslated(context, 'Not listening')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ubuntu',
                                ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          top: 19.0, bottom: 16.0),
                      child: Text(
                        getTranslated(context, 'SORT_BY')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: 18,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      sortBy = '';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            notificationoffset = 0;
                            context.read<ExploreProvider>().productList.clear();
                          },
                        );
                      }
                      getProduct('1');
                      Navigator.pop(context, 'option 1');
                    },
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == ''
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'TOP_RATED')!,
                        style: TextStyle(
                          color: sortBy == ''
                              ? Theme.of(context).colorScheme.white
                              : Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize16,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == 'p.date_added' && orderBy == 'DESC'
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_NEWEST')!,
                        style: TextStyle(
                          color: sortBy == 'p.date_added' && orderBy == 'DESC'
                              ? Theme.of(context).colorScheme.white
                              : Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize16,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'p.date_added';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            notificationoffset = 0;
                            context.read<ExploreProvider>().productList.clear();
                          },
                        );
                      }
                      getProduct('0');
                      Navigator.pop(context, 'option 1');
                    },
                  ),
                  InkWell(
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == 'p.date_added' && orderBy == 'ASC'
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_OLDEST')!,
                        style: TextStyle(
                          color: sortBy == 'p.date_added' && orderBy == 'ASC'
                              ? Theme.of(context).colorScheme.white
                              : Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize16,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'p.date_added';
                      orderBy = 'ASC';
                      if (mounted) {
                        setState(
                          () {
                            notificationoffset = 0;
                            context.read<ExploreProvider>().productList.clear();
                          },
                        );
                      }
                      getProduct('0');
                      Navigator.pop(context, 'option 2');
                    },
                  ),
                  InkWell(
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == 'pv.price' && orderBy == 'ASC'
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_LOW')!,
                        style: TextStyle(
                          color: sortBy == 'pv.price' && orderBy == 'ASC'
                              ? Theme.of(context).colorScheme.white
                              : Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize16,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'pv.price';
                      orderBy = 'ASC';
                      if (mounted) {
                        setState(
                          () {
                            notificationoffset = 0;
                            context.read<ExploreProvider>().productList.clear();
                          },
                        );
                      }
                      getProduct('0');
                      Navigator.pop(context, 'option 3');
                    },
                  ),
                  InkWell(
                    child: Container(
                      width: deviceWidth,
                      color: sortBy == 'pv.price' && orderBy == 'DESC'
                          ? colors.primary
                          : Theme.of(context).colorScheme.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        getTranslated(context, 'F_HIGH')!,
                        style: TextStyle(
                          color: sortBy == 'pv.price' && orderBy == 'DESC'
                              ? Theme.of(context).colorScheme.white
                              : Theme.of(context).colorScheme.fontColor,
                          fontSize: textFontSize16,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'pv.price';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            notificationoffset = 0;
                            context.read<ExploreProvider>().productList.clear();
                          },
                        );
                      }
                      getProduct('0');
                      Navigator.pop(context, 'option 4');
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  sortAndFilterOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
        color: Theme.of(context).colorScheme.white,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: GestureDetector(
                  onTap: sortDialog,
                  child: Row(
                    children: [
                      Text(
                        getTranslated(context, 'SORT_BY')!,
                        style: const TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: textFontSize12,
                          fontFamily: 'ubuntu',
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        size: 16,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 3.0,
                    ),
                    child: InkWell(
                      child: AnimatedIcon(
                        textDirection: TextDirection.ltr,
                        icon: AnimatedIcons.list_view,
                        progress: listViewIconController,
                      ),
                      onTap: () {
                        if (context
                            .read<ExploreProvider>()
                            .productList
                            .isNotEmpty) {
                          if (context.read<ExploreProvider>().view ==
                              'ListView') {
                            context
                                .read<ExploreProvider>()
                                .changeViewTo('GridView');
                          } else {
                            context
                                .read<ExploreProvider>()
                                .changeViewTo('ListView');
                          }
                        }
                        context.read<ExploreProvider>().view == 'ListView'
                            ? listViewIconController.forward()
                            : listViewIconController.reverse();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  GestureDetector(
                    onTap: filterDialog,
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined),
                        Text(
                          getTranslated(context, 'FILTER')!,
                          style: TextStyle(
                            fontFamily: 'ubuntu',
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  searchResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
        color: Theme.of(context).colorScheme.white,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: Text(
                  getTranslated(context, 'TITLE1_LBL')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize16,
                    fontFamily: 'ubuntu',
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: Selector<ExploreProvider, String>(
                builder: (context, totalProducts, child) {
                  return Text(
                    '$totalProducts ${getTranslated(context, "Items_Found")}',
                    style: const TextStyle(
                      fontFamily: 'ubuntu',
                    ),
                  );
                },
                selector: (_, exploreProvider) => exploreProvider.totalProducts,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 30.0),
                  child: AppBar(
                    title: Text(
                      getTranslated(context, 'FILTER')!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontFamily: 'ubuntu',
                      ),
                    ),
                    centerTitle: true,
                    elevation: 5,
                    backgroundColor: Theme.of(context).colorScheme.white,
                    leading: Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.only(end: 4.0),
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  color: Theme.of(context).colorScheme.lightWhite,
                  padding: const EdgeInsetsDirectional.only(
                    start: 7.0,
                    end: 7.0,
                    top: 7.0,
                  ),
                  child: filterList != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsetsDirectional.only(top: 10.0),
                          itemCount: filterList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: deviceWidth,
                                    child: Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          getTranslated(
                                              context, 'Price Range')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                fontFamily: 'ubuntu',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightBlack,
                                                fontWeight: FontWeight.normal,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  RangeSlider(
                                    values: _currentRangeValues!,
                                    min: double.parse(minPrice),
                                    max: double.parse(maxPrice),
                                    divisions: 10,
                                    labels: RangeLabels(
                                      _currentRangeValues!.start
                                          .round()
                                          .toString(),
                                      _currentRangeValues!.end
                                          .round()
                                          .toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      _currentRangeValues = values;
                                      setState(
                                        () {},
                                      );
                                    },
                                  ),
                                ],
                              );
                            } else {
                              index = index - 1;
                              attributeSubList = filterList[index]
                                      ['attribute_values']
                                  .split(',');

                              attributeIDList = filterList[index]
                                      ['attribute_values_id']
                                  .split(',');

                              List<Widget?> chips = [];
                              List<String> att = filterList[index]
                                      ['attribute_values']!
                                  .split(',');

                              List<String> attSType =
                                  filterList[index]['swatche_type'].split(',');

                              List<String> attSValue =
                                  filterList[index]['swatche_value'].split(',');

                              for (int i = 0; i < att.length; i++) {
                                Widget itemLabel;
                                if (attSType[i] == '1') {
                                  String clr = (attSValue[i].substring(1));

                                  String color = '0xff$clr';

                                  itemLabel = Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(
                                        int.parse(color),
                                      ),
                                    ),
                                  );
                                } else if (attSType[i] == '2') {
                                  itemLabel = ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      attSValue[i],
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              DesignConfiguration.erroWidget(
                                        80,
                                      ),
                                    ),
                                  );
                                } else {
                                  itemLabel = Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      att[i],
                                      style: TextStyle(
                                        fontFamily: 'ubuntu',
                                        color: selectedId!
                                                .contains(attributeIDList![i])
                                            ? Theme.of(context)
                                                .colorScheme
                                                .white
                                            : Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                      ),
                                    ),
                                  );
                                }

                                choiceChip = ChoiceChip(
                                  selected:
                                      selectedId!.contains(attributeIDList![i]),
                                  label: itemLabel,
                                  labelPadding: const EdgeInsets.all(0),
                                  selectedColor: colors.primary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        attSType[i] == '1' ? 100 : 10),
                                    side: BorderSide(
                                        color: selectedId!
                                                .contains(attributeIDList![i])
                                            ? colors.primary
                                            : colors.black12,
                                        width: 1.5),
                                  ),
                                  onSelected: (bool selected) {
                                    attributeIDList = filterList[index]
                                            ['attribute_values_id']
                                        .split(',');

                                    if (mounted) {
                                      setState(
                                        () {
                                          if (selected == true) {
                                            selectedId!
                                                .add(attributeIDList![i]);
                                          } else {
                                            selectedId!
                                                .remove(attributeIDList![i]);
                                          }
                                        },
                                      );
                                    }
                                  },
                                );

                                chips.add(choiceChip);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: deviceWidth,
                                    child: Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          filterList[index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  fontFamily: 'ubuntu',
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  chips.isNotEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Wrap(
                                            children: chips.map<Widget>(
                                              (Widget? chip) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: chip,
                                                );
                                              },
                                            ).toList(),
                                          ),
                                        )
                                      : Container()
                                ],
                              );
                            }
                          },
                        )
                      : Container(),
                )),
                Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 20),
                        width: deviceWidth! * 0.4,
                        child: OutlinedButton(
                          onPressed: () {
                            if (mounted) {
                              setState(
                                () {
                                  selectedId!.clear();
                                },
                              );
                              Routes.pop(context);
                            }
                          },
                          child: Text(
                            getTranslated(context, 'DISCARD')!,
                            style: const TextStyle(
                              fontFamily: 'ubuntu',
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      SimBtn(
                        borderRadius: circularBorderRadius5,
                        size: 0.4,
                        title: getTranslated(context, 'APPLY'),
                        onBtnSelected: () {
                          if (selectedId != null) {
                            selId = selectedId!.join(',');
                          }
                          if (mounted) {
                            setState(
                              () {
                                notificationoffset = 0;
                                context
                                    .read<ExploreProvider>()
                                    .productList
                                    .clear();
                              },
                            );
                          }
                          getProduct('0');
                          Navigator.pop(context, 'Product Filter');
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  getGridviewLayoutOfProducts() {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: GridView.count(
          controller: productsController,
          padding: const EdgeInsetsDirectional.only(top: 5),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 0.750,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          physics: const BouncingScrollPhysics(),
          children: List.generate(
            context.read<ExploreProvider>().productList.length,
            (index) {
              return GridViewLayOut(
                index: index,
                update: update,
              );
            },
          ),
        ),
      ),
    );
  }
}
