import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../theme/app_colors.dart';

class SystemMonitoringDashboard extends StatefulWidget {
  final bool showRealTimeData;

  const SystemMonitoringDashboard({super.key, this.showRealTimeData = true});

  @override
  State<SystemMonitoringDashboard> createState() =>
      _SystemMonitoringDashboardState();
}

class _SystemMonitoringDashboardState extends State<SystemMonitoringDashboard> {
  Timer? _dataUpdateTimer;

  // Simulated real-time data
  double _systemPressure = 2500.0; // PSI
  double _temperature = 65.0; // Celsius
  double _flowRate = 45.0; // LPM
  double _efficiency = 94.5; // Percentage

  String _systemStatus = 'Optimal';

  // Historical data for mini charts
  final List<double> _pressureHistory = [];
  final List<double> _temperatureHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeHistoricalData();

    if (widget.showRealTimeData) {
      _startDataUpdates();
    }
  }

  void _initializeHistoricalData() {
    // Initialize with some sample data
    final random = Random();
    for (int i = 0; i < 20; i++) {
      _pressureHistory.add(2400 + random.nextDouble() * 200);
      _temperatureHistory.add(60 + random.nextDouble() * 15);
    }
  }

  void _startDataUpdates() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateSimulatedData();
      }
    });
  }

  void _updateSimulatedData() {
    final random = Random();

    setState(() {
      // Simulate realistic hydraulic system variations
      _systemPressure += (random.nextDouble() - 0.5) * 50;
      _systemPressure = _systemPressure.clamp(2200.0, 2800.0);

      _temperature += (random.nextDouble() - 0.5) * 2;
      _temperature = _temperature.clamp(55.0, 80.0);

      _flowRate += (random.nextDouble() - 0.5) * 3;
      _flowRate = _flowRate.clamp(35.0, 55.0);

      _efficiency = 90 + random.nextDouble() * 8;

      // Update historical data
      _pressureHistory.add(_systemPressure);
      _temperatureHistory.add(_temperature);

      // Keep only last 20 data points
      if (_pressureHistory.length > 20) {
        _pressureHistory.removeAt(0);
        _temperatureHistory.removeAt(0);
      }

      // Update system status based on values
      _updateSystemStatus();
    });
  }

  void _updateSystemStatus() {
    if (_temperature > 75 || _systemPressure > 2700) {
      _systemStatus = 'Warning';
    } else if (_efficiency < 92) {
      _systemStatus = 'Attention';
    } else {
      _systemStatus = 'Optimal';
    }
  }

  @override
  void dispose() {
    _dataUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),
        _buildMonitoringGrid(),
        const SizedBox(height: 20),
        _buildSystemAlerts(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface.withOpacity(0.06)
                    : AppColors.primaryBlue.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.monitor_heart,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.accentColor
                    : AppColors.primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Monitoring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.neutral800,
              ),
            ),
            Text(
              'Real-time hydraulic system status',
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSecondaryText
                        : AppColors.neutral500,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildStatusIndicator(),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;

    switch (_systemStatus) {
      case 'Optimal':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'Warning':
        statusColor = AppColors.warning;
        statusIcon = Icons.warning;
        break;
      case 'Attention':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppColors.neutral400;
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            _systemStatus,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'System Pressure',
                    value: '${_systemPressure.toStringAsFixed(0)} PSI',
                    icon: Icons.speed,
                    color:
                        _systemPressure > 2700
                            ? AppColors.warning
                            : AppColors.primaryBlue,
                    trend: _pressureHistory,
                    unit: 'PSI',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Temperature',
                    value: '${_temperature.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat,
                    color:
                        _temperature > 75 ? AppColors.error : AppColors.success,
                    trend: _temperatureHistory,
                    unit: '°C',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Flow Rate',
                    value: '${_flowRate.toStringAsFixed(1)} LPM',
                    icon: Icons.water_drop,
                    color: AppColors.info,
                    trend: null,
                    unit: 'LPM',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Efficiency',
                    value: '${_efficiency.toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color:
                        _efficiency > 95
                            ? AppColors.success
                            : AppColors.warning,
                    trend: null,
                    unit: '%',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    List<double>? trend,
    required String unit,
  }) {
    return Container(
      height: 140, // Fixed height to prevent layout issues
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withAlpha(51), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (widget.showRealTimeData)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.neutral500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Expanded(child: _buildMiniChart(trend, color)),
          ] else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<double> data, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();

    final minValue = data.reduce(min);
    final maxValue = data.reduce(max);

    return SizedBox(
      height: 30,
      child: CustomPaint(
        painter: MiniChartPainter(
          data: data,
          color: color,
          minValue: minValue,
          maxValue: maxValue,
        ),
        size: const Size(double.infinity, 30),
      ),
    );
  }

  Widget _buildSystemAlerts() {
    final alerts = <Map<String, dynamic>>[];

    if (_temperature > 75) {
      alerts.add({
        'type': 'warning',
        'message':
            'High temperature detected: ${_temperature.toStringAsFixed(1)}°C',
        'icon': Icons.thermostat,
      });
    }

    if (_systemPressure > 2700) {
      alerts.add({
        'type': 'error',
        'message':
            'Pressure exceeds safe limit: ${_systemPressure.toStringAsFixed(0)} PSI',
        'icon': Icons.warning,
      });
    }

    if (_efficiency < 92) {
      alerts.add({
        'type': 'info',
        'message':
            'System efficiency below optimal: ${_efficiency.toStringAsFixed(1)}%',
        'icon': Icons.info,
      });
    }

    if (alerts.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppColors.darkSurface.withAlpha(30)
                  : AppColors.success.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? AppColors.darkBorder : AppColors.success.withAlpha(77),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: isDark ? AppColors.success : AppColors.success,
            ),
            const SizedBox(width: 12),
            Text(
              'All systems operating normally',
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryText : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkPrimaryText : AppColors.neutral800,
          ),
        ),
        const SizedBox(height: 8),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    Color alertColor;
    switch (alert['type']) {
      case 'error':
        alertColor = AppColors.error;
        break;
      case 'warning':
        alertColor = AppColors.warning;
        break;
      default:
        alertColor = AppColors.info;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : alertColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : alertColor.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(alert['icon'], color: alertColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert['message'],
              style: TextStyle(
                color: isDark ? AppColors.darkPrimaryText : alertColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double minValue;
  final double maxValue;

  MiniChartPainter({
    required this.data,
    required this.color,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final range = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
