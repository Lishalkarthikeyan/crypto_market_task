import 'package:flutter/material.dart';

import '../core/theme.dart';

class ChangeText extends StatelessWidget {
  final double percent;
  final double size;
  final bool bold;

  const ChangeText({
    super.key,
    required this.percent,
    this.size = 14,
    this.bold = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.change(percent);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          percent >= 0 ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          color: color,
          size: size + 8,
        ),
        Text(
          '${percent.abs().toStringAsFixed(2)}%',
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            fontFeatures: Tabular.features,
          ),
        ),
      ],
    );
  }
}

class ChangeChip extends StatelessWidget {
  final double percent;
  final bool large;

  const ChangeChip({super.key, required this.percent, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.change(percent);

    return Container(
      padding: EdgeInsets.fromLTRB(large ? 6 : 2, 3, large ? 12 : 8, 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ChangeText(percent: percent, size: large ? 15 : 13),
    );
  }
}
