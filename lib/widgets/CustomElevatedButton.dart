import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final bool? isLoading;
  final bool? isDisabled;
  final Color? disabledBackgroundColor;

  const CustomElevatedButton({super.key,this.isLoading,this.isDisabled,this.disabledBackgroundColor,required this.onPressed, required this.child,this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading==true && isDisabled!=true ? null : onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          disabledBackgroundColor: disabledBackgroundColor ?? Colors.grey.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [child,
        if(isLoading==true) ...[const SizedBox(width: 10),SpinKitCircle(color: Theme.of(context).primaryColor,size: 20)],
      ],),
    );
  }
}
