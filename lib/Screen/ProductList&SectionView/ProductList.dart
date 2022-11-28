import 'dart:async';
import 'dart:math';
import 'package:eshop_multivendor/Provider/explore_provider.dart';
import 'package:eshop_multivendor/Screen/ProductList&SectionView/Widget/ListcompareGrid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../Provider/productListProvider.dart';
import '../../widgets/ButtonDesing.dart';
import '../../widgets/appBar.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/simmerEffect.dart';
import '../../widgets/snackbar.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import '../Product Detail/Widget/commanFiledsofProduct.dart';
import 'Widget/ListcompareList.dart';
import 'Widget/priceRangeWidget.dart';

class ProductList extends StatefulWidget {
  final String? name, id;
  final bool? tag, fromSeller;
  final int? dis;

  const ProductList(
      {Key? key, this.id, this.name, this.tag, this.fromSeller, this.dis})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

String? totalProduct;
bool isProgress = false;
final List<TextEditingController> controllerText = [];
RangeValues? currentRangeValues;

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Product> productList = [];
  List<Product> tempList = [];
  String sortBy = '', orderBy = 'DESC';
  int offset = 0;
  int total = 0;

  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  var filterList;
  String minPrice = '0', maxPrice = '0';
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  List<String> selectedId = [];
  bool _isFirstLoad = true;
  String selId = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;

  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;

  AnimationController? _animationController;
  AnimationController? _animationController1;

  late AnimationController listViewIconController;

