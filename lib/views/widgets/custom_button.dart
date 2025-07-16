import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double elevation;
  final bool isOutlined;
  final TextStyle? textStyle;
  final Widget? icon;
  final MainAxisAlignment iconAlignment;
  final double gapBetweenIconAndText;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 48.0,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.elevation = 0,
    this.isOutlined = false,
    this.textStyle,
    this.icon,
    this.iconAlignment = MainAxisAlignment.center,
    this.gapBetweenIconAndText = 8.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: color,
            side: BorderSide(color: borderColor ?? color, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: elevation,
            minimumSize: Size(width ?? double.infinity, height!),
            textStyle: textStyle ??
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: onPressed == null || isLoading 
                ? color.withOpacity(0.5)
                : color,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            elevation: elevation,
            shadowColor: color.withOpacity(0.3),
            minimumSize: Size(width ?? double.infinity, height!),
            textStyle: textStyle ??
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          );

    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        );
      }

      if (icon == null) {
        return Text(text, textAlign: TextAlign.center);
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: iconAlignment,
        children: [
          icon!,
          SizedBox(width: gapBetweenIconAndText),
          Text(text),
        ],
      );
    }

    return icon == null || isLoading
        ? ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          )
        : SizedBox(
            width: width ?? double.infinity,
            height: height,
            child: isOutlined
                ? OutlinedButton(
                    onPressed: isLoading ? null : onPressed,
                    style: buttonStyle,
                    child: buildContent(),
                  )
                : ElevatedButton(
                    onPressed: isLoading ? null : onPressed,
                    style: buttonStyle,
                    child: buildContent(),
                  ),
          );
  }
}