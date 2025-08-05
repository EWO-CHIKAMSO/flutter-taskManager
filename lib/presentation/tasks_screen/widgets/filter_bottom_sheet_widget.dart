import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(6.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Tasks',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter
                  _buildSectionTitle('Status'),
                  SizedBox(height: 2.h),
                  _buildStatusChips(),
                  SizedBox(height: 4.h),

                  // Priority filter
                  _buildSectionTitle('Priority'),
                  SizedBox(height: 2.h),
                  _buildPriorityChips(),
                  SizedBox(height: 4.h),

                  // Date range filter
                  _buildSectionTitle('Due Date'),
                  SizedBox(height: 2.h),
                  _buildDateRangeSelector(),
                  SizedBox(height: 4.h),

                  // Project filter
                  _buildSectionTitle('Project'),
                  SizedBox(height: 2.h),
                  _buildProjectSelector(),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(6.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatusChips() {
    final statuses = ['All', 'Pending', 'Completed'];
    final selectedStatus = _filters['status'] as String? ?? 'All';

    return Wrap(
      spacing: 2.w,
      children: statuses.map((status) {
        final isSelected = selectedStatus == status;
        return FilterChip(
          label: Text(status),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filters['status'] = status;
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.lightTheme.primaryColor,
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityChips() {
    final priorities = ['Low', 'Medium', 'High'];
    final selectedPriorities = (_filters['priorities'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      children: priorities.map((priority) {
        final isSelected = selectedPriorities.contains(priority.toLowerCase());
        final priorityColor = _getPriorityColor(priority.toLowerCase());

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(priority),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final priorities =
                  List<String>.from(_filters['priorities'] ?? []);
              if (selected) {
                priorities.add(priority.toLowerCase());
              } else {
                priorities.remove(priority.toLowerCase());
              }
              _filters['priorities'] = priorities;
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor: priorityColor.withValues(alpha: 0.2),
          checkmarkColor: priorityColor,
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? priorityColor
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector() {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outlineLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'date_range',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                    : 'Select date range',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: _selectedDateRange != null
                      ? AppTheme.lightTheme.colorScheme.onSurface
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                ),
              ),
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateRange = null;
                    _filters.remove('dateRange');
                  });
                },
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector() {
    final projects = ['Personal', 'Work', 'Health', 'Learning', 'Shopping'];
    final selectedProjects = (_filters['projects'] as List<String>?) ?? [];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: projects.map((project) {
        final isSelected = selectedProjects.contains(project);
        return FilterChip(
          label: Text(project),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final projects = List<String>.from(_filters['projects'] ?? []);
              if (selected) {
                projects.add(project);
              } else {
                projects.remove(project);
              }
              _filters['projects'] = projects;
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.lightTheme.primaryColor,
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        );
      }).toList(),
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

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}
