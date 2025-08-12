import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildFormField({
  required String label,
  required TextEditingController controller,
  bool? obscureText,
  bool? showToggle,
  VoidCallback? onToggle,
  String? errorText,
  Animation<double>? animation,
  TextInputType? keyboardType,
  bool? isValid,
  bool? enabled,
  String? hintText,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildShakingField(
        animation: animation,
        child: TextFormField(
          controller: controller,
          enabled: enabled ?? true,
          obscureText: obscureText ?? false,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Color(0xFF858484).withValues(alpha: 0.1),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Validation checkmark icon
                if (isValid != null && controller.text.isNotEmpty)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      isValid ? Icons.check : Icons.close,
                      color: isValid ? Colors.green : Colors.red,
                      size: 30,
                    ),
                  ),
                if (controller.text.isNotEmpty) SizedBox(width: 8),
                if (showToggle ?? false)
                  IconButton(
                    icon: Icon(
                      (obscureText ?? false) ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: onToggle,
                  )
                else SizedBox(width: 48), //PassToggle
              ],
            ),
          ),
          keyboardType: keyboardType,
        ),
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 8),
          child: Text(errorText, style: TextStyle(color: Colors.red)),
        ),
    ],
  );
}

Widget _buildShakingField({
  Animation<double>? animation,
  required Widget child,
}) {
  if (animation == null) return child;

  return AnimatedBuilder(
    animation: animation,
    builder: (context, childWidget) => Transform.translate(
      offset: Offset(animation.value, 0),
      child: childWidget,
    ),
    child: child,
  );
}