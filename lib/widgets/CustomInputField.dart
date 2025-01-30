import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField(
      {super.key,
      this.controller,
      this.labelText,
      this.hintText,
      this.initialValue,
      this.autoCorrect = true,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.obscureText = false,
      this.obscureCharacter = '*',
      this.suffixIcon,
      this.enabled = true});

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool autoCorrect;
  final bool autofocus;
  final String? initialValue;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final String obscureCharacter;
  final Icon? suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.7)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
          ),
          suffixIconColor: Colors.orangeAccent,
          suffixIcon: suffixIcon,
          alignLabelWithHint: true,
          hintText: hintText,
          labelText: labelText,
          enabled: this.enabled,
          contentPadding: const EdgeInsets.all(18)),
      controller: controller,
      autocorrect: autoCorrect,
      autofocus: autofocus,
      keyboardType: keyboardType,
      initialValue: initialValue,
      maxLines: 1,
      validator: validator,
      obscureText: obscureText,
      obscuringCharacter: obscureCharacter,
    );
  }
}
