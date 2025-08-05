import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskMetadataWidget extends StatelessWidget {
  final DateTime dueDate;
  final String project;
  final DateTime createdAt;
  final bool isCompleted;

  const TaskMetadataWidget({
    super.key,
    required this.dueDate,
    required this.project,
    required this.createdAt,
    required this.isCompleted,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  bool _isOverdue() {
    return !isCompleted && DateTime.now().isAfter(dueDate);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();

    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildMetadataRow(
              icon: 'calendar_today',
              label: 'Due Date',
              value: _formatDate(dueDate),
              subValue: _formatTime(dueDate),
              isHighlighted: isOverdue,
              highlightColor: AppTheme.error,
            ),
            SizedBox(height: 2.h),
            _buildMetadataRow(
              icon: 'folder',
              label: 'Project',
              value: project,
              subValue: null,
              isHighlighted: false,
              highlightColor: null,
            ),
            SizedBox(height: 2.h),
            _buildMetadataRow(
              icon: 'schedule',
              label: 'Created',
              value: _formatDate(createdAt),
              subValue: _formatTime(createdAt),
              isHighlighted: false,
              highlightColor: null,
            ),
            if (isCompleted) ...[
              SizedBox(height: 2.h),
              _buildMetadataRow(
                icon: 'check_circle',
                label: 'Status',
                value: 'Completed',
                subValue: 'Task finished successfully',
                isHighlighted: true,
                highlightColor: AppTheme.success,
              ),
            ],
            if (isOverdue && !isCompleted) ...[
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.error,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Overdue',
                            style: AppTheme.lightTheme.textTheme.labelMedium!
                                .copyWith(
                              color: AppTheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'This task is past its due date',
                            style: AppTheme.lightTheme.textTheme.bodySmall!
                                .copyWith(
                              color: AppTheme.error.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow({
    required String icon,
    required String label,
    required String value,
    String? subValue,
    required bool isHighlighted,
    Color? highlightColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isHighlighted && highlightColor != null
                ? highlightColor.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: isHighlighted && highlightColor != null
                  ? highlightColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isHighlighted && highlightColor != null
                      ? highlightColor
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              if (subValue != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  subValue,
                  style: AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
