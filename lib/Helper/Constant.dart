import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';

//Your application name
const String appName = 'eShop Multi';

//Your package name
const String packageName = 'eShop.multivendor.customer';
const String iosPackage = 'eShop.multivendor.customer';

//Playstore link of your application
const String androidLink = 'https://play.google.com/store/apps/details?id=';

//Appstore link of your application
const String iosLink = 'your ios link here';

//Appstore id
const String appStoreId = '123456789';

//Link for share product (get From Firebase)
const String deepLinkUrlPrefix = 'https://eshopmultivendor.page.link';
const String deepLinkName = 'eshop';

//Set labguage
String defaultLanguage = 'en';

//Set country code
String defaultCountryCode = 'IN';

//Time settings
const int timeOut = 50;
const int perPage = 10;

//FontSize
const double textFontSize10 = 10;
const double textFontSize12 = 12;
const double textFontSize14 = 14;
const double textFontSize16 = 16;

//Radius
const double circularBorderRadius5 = 5;
const double circularBorderRadius7 = 7;
const double circularBorderRadius10 = 10;

//Token ExpireTime in minutes & issuer name
const int tokenExpireTime = 5;
const String issuerName = 'eshop';

//General Error Message
const String errorMesaage = 'Something went wrong, Error : ';

//Bank detail hint text
const String BANK_DETAIL =
    'Bank Details:\nAccount No :123XXXXX\nIFSC Code: 123XXX \nName: Abc xyz';

//Api class instance
ApiBaseHelper apiBaseHelper = ApiBaseHelper();

// CREDENTIAL FOR CONNECT APP TO ADMIN PANEL
const String baseUrl = 'https://shop.pondicherryshopping.com/app/v1/api/';
const String jwtKey = '1e3f3dc82ff1d7d755eb93f94e24602395089c41';
