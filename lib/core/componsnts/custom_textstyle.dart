import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? lineHeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final VoidCallback? onTap;

  const CustomText({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.lineHeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.onTap,
  });

  TextStyle get style {
    double? computedHeight;
    if (fontSize != null && lineHeight != null) {
      computedHeight = lineHeight! / fontSize!;
    }

    return TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.normal,
      fontFamily: fontFamily ?? 'Montserrat',
      height: computedHeight,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null ? null : (overflow ?? TextOverflow.ellipsis),
      ),
    );
  }
}

TextStyle getCustomTextStyle({
  Color? color,
  double? fontSize,
  FontWeight? fontWeight,
  String? fontFamily,
  double? height,
  TextOverflow? overflow,
  TextDecoration? decoration,
}) {
  double? calculateLineHeight() {
    if (height != null && fontSize != null) {
      return height / fontSize;
    }
    return null;
  }

  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontFamily: "Montserrat",
    height: calculateLineHeight(),
    overflow: overflow,
    decoration: decoration,
  );
}

class CustomTextFieldTitle extends StatelessWidget {
  final String title;
  const CustomTextFieldTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: title,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      lineHeight: 16,
      color: const Color(0xff343434),
    );
  }
}
