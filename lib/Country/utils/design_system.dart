import 'package:flutter/material.dart';

/// Design system for consistent UI across the app
class DesignSystem {
  // Colors
  static const Color primaryBlue = Color(0xFF667EEA);
  static const Color primaryPurple = Color(0xFF764BA2);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, primaryPurple],
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  // Helper function to create colors with alpha
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  // Common glass-morphism decoration
  static BoxDecoration glassDecoration({
    double alpha = 0.15,
    double borderAlpha = 0.2,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: alpha),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderAlpha),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  // Common Widgets
  static Widget modernCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(0),
      padding: padding ?? const EdgeInsets.all(spacingL),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? radiusXXL),
        boxShadow: cardShadow,
      ),
      child: child,
    );
  }

  static Widget modernButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    IconData? icon,
    double? width,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: isPrimary ? primaryGradient : null,
        color: isPrimary ? null : Colors.grey[100],
        borderRadius: BorderRadius.circular(radiusL),
        boxShadow: isPrimary ? buttonShadow : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: isPrimary ? Colors.white : textPrimary)
            : const SizedBox(),
        label: Text(
          text,
          style: TextStyle(
            color: isPrimary ? Colors.white : textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
        ),
      ),
    );
  }

  static Widget modernAppBar({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBackPressed != null
            ? Container(
                margin: const EdgeInsets.all(spacingS),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(radiusM),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: onBackPressed,
                ),
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: actions,
      ),
    );
  }

  static Widget modernSectionHeader({
    required String title,
    required IconData icon,
    Color? iconColor,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(spacingM),
          decoration: BoxDecoration(
            color: (iconColor ?? primaryBlue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radiusL),
          ),
          child: Icon(icon, color: iconColor ?? primaryBlue, size: 24),
        ),
        const SizedBox(width: spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: headingMedium),
              if (subtitle != null) ...[
                const SizedBox(height: spacingXS),
                Text(subtitle, style: bodyMedium),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static Widget modernInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final rowColor = color ?? primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: spacingM),
      padding: const EdgeInsets.all(spacingM),
      decoration: BoxDecoration(
        color: rowColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(radiusL),
        border: Border.all(color: rowColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(spacingS),
            decoration: BoxDecoration(
              color: rowColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radiusM),
            ),
            child: Icon(icon, color: rowColor, size: 20),
          ),
          const SizedBox(width: spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodySmall),
                const SizedBox(height: 2),
                Text(value, style: bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget modernEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onActionPressed,
    String? actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingXXL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(spacingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryBlue.withValues(alpha: 0.1),
                    primaryPurple.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(spacingXL),
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 80,
                color: primaryBlue.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: spacingXL),
            Text(title, style: headingLarge, textAlign: TextAlign.center),
            const SizedBox(height: spacingM),
            Text(subtitle, style: bodyLarge, textAlign: TextAlign.center),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: spacingXXL),
              modernButton(
                text: actionText,
                onPressed: onActionPressed,
                icon: Icons.explore_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
