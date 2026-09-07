import 'package:flutter/material.dart';

import '../theme/brutal_theme.dart';

/// Botón con el gesto característico del Neo-Brutalism: al presionar se
/// desplaza hacia su propia sombra dura (que no tiene blur), simulando que
/// se "hunde" en la superficie.
class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color color;
  final Color textColor;

  const BrutalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.color = BrutalColors.ink,
    this.textColor = BrutalColors.cream,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  static const _restOffset = Offset(6, 6);
  static const _pressedOffset = Offset(2, 2);

  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _setPressed(bool value) {
    if (_enabled) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? _pressedOffset : _restOffset;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _restOffset.dx - offset.dx,
          _restOffset.dy - offset.dy,
          0,
        ),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _enabled ? widget.color : widget.color.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BrutalColors.ink, width: 3),
          boxShadow: [BoxShadow(color: BrutalColors.ink, offset: offset, blurRadius: 0)],
        ),
        child: Center(
          child: widget.loading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: widget.textColor),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}
