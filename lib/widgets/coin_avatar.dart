import 'package:flutter/material.dart';

import '../core/constants.dart';

class CoinAvatar extends StatelessWidget {
  final String base;
  final double size;

  const CoinAvatar({super.key, required this.base, this.size = 40});

  static const List<Color> _palette = [
    Color(0xFF3861FB),
    Color(0xFFF7931A),
    Color(0xFF16C784),
    Color(0xFF8247E5),
    Color(0xFFE84142),
    Color(0xFF00A3FF),
    Color(0xFFF3BA2F),
    Color(0xFF14B8A6),
  ];

  Widget _fallback() {
    final seed = base.codeUnits.fold<int>(0, (sum, c) => sum + c);
    final color = _palette[seed % _palette.length];
    final label = base.length > 3 ? base.substring(0, 3) : base;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.network(
          AppConstants.iconUrl(base),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (context, child, progress) {
            return progress == null ? child : _fallback();
          },
        ),
      ),
    );
  }
}
