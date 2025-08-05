import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActiveFiltersWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String, dynamic) onRemoveFilter;
  final VoidCallback onClearAll;

  const ActiveFiltersWidget({
    super.key,
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.8),
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Clear All',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _buildFilterChips(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];

    // Status filter
    if (activeFilters.containsKey('status') &&
        activeFilters['status'] != 'All') {
      chips.add(_buildFilterChip(
        label: activeFilters['status'],
        onRemove: () => onRemoveFilter('status', null),
      ));
    }

    // Priority filters
    if (activeFilters.containsKey('priorities')) {
      final priorities = activeFilters['priorities'] as List<String>;
      for (String priority in priorities) {
        chips.add(_buildFilterChip(
          label: priority.toUpperCase(),
          color: _getPriorityColor(priority),
          onRemove: () => onRemoveFilter('priorities', priority),
        ));
      }
    }

    // Project filters
    if (activeFilters.containsKey('projects')) {
      final projects = activeFilters['projects'] as List<String>;
      for (String project in projects) {
        chips.add(_buildFilterChip(
          label: project,
          onRemove: () => onRemoveFilter('projects', project),
        ));
      }
    }

    // Date range filter
    if (activeFilters.containsKey('dateRange')) {
      final dateRange = activeFilters['dateRange'] as DateTimeRange;
      chips.add(_buildFilterChip(
        label:
            '${_formatDate(dateRange.start)} - ${_formatDate(dateRange.end)}',
        onRemove: () => onRemoveFilter('dateRange', null),
      ));
    }

    return chips;
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.1) ??
            AppTheme.lightTheme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color ?? AppTheme.lightTheme.primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 3.w, top: 1.h, bottom: 1.h),
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: color ?? AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'close',
                color: color ?? AppTheme.lightTheme.primaryColor,
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppTheme.priorityLow;
      case 'medium':
        return AppTheme.priorityMedium;
      case 'high':
        return AppTheme.priorityHigh;
      default:
        return AppTheme.priorityMedium;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
