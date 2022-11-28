import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Helper/Color.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? size;
  double? height;
  Color? backgroundColor, borderColor, titleFontColor;
  double? borderWidth, borderRadius;

  SimBtn({
    Key? key,
    this.title,
    this.onBtnSelected,
    this.size,
    this.height,
    this.titleFontColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * size!;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      child: Container(
        width: size,
        height: height ?? 35,
        alignment: FractionalOffset.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1]),
          color: backgroundColor ?? colors.primary,
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius ?? 0.0,
            ),
          ),
          border: Border.all(
            width: borderWidth ?? 0,
            color: borderColor ?? Colors.transparent,
          ),
        ),
        child: Text(
          title!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: titleFontColor ?? colors.whiteTemp,
                fontWeight: FontWeight.normal,
                fontFamily: 'ubuntu',
              ),
        ),
      ),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}

// appbtn

class AppBtn extends StatelessWidget {
  final String? title;
  final AnimationController? btnCntrl;
  final Animation? btnAnim;
  final VoidCallback? onBtnSelected;

  const AppBtn({
    Key? key,
    this.title,
    this.btnCntrl,
    this.btnAnim,
    this.onBtnSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildBtnAnimation,
      animation: btnCntrl!,
    );
  }

  Widget _buildBtnAnimation(BuildContext context, Widget? child) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: CupertinoButton(
        child: Container(
          width: btnAnim!.value,
          height: 45,
          alignment: FractionalOffset.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.grad1Color, colors.grad2Color],
              stops: [0, 1],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(
                10.0,
              ),
            ),
          ),
          child: btnAnim!.value > 75.0
              ? Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: colors.whiteTemp,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'ubuntu',
                      ),
                )
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.whiteTemp,
                  ),
                ),
        ),
        onPressed: () {
          onBtnSelected!();
        },
      ),
    );
  }
}
