import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';

class RangeBar extends StatelessWidget {
  final String title;
  final double low;
  final double high;
  final double current;

  const RangeBar({
    super.key,
    required this.title,
    required this.low,
    required this.high,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final span = high - low;
    final position = span <= 0 ? 0.5 : ((current - low) / span).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 14,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [AppColors.down, AppColors.gold, AppColors.up],
                      ),
                    ),
                  ),
                  Positioned(
                    left: (width - 14) * position,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.onSurface,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Fmt.price(low),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: Tabular.features,
              ),
            ),
            Text(
              Fmt.price(high),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: Tabular.features,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
