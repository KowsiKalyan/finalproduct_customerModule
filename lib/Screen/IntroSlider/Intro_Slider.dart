import 'package:eshop_multivendor/Screen/IntroSlider/Widgets/SliderClass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Helper/String.dart';
import '../../widgets/systemChromeSettings.dart';
import '../Language/languageSettings.dart';
import 'Widgets/AllBtn.dart';
import 'Widgets/SetSlider.dart';

class IntroSlider extends StatefulWidget {
  const IntroSlider({Key? key}) : super(key: key);

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<IntroSlider>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late List slideList = [];

  @override
  void initState() {
    SystemChromeSettings.setSystemButtomNavigationBarithTopAndButtom();
    SystemChromeSettings.setSystemUIOverlayStyleWithDarkBrightNess();

    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        setState(
          () {
            slideList = [
              Slide(
                imageUrl: 'introimage_a',
                title: getTranslated(context, 'TITLE1_LBL'),
                description: getTranslated(context, 'DISCRIPTION1'),
              ),
              Slide(
                imageUrl: 'introimage_b',
                title: getTranslated(context, 'TITLE2_LBL'),
                description: getTranslated(context, 'DISCRIPTION2'),
              ),
              Slide(
                imageUrl: 'introimage_c',
                title: getTranslated(context, 'TITLE3_LBL'),
                description: getTranslated(context, 'DISCRIPTION3'),
              ),
            ];
          },
        );
      },
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.9,
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
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    buttonController!.dispose();
  }

  _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            skipBtn(
              context,
              _currentPage,
            ),
            slider(
              slideList,
              _pageController,
              context,
              _onPageChanged,
            ),
            SliderBtn(
              currentPage: _currentPage,
              pageController: _pageController,
              sliderList: slideList,
            ),
          ],
        ),
      ),
    );
  }
}
