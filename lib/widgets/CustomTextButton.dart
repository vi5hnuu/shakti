import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool? isLoading;
  final bool? isDisabled;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Widget child;

  const CustomTextButton({super.key,this.isDisabled,this.backgroundColor,this.disabledBackgroundColor,required this.onPressed, required this.child,this.isLoading});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading!=true && isDisabled!=true ? onPressed : null,
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          disabledBackgroundColor: disabledBackgroundColor ?? Colors.grey.withValues(alpha: 0.2),
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.2),
          textStyle: TextStyle(color:Colors.black)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if(isLoading==true) ...[const SizedBox(width: 10),SpinKitCircle(color: Theme.of(context).primaryColor,size: 20)],
        ],
      ),
    );
  }
}
