import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/vital_record.dart';
import '../providers/vitals_provider.dart';
import '../widgets/metric_header.dart';
import '../widgets/vitals_chart.dart';
import 'add_vitals_screen.dart';

/// Main screen for tracking and visualizing vital signs over time
///
/// Features:
/// - Horizontal tabs for different metrics (Weight, BP, HR, Sugar)
/// - Animated line chart showing trends
/// - Metric header with current value and trend
/// - Quick log floating button
/// - Bottom navigation bar
class TrackVitalsScreen extends StatefulWidget {
  const TrackVitalsScreen({super.key, this.embedInParent = false});

  /// When true, return only the inner content (no Scaffold, no FAB,
  /// no bottom navigation) so it can be embedded in a parent container.
  final bool embedInParent;

  @override
  State<TrackVitalsScreen> createState() => _TrackVitalsScreenState();
}

class _TrackVitalsScreenState extends State<TrackVitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentBottomNavIndex = 1; // Track tab is active

  final List<MetricType> _metrics = [
    MetricType.weight,
    MetricType.bloodPressure,
    MetricType.heartRate,
    MetricType.sugar,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _metrics.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initialize chart data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VitalsProvider>();
      provider.initializeChartData();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final provider = context.read<VitalsProvider>();
      provider.changeMetric(_metrics[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
      children: [
        _buildAppBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _metrics.map((metric) {
              return _buildMetricView(metric);
            }).toList(),
          ),
        ),
      ],
    );

    if (widget.embedInParent) {
      return SafeArea(child: bodyContent);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: bodyContent,
      floatingActionButton: _buildQuickLogButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2B3B4A)),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      title: Text(
        'Vitals',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2B3B4A),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: const Color(0xFF2B3B4A),
        unselectedLabelColor: const Color(0xFF7F97AA),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: const Color(0xFF2B3B4A),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: _metrics.map((metric) {
          return Tab(text: metric.displayName);
        }).toList(),
      ),
    );
  }

  Widget _buildMetricView(MetricType metric) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, child) {
        final config = MetricConfig.forMetric(metric);

        // Only show data if this metric is the currently selected one
        final isActiveMetric = provider.selectedMetric == metric;
        final currentValue = isActiveMetric ? provider.getCurrentValue() : null;
        final trendPercentage =
            isActiveMetric ? provider.getTrendPercentage() : null;
        final chartData =
            isActiveMetric ? provider.chartData : <TimeSeriesPoint>[];

        // Format current value
        String formattedValue;
        if (currentValue != null) {
          formattedValue = config.valueFormatter(currentValue);
        } else {
          formattedValue = '--';
        }

        // Format trend text
        String? trendText;
        if (trendPercentage != null) {
          final percentStr = trendPercentage.abs().toStringAsFixed(1);
          trendText =
              '${provider.selectedDateRange.displayName}  ${trendPercentage >= 0 ? '+' : '-'}$percentStr%';
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metric header
              MetricHeader(
                metricName: metric.displayName,
                currentValue: formattedValue,
                trendText: trendText,
                trendPercentage: trendPercentage,
                valueColor: config.color,
              ),

              const SizedBox(height: 8),

              // Chart
              SizedBox(
                height: 280,
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : VitalsChart(
                        points: chartData,
                        config: config,
                        showArea: true,
                        enableTouch: true,
                      ),
              ),

              const SizedBox(height: 24),

              // Date range selector
              _buildDateRangeSelector(provider),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSelector(VitalsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIME RANGE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7F97AA),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: DateRange.values.map((range) {
              final isSelected = provider.selectedDateRange == range;
              return ChoiceChip(
                label: Text(range.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    provider.changeDateRange(range);
                  }
                },
                selectedColor: const Color(0xFF0D79FF).withOpacity(0.1),
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF0D79FF)
                      : const Color(0xFF7F97AA),
                ),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0D79FF)
                      : const Color(0xFFE5E5E5),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddVitalsScreen(),
          ),
        );

        // Reload data if vitals were added
        if (result != null && mounted) {
          final provider = context.read<VitalsProvider>();
          await provider.loadLatestVitals();
          // Reload chart data to show the new entry
          await provider.initializeChartData();
        }
      },
      backgroundColor: const Color(0xFF0D79FF),
      elevation: 4,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Quick Log',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) async {
          // Navigate to different screens based on index
          switch (index) {
            case 0:
              // Go back to Dashboard
              Navigator.of(context).pop();
              break;
            case 1:
              // Already on Track screen
              break;
            case 2:
              // Navigate to Reminders screen
              await Navigator.pushNamed(context, '/reminders');
              break;
            case 3:
              // Navigate to More screen
              await Navigator.pushNamed(context, '/more');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D79FF),
        unselectedItemColor: const Color(0xFF7F97AA),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            activeIcon: Icon(Icons.show_chart),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
