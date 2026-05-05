import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_insight/app/config/app_colors.dart';

class ResultDialog {
  /// Shows a success dialog with a checkmark animation, then navigates back
  static Future<void> success({
    required String title,
    String? message,
    bool navigateBack = true,
    VoidCallback? onDismiss,
  }) async {
    await Get.dialog(
      _ResultDialogWidget(
        type: _ResultType.success,
        title: title,
        message: message,
      ),
      barrierDismissible: false,
    );
    if (navigateBack) {
      Get.back();
    }
    onDismiss?.call();
  }

  /// Shows an error dialog
  static Future<void> error({
    required String title,
    String? message,
  }) async {
    await Get.dialog(
      _ResultDialogWidget(
        type: _ResultType.error,
        title: title,
        message: message,
      ),
      barrierDismissible: true,
    );
  }

  /// Shows a warning dialog
  static Future<void> warning({
    required String title,
    String? message,
  }) async {
    await Get.dialog(
      _ResultDialogWidget(
        type: _ResultType.warning,
        title: title,
        message: message,
      ),
      barrierDismissible: true,
    );
  }
}

enum _ResultType { success, error, warning }

class _ResultDialogWidget extends StatefulWidget {
  final _ResultType type;
  final String title;
  final String? message;

  const _ResultDialogWidget({
    required this.type,
    required this.title,
    this.message,
  });

  @override
  State<_ResultDialogWidget> createState() => _ResultDialogWidgetState();
}

class _ResultDialogWidgetState extends State<_ResultDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    // Auto dismiss success after 1.8 seconds
    if (widget.type == _ResultType.success) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted && Get.isDialogOpen == true) {
          Get.back();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Theme.of(context).cardTheme.color,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [config.color, config.colorDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: config.color.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(config.icon, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.message!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Only show button for error/warning (success auto-dismisses)
                if (widget.type != _ResultType.success) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: config.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _DialogConfig _getConfig() {
    switch (widget.type) {
      case _ResultType.success:
        return _DialogConfig(
          icon: Icons.check_rounded,
          color: AppColors.income,
          colorDark: const Color(0xFF059669),
        );
      case _ResultType.error:
        return _DialogConfig(
          icon: Icons.close_rounded,
          color: AppColors.expense,
          colorDark: const Color(0xFFDC2626),
        );
      case _ResultType.warning:
        return _DialogConfig(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          colorDark: const Color(0xFFD97706),
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color color;
  final Color colorDark;

  _DialogConfig({
    required this.icon,
    required this.color,
    required this.colorDark,
  });
}

