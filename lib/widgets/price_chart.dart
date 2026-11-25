import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/kline.dart';

class PriceChart extends StatelessWidget {
  final List<Kline> klines;

  const PriceChart({super.key, required this.klines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final up = klines.last.close >= klines.first.open;
    final color = up ? AppColors.up : AppColors.down;

    final spots = [
      for (var i = 0; i < klines.length; i++)
        FlSpot(i.toDouble(), klines[i].close),
    ];

    final lows = klines.map((k) => k.close).reduce((a, b) => a < b ? a : b);
    final highs = klines.map((k) => k.close).reduce((a, b) => a > b ? a : b);
    final padding = (highs - lows) == 0 ? highs * 0.01 : (highs - lows) * 0.1;
    final minY = lows - padding;
    final maxY = highs + padding;
    final gridStep = (maxY - minY) / 4;

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: LineChart(
            duration: const Duration(milliseconds: 250),
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: 0,
              maxX: (klines.length - 1).toDouble(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: gridStep,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.35),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                bottomTitles: const AxisTitles(),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 58,
                    interval: gridStep,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          Fmt.price(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                  getTooltipItems: (touched) {
                    return touched.map((spot) {
                      final item = klines[spot.x.toInt()];
                      return LineTooltipItem(
                        '${Fmt.price(item.close)}\n',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: Fmt.dateTime(item.time),
                            style: TextStyle(
                              color: theme.colorScheme.onInverseSurface
                                  .withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.15,
                  preventCurveOverShooting: true,
                  color: color,
                  barWidth: 2.2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [color.withOpacity(0.28), color.withOpacity(0)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 58),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Fmt.dateTime(klines.first.time),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                Fmt.dateTime(klines.last.time),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
