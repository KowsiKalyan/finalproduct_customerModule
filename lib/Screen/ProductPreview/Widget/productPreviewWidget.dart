import 'package:flutter/material.dart';
import '../../../Helper/Color.dart';

class IOSRundedButton extends StatelessWidget {
  const IOSRundedButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      top: 39.0,
      start: 11.0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1a0400ff),
                    offset: Offset(0, 0),
                    blurRadius: 30)
              ],
              color: Theme.of(context).colorScheme.white,
              borderRadius: BorderRadius.circular(7),
            ),
            width: 33,
            height: 33,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
