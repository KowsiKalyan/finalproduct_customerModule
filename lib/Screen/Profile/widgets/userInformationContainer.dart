import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/Profile/widgets/editProfileBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Helper/String.dart';
import '../../../Helper/routes.dart';
import '../../../Provider/UserProvider.dart';
import '../../../widgets/bottomSheet.dart';
import '../../../widgets/desing.dart';
import '../../Language/languageSettings.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({Key? key}) : super(key: key);

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10.0, top: 10),
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          start: 10.0,
        ),
        child: Row(
          children: [
            Selector<UserProvider, String>(
              selector: (_, provider) => provider.profilePic,
              builder: (context, profileImage, child) {
                return getUserImage(
                    profileImage, context, () => openEditBottomSheet(context));
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
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
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
                                    color:
                                        Theme.of(context).colorScheme.fontColor,
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
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
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
                            padding: const EdgeInsetsDirectional.only(top: 7),
                            child: InkWell(
                              child: Text(
                                getTranslated(context, 'LOGIN_REGISTER_LBL')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                      color: colors.primary,
                                      decoration: TextDecoration.underline,
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