  late StateSetter setStater;
  String query = '';
  String lastWords = '';
  String lastStatus = '';
  FocusNode searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  final SpeechToText speech = SpeechToText();
  final TextEditingController searchController = TextEditingController();
  bool notificationisnodata = false;
  List<LocaleName> _localeNames = [];
  String _currentLocaleId = '';

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          query = '';
          offset = 0;
          isLoadingmore = true;
          getProduct('0');
        });
      } else {
        query = searchController.text;
        offset = 0;
        notificationisnodata = false;

        if (query.trim().isNotEmpty) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (query.trim().isNotEmpty) {
              isLoadingmore = true;
              offset = 0;
              getProduct('0');
            }
          });
        }
      }
      ScaffoldMessenger.of(context).clearSnackBars();
    });
    getProduct('0');

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));

    listViewIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              isLoadingmore = true;
              if (offset < total) getProduct('0');
            },
          );
        }
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _animationController!.dispose();
    _animationController1!.dispose();
    listViewIconController.dispose();
    controller.removeListener(() {});
    searchController.dispose();

    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNow() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromSeller!
          ? null
          : getAppBar(
              widget.name!,
              context,
              setStateNow,
            ),
      key: _scaffoldKey,
      body: isNetworkAvail
          ? Stack(
              children: <Widget>[
                _showForm(),
                DesignConfiguration.showCircularProgress(
                  isProgress,
                  colors.primary,
                ),
              ],
            )
          : NoInterNet(
              setStateNoInternate: setStateNoInternate,
              buttonSqueezeanimation: buttonSqueezeanimation,
              buttonController: buttonController,
            ),
    );
  }

  setStateNoInternate() async {
    _playAnimation();
    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          offset = 0;
          total = 0;
          getProduct('0');
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

  void getProduct(String top) {
    if (mounted) {
      setState(
        () {
          isLoadingmore = false;
          if (searchController.hasListeners &&
              searchController.text.isNotEmpty) {
            _isLoading = true;
          }
        },
      );
    }

    Map parameter = {
      SEARCH: query.trim(),
      LIMIT: perPage.toString(),
      OFFSET: offset.toString(),
      TOP_RETAED: top,
    };
    if (selId != '') {
      parameter[ATTRIBUTE_VALUE_ID] = selId;
    }
    if (widget.tag!) parameter[TAG] = widget.name!;
    if (widget.fromSeller!) {
      parameter['seller_id'] = widget.id!;
    } else {
      parameter[CATID] = widget.id ?? '';
    }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    if (widget.dis != null) {
      parameter[DISCOUNT] = widget.dis.toString();
    } else {
      parameter[SORT] = sortBy;
      parameter[ORDER] = orderBy;
    }

    if (currentRangeValues != null &&
        currentRangeValues!.start.round().toString() != '0') {
      parameter[MINPRICE] = currentRangeValues!.start.round().toString();
    }

    if (currentRangeValues != null &&
        currentRangeValues!.end.round().toString() != '0') {
      parameter[MAXPRICE] = currentRangeValues!.end.round().toString();
    }
    context.read<ProductListProvider>().setProductListParameter(parameter);
    tempList.clear();
    // productList.clear();

    Future.delayed(Duration.zero).then(
      (value) => context.read<ProductListProvider>().getProductList().then(
        (
          value,
        ) async {
          bool error = value['error'];
          String? msg = value['message'];
          if (offset == 0) notificationisnodata = error;
          if (!error) {
            tempList.clear();
            total = int.parse(value['total']);
            if (_isFirstLoad) {
              filterList = value['filters'];
              minPrice = value[MINPRICE].toString();
              maxPrice = value[MAXPRICE].toString();
              _isFirstLoad = false;
            }
            if ((offset) < total) {
              tempList.clear();
              var data = value['data'];
              tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              if (value.containsKey(TAG)) {
                List<String> tempList = List<String>.from(value[TAG]);
                if (tempList.isNotEmpty) tagList = tempList;
              }
              getAvailVarient();
              offset = offset + perPage;
            } else {
              if (msg != 'Products Not Found !') setSnackbar(msg!, context);
              isLoadingmore = false;
              notificationisnodata = true;
            }
          } else {
            isLoadingmore = false;
            if (msg != 'Products Not Found !') setSnackbar(msg!, context);
            notificationisnodata = true;
          }

          setState(
            () {
              _isLoading = false;
            },
          );
        },
      ),
    );
  }

  void getAvailVarient() {
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
    productList.addAll(tempList);
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
                        top: 19.0,
                        bottom: 16.0,
                      ),
                      child: Text(
                        getTranslated(context, 'SORT_BY')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  getDivider(3, context),
                  InkWell(
                    onTap: () {
                      sortBy = '';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
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
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'p.date_added';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
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
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'p.date_added';
                      orderBy = 'ASC';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
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
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'pv.price';
                      orderBy = 'ASC';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
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
                        ),
                      ),
                    ),
                    onTap: () {
                      sortBy = 'pv.price';
                      orderBy = 'DESC';
                      if (mounted) {
                        setState(
                          () {
                            _isLoading = true;
                            total = 0;
                            offset = 0;
                            productList.clear();
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

  _showForm() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      height: 44,
                      child: TextField(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.normal,
                        ),
                        controller: searchController,
                        autofocus: false,
                        focusNode: searchFocusNode,
                        enabled: true,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.gray),
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          fillColor: Theme.of(context).colorScheme.lightWhite,
                          filled: true,
                          isDense: true,
                          hintText: getTranslated(context, 'searchHint'),
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Icon(Icons.search),
                          ),
                          suffixIcon: searchController.text != ''
                              ? IconButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    searchController.text = '';
                                    query = '';
                                    offset = 0;
                                    isLoadingmore = true;
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: colors.primary,
                                  ),
                                )
                              : InkWell(
                                  child: const Icon(
                                    Icons.mic,
                                    color: colors.primary,
                                  ),
                                  onTap: () {
                                    lastWords = '';
                                    if (!_hasSpeech) {
                                      initSpeechState();
                                    } else {
                                      showSpeechDialog();
                                    }
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.fromSeller!) Container() else _tags(),
              sortAndFilterOption(),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const ShimmerEffect()
              : productList.isEmpty || notificationisnodata
                  ? DesignConfiguration.getNoItem(context)
                  : context.watch<ExploreProvider>().getCurrentView !=
                          'GridView'
                      ? NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: ListView.builder(
                            controller: controller,
                            shrinkWrap: true,
                            itemCount: (offset < total)
                                ? productList.length + 1
                                : productList.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return (index == productList.length &&
                                      isLoadingmore)
                                  ? const SingleItemSimmer()
                                  : ListIteamListWidget(
                                      index: index,
                                      productList: productList,
                                      length: productList.length,
                                      setState: setStateNow,
                                    );
                            },
                          ),
                        )
                      : NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: GridView.count(
                            padding: const EdgeInsetsDirectional.only(top: 5),
                            crossAxisCount: 2,
                            controller: controller,
                            childAspectRatio: 0.6,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: List.generate(
                              (offset < total)
                                  ? productList.length + 1
                                  : productList.length,
                              (index) {
                                return (index == productList.length &&
                                        isLoadingmore)
                                    ? const SimmerSingleProduct()
                                    : GridViewProductListWidget(
                                        pad: index % 2 == 0 ? true : false,
                                        index: index,
                                        productList: productList,
                                        setState: setStateNow,
                                      );
                              },
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _tags() {
    if (tagList != null && tagList!.isNotEmpty) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i],
              style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (mounted) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(
                      name: tagList![i],
                      tag: true,
                      fromSeller: false,
                    ),
                  ));
            }
          },
        );

        chips.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: chips),
      );
    } else {
      return Container();
    }
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
                            fontSize: textFontSize12),
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
                        if (productList.isNotEmpty) {
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
                  const Text(' | '),
                  GestureDetector(
                    onTap: filterDialog,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_alt_outlined,
                        ),
                        Text(
                          getTranslated(context, 'FILTER')!,
                          style: TextStyle(
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

  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords.replaceAll(' ', '');
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then(
        (_) async {
          clearAll();

          searchController.text = lastWords;
          searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: searchController.text.length));

          setState(() {});
          Navigator.of(context).pop();
        },
      );
    }
  }

  clearAll() {
    setState(() {
      query = searchController.text;
      offset = 0;
      isLoadingmore = true;
      productList.clear();
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      setSnackbar(error.errorMsg, context);
    });
  }

  void statusListener(String status) {
    setStater(() {
      lastStatus = status;
    });
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
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
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
              'Search for desired product',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
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
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(lastWords),
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
                                    fontWeight: FontWeight.bold),
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

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        // currentRangeValues =
        //     RangeValues(double.parse(minPrice), double.parse(maxPrice));
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
                            padding:
                                const EdgeInsetsDirectional.only(top: 10.0),
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
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                        FontWeight.normal),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    currentRangeValues != null
                                        ? RangeSlider(
                                            values: currentRangeValues!,
                                            min: double.parse(minPrice),
                                            max: double.parse(maxPrice),
                                            divisions: 10,
                                            labels: RangeLabels(
                                              currentRangeValues!.start
                                                  .round()
                                                  .toString(),
                                              currentRangeValues!.end
                                                  .round()
                                                  .toString(),
                                            ),
                                            onChanged: (RangeValues values) {
                                              currentRangeValues = values;
                                              setState(() {});
                                            },
                                          )
                                        : Container(),
                                  ],
                                );
                              } else {
                                index = index - 1;
                                attsubList = filterList[index]
                                        ['attribute_values']
                                    .split(',');

                                attListId = filterList[index]
                                        ['attribute_values_id']
                                    .split(',');

                                List<Widget?> chips = [];
                                List<String> att = filterList[index]
                                        ['attribute_values']!
                                    .split(',');

                                List<String> attSType = filterList[index]
                                        ['swatche_type']
                                    .split(',');

                                List<String> attSValue = filterList[index]
                                        ['swatche_value']
                                    .split(',');

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
                                          int.parse(
                                            color,
                                          ),
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
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        att[i],
                                        style: TextStyle(
                                          color:
                                              selectedId.contains(attListId![i])
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
                                        selectedId.contains(attListId![i]),
                                    label: itemLabel,
                                    labelPadding: const EdgeInsets.all(0),
                                    selectedColor: colors.primary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        attSType[i] == '1' ? 100 : 10,
                                      ),
                                      side: BorderSide(
                                          color:
                                              selectedId.contains(attListId![i])
                                                  ? colors.primary
                                                  : colors.black12,
                                          width: 1.5),
                                    ),
                                    onSelected: (bool selected) {
                                      attListId = filterList[index]
                                              ['attribute_values_id']
                                          .split(',');

                                      if (mounted) {
                                        setState(
                                          () {
                                            if (selected == true) {
                                              selectedId.add(attListId![i]);
                                            } else {
                                              selectedId.remove(attListId![i]);
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .fontColor,
                                                  fontWeight: FontWeight.normal,
                                                ),
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
                                                        const EdgeInsets.all(
                                                      2.0,
                                                    ),
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
                  ),
                ),
                Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 20),
                        width: deviceWidth! * 0.4,
                        child: OutlinedButton(
                          onPressed: () {
                            selectedId = [];
                            setState(() {});
                            if (mounted) {}
                          },
                          child: Text(
                            getTranslated(context, 'DISCARD')!,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        child: SimBtn(
                          borderRadius: circularBorderRadius5,
                          size: 0.4,
                          title: getTranslated(context, 'APPLY'),
                          onBtnSelected: () {
                            selId = selectedId.join(',');

                            if (mounted) {
                              setState(
                                () {
                                  _isLoading = true;
                                  total = 0;
                                  offset = 0;
                                  productList.clear();
                                },
                              );
                            }
                            getProduct('0');
                            Navigator.pop(context, 'Product Filter');
                          },
                        ),
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
}
