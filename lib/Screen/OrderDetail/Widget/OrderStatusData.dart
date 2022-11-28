import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';
import '../../../Helper/String.dart';
import '../../../Model/Order_Model.dart';
import '../../Language/languageSettings.dart';

getPlaced(String pDate, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Icon(
        Icons.circle,
        color: colors.primary,
        size: 15,
      ),
      Container(
        margin: const EdgeInsetsDirectional.only(start: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslated(context, 'ORDER_NPLACED')!,
              style: const TextStyle(fontSize: 8),
            ),
            Text(
              pDate,
              style: const TextStyle(fontSize: 8),
            ),
          ],
        ),
      ),
    ],
  );
}

getProcessed(String? prDate, String? cDate, BuildContext context) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: prDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: prDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_PROCESSED')!,
                    style: const TextStyle(fontSize: 8),
                  ),
                  Text(
                    prDate ?? ' ',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        )
      : prDate == null
          ? Container()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_PROCESSED')!,
                        style: const TextStyle(fontSize: 8),
                      ),
                      Text(
                        prDate,
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

getShipped(String? sDate, String? cDate, BuildContext context) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: sDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: sDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_SHIPPED')!,
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    sDate ?? ' ',
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
          ],
        )
      : sDate == null
          ? Container()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: const [
                    SizedBox(
                      height: 30,
                      child: VerticalDivider(
                        thickness: 2,
                        color: colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.circle,
                      color: colors.primary,
                      size: 15,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, 'ORDER_SHIPPED')!,
                        style: const TextStyle(fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        sDate,
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            );
}

getDelivered(String? dDate, String? cDate, BuildContext context) {
  return cDate == null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: dDate == null ? Colors.grey : colors.primary,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: dDate == null ? Colors.grey : colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_DELIVERED')!,
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dDate ?? ' ',
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : Container();
}

getCanceled(String? cDate, BuildContext context) {
  return cDate != null
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: const [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_CANCLED')!,
                    style: const TextStyle(fontSize: 8),
                  ),
                  Text(
                    cDate,
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : Container();
}

getReturned(
  OrderItem item,
  String? rDate,
  OrderModel model,
  BuildContext context,
) {
  return item.listStatus!.contains(RETURNED)
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: const [
                SizedBox(
                  height: 30,
                  child: VerticalDivider(
                    thickness: 2,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.cancel_rounded,
                  color: colors.primary,
                  size: 15,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, 'ORDER_RETURNED')!,
                    style: const TextStyle(fontSize: 8),
                  ),
                  Text(
                    rDate ?? ' ',
                    style: const TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        )
      : Container();
}
