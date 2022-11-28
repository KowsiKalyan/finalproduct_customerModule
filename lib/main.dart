import 'dart:io';
import 'package:country_code_picker/country_localizations.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/Favourite/UpdateFavProvider.dart';
import 'package:eshop_multivendor/Provider/NotificationProvider.dart';
import 'package:eshop_multivendor/Provider/ProductProvider.dart';
import 'package:eshop_multivendor/Provider/Search/SearchProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Provider/explore_provider.dart';
import 'package:eshop_multivendor/Provider/authenticationProvider.dart';
import 'package:eshop_multivendor/Provider/myWalletProvider.dart';
import 'package:eshop_multivendor/Provider/paymentProvider.dart';
import 'package:eshop_multivendor/Screen/SplashScreen/Splash.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/String.dart';
import 'Screen/Language/Demo_Localization.dart';
import 'Screen/PushNotification/PushNotificationService.dart';
import 'Provider/FaqsProvider.dart';
import 'Provider/Favourite/FavoriteProvider.dart';
import 'Provider/ManageAddressProvider.dart';
import 'Provider/Order/OrderProvider.dart';
import 'Provider/Order/UpdateOrderProvider.dart';
import 'Provider/addressProvider.dart';
import 'Provider/chatProvider.dart';
import 'Provider/customerSupportProvider.dart';
import 'Provider/homePageProvider.dart';
import 'Provider/productDetailProvider.dart';
import 'Provider/ReviewGallleryProvider.dart';
import 'Provider/ReviewPreviewProvider.dart';
import 'Provider/Theme.dart';
import 'Provider/SettingProvider.dart';
import 'Provider/faqProvider.dart';
import 'Provider/productListProvider.dart';
import 'Provider/productPrevciewProvider.dart';
import 'Provider/promoCodeProvider.dart';
import 'Provider/pushNotificationProvider.dart';
import 'Provider/sellerDetailProvider.dart';
import 'Provider/systemProvider.dart';
import 'Provider/userWalletProvider.dart';
import 'Provider/writeReviewProvider.dart';
import 'Screen/Dashboard/Dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.instance.getInitialMessage();
  initializedDownload();

  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (BuildContext context) {
        String? theme = prefs.getString(APP_THEME);

        if (theme == DARK) {
          ISDARK = 'true';
        } else if (theme == LIGHT) {
          ISDARK = 'false';
        }

        if (theme == null || theme == '' || theme == DEFAULT_SYSTEM) {
          prefs.setString(APP_THEME, DEFAULT_SYSTEM);
          var brightness = SchedulerBinding.instance.window.platformBrightness;
          ISDARK = (brightness == Brightness.dark).toString();

          return ThemeNotifier(ThemeMode.system);
        }

        return ThemeNotifier(theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
      },
      child: MyApp(sharedPreferences: prefs),
    ),
  );
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted) {
      setState(
        () {
          _locale = locale;
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then(
      (locale) {
        if (mounted) {
          setState(
            () {
              _locale = locale;
            },
          );
        }
      },
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (_locale == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color?>(
            colors.primary,
          ),
        ),
      );
    } else {
      return MultiProvider(
        providers: [
          Provider<SettingProvider>(
            create: (context) => SettingProvider(widget.sharedPreferences),
          ),
          ChangeNotifierProvider<HomePageProvider>(
              create: (context) => HomePageProvider()),
          ChangeNotifierProvider<UserProvider>(
              create: (context) => UserProvider()),
          ChangeNotifierProvider<CategoryProvider>(
              create: (context) => CategoryProvider()),
          ChangeNotifierProvider<ProductDetailProvider>(
              create: (context) => ProductDetailProvider()),
          ChangeNotifierProvider<FavoriteProvider>(
              create: (context) => FavoriteProvider()),
          ChangeNotifierProvider<OrderProvider>(
              create: (context) => OrderProvider()),
          ChangeNotifierProvider<CartProvider>(
              create: (context) => CartProvider()),
          ChangeNotifierProvider<ExploreProvider>(
              create: (context) => ExploreProvider()),
          ChangeNotifierProvider<ProductProvider>(
              create: (context) => ProductProvider()),
          ChangeNotifierProvider<FaqsProvider>(
              create: (context) => FaqsProvider()),
          ChangeNotifierProvider<PromoCodeProvider>(
              create: (context) => PromoCodeProvider()),
          ChangeNotifierProvider<SystemProvider>(
              create: (context) => SystemProvider()),
          ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider()),
          ChangeNotifierProvider<ProductListProvider>(
              create: (context) => ProductListProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(
              create: (context) => AuthenticationProvider()),
          ChangeNotifierProvider<FaQProvider>(
              create: (context) => FaQProvider()),
          ChangeNotifierProvider<ReviewGallaryProvider>(
              create: (context) => ReviewGallaryProvider()),
          ChangeNotifierProvider<ReviewPreviewProvider>(
              create: (context) => ReviewPreviewProvider()),
          ChangeNotifierProvider<UpdateFavProvider>(
              create: (context) => UpdateFavProvider()),
          ChangeNotifierProvider<UserTransactionProvider>(
              create: (context) => UserTransactionProvider()),
          ChangeNotifierProvider<MyWalletProvider>(
              create: (context) => MyWalletProvider()),
          ChangeNotifierProvider<PaymentProvider>(
              create: (context) => PaymentProvider()),
          ChangeNotifierProvider<SellerDetailProvider>(
              create: (context) => SellerDetailProvider()),
          ChangeNotifierProvider<SearchProvider>(
              create: (context) => SearchProvider()),
          ChangeNotifierProvider<PushNotificationProvider>(
              create: (context) => PushNotificationProvider()),
          ChangeNotifierProvider<NotificationProvider>(
              create: (context) => NotificationProvider()),
          ChangeNotifierProvider<ManageAddrProvider>(
              create: (context) => ManageAddrProvider()),
          ChangeNotifierProvider<UpdateOrdProvider>(
              create: (context) => UpdateOrdProvider()),
          ChangeNotifierProvider<WriteReviewProvider>(
              create: (context) => WriteReviewProvider()),
          ChangeNotifierProvider<AddressProvider>(
              create: (context) => AddressProvider()),
          ChangeNotifierProvider<CustomerSupportProvider>(
              create: (context) => CustomerSupportProvider()),
          ChangeNotifierProvider<ProductPreviewProvider>(
              create: (context) => ProductPreviewProvider()),
          ChangeNotifierProvider<ChatProvider>(
              create: (context) => ChatProvider()),
        ],
        child: MaterialApp(
          locale: _locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
            Locale('es', 'ES'),
            Locale('hi', 'IN'),
            Locale('fr', 'FR'),
            Locale('ar', 'DZ'),
            Locale('ru', 'RU'),
            Locale('ja', 'JP'),
            Locale('de', 'DE'),
          ],
          localizationsDelegates: const [
            CountryLocalizations.delegate,
            DemoLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale!.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          title: appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: colors.primary_app,
            ).copyWith(
              secondary: colors.darkIcon,
              brightness: Brightness.light,
            ),
            canvasColor: Theme.of(context).colorScheme.lightWhite,
            cardColor: Theme.of(context).colorScheme.white,
            dialogBackgroundColor: Theme.of(context).colorScheme.white,
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: colors.primary,
                ),
            primarySwatch: colors.primary_app,
            primaryColor: Theme.of(context).colorScheme.lightWhite,
            fontFamily: 'ubuntu',
            brightness: Brightness.light,
            textTheme: TextTheme(
              headline6: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.w600,
              ),
              subtitle1: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
              ),
            ).apply(
              bodyColor: Theme.of(context).colorScheme.fontColor,
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const Splash(),
            '/home': (context) => const Dashboard(),
          },
          darkTheme: ThemeData(
            canvasColor: colors.darkColor,
            cardColor: colors.darkColor2,
            dialogBackgroundColor: colors.darkColor2,
            primaryColor: colors.darkColor,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: colors.darkIcon,
              selectionColor: colors.darkIcon,
              selectionHandleColor: colors.darkIcon,
            ),
            toggleableActiveColor: colors.primary,
            fontFamily: 'ubuntu',
            brightness: Brightness.dark,
            hintColor: colors.white10,
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: colors.secondary,
                ),
            textTheme: TextTheme(
              headline6: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.w600,
              ),
              subtitle1: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
              ),
            ).apply(
              bodyColor: Theme.of(context).colorScheme.fontColor,
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: colors.primary_app,
            ).copyWith(
              secondary: colors.darkIcon,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeNotifier.getThemeMode(),
        ),
      );
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
