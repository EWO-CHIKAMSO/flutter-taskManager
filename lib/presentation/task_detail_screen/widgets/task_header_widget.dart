import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskHeaderWidget extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final String priority;
  final VoidCallback onCompletionToggle;

  const TaskHeaderWidget({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.priority,
    required this.onCompletionToggle,
  });

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.priorityHigh;
      case 'medium':
        return AppTheme.priorityMedium;
      case 'low':
        return AppTheme.priorityLow;
      default:
        return AppTheme.priorityMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onCompletionToggle,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.success : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.success
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: isCompleted
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: Colors.white,
                          size: 4.w,
                        )
                      : null,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 300),
                  style: AppTheme.lightTheme.textTheme.headlineSmall!.copyWith(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6)
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getPriorityColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: _getPriorityColor().withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${priority.toUpperCase()} PRIORITY',
                      style: AppTheme.lightTheme.textTheme.labelSmall!.copyWith(
                        color: _getPriorityColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.success.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                  style: AppTheme.lightTheme.textTheme.labelSmall!.copyWith(
                    color: isCompleted
                        ? AppTheme.success
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
