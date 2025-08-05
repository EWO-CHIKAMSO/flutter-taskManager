import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PrioritySelectorWidget extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPriorityChanged;

  const PrioritySelectorWidget({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildPriorityOption(
                  context,
                  'Low',
                  AppTheme.priorityLow,
                  selectedPriority == 'Low',
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              Expanded(
                child: _buildPriorityOption(
                  context,
                  'Medium',
                  AppTheme.priorityMedium,
                  selectedPriority == 'Medium',
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
              Expanded(
                child: _buildPriorityOption(
                  context,
                  'High',
                  AppTheme.priorityHigh,
                  selectedPriority == 'High',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityOption(
    BuildContext context,
    String priority,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 6.h,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                priority,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? color
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
