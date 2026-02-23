import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/app_theme.dart';

class CustomTextBox extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final String? label;
  final TextStyle? textStyle;
  final double? width;
  final double? height;

  const CustomTextBox({
    super.key,
    this.hintText = 'Enter your text here...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.label,
    this.textStyle,
    this.width,
    this.height,
  });

  @override
  State<CustomTextBox> createState() => _CustomTextBoxState();
}

class _CustomTextBoxState extends State<CustomTextBox> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _validateField(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
        _hasError = _errorText != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _hasError ? Colors.red : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasError
                  ? Colors.red
                  : _isFocused
                  ? AppTheme.mainColor
                  : Colors.grey[300]!,
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: AppTheme.mainColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? AppTheme.mainColor : Colors.grey[400],
                      size: 20,
                    ),
                    child: widget.prefixIcon!,
                  ),
                ),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: widget.obscureText,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  maxLength: widget.maxLength,
                  keyboardType: widget.keyboardType,
                  textCapitalization: widget.textCapitalization,
                  autofocus: widget.autofocus,
                  inputFormatters: widget.inputFormatters,
                  onChanged: (value) {
                    _validateField(value);
                    widget.onChanged?.call(value);
                  },
                  onSubmitted: widget.onSubmitted,
                  style: widget.textStyle ??
                      TextStyle(
                        fontSize: 16,
                        color: widget.enabled ? Colors.black87 : Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 8 : 16,
                      vertical: 14,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              if (widget.suffixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconTheme(
                    data: IconThemeData(
                      color: _isFocused ? AppTheme.mainColor : Colors.grey[400],
                      size: 20,
                    ),
                    child: widget.suffixIcon!,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_hasError && _errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
Widget myTextBox({
  String? hintText,
  TextEditingController? controller,
  Function(String)? onChanged,
  bool obscureText = false,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? label,
}) {
  return CustomTextBox(
    hintText: hintText,
    controller: controller,
    onChanged: onChanged,
    obscureText: obscureText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    label: label,
  );
}