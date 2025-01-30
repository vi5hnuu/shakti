import 'package:flutter/material.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required List<TextEditingController> otpcontrollers,
    required List<FocusNode> focusNodes,
  }) : _otpcontrollers = otpcontrollers, _focusNodes = focusNodes;

  final List<TextEditingController> _otpcontrollers;
  final List<FocusNode> _focusNodes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _otpcontrollers.length,
            (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: (index == 5 ? 0 : 5.0)),
            child: TextField(
              controller: _otpcontrollers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
              focusNode: _focusNodes[index],
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
