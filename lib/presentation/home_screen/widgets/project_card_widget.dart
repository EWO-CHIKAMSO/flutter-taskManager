import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProjectCardWidget({
    super.key,
    required this.project,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final int totalTasks = (project['totalTasks'] as int?) ?? 0;
    final int completedTasks = (project['completedTasks'] as int?) ?? 0;
    final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final String progressText = "${(progress * 100).toInt()}%";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
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
                    Expanded(
                      child: Text(
                        (project['title'] as String?) ?? 'Untitled Project',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(project['priority'] as String?)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (project['priority'] as String?)?.toUpperCase() ??
                            'MEDIUM',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color:
                              _getPriorityColor(project['priority'] as String?),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                if (project['description'] != null &&
                    (project['description'] as String).isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: Text(
                      project['description'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'task_alt',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$completedTasks of $totalTasks tasks',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    Spacer(),
                    Text(
                      progressText,
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                    minHeight: 6,
                  ),
                ),
                if (project['dueDate'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color:
                              _getDueDateColor(project['dueDate'] as DateTime),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _formatDueDate(project['dueDate'] as DateTime),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getDueDateColor(
                                project['dueDate'] as DateTime),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.success;
    if (progress >= 0.5) return AppTheme.priorityMedium;
    return AppTheme.priorityHigh;
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) return AppTheme.error;
    if (difference <= 3) return AppTheme.priorityHigh;
    if (difference <= 7) return AppTheme.priorityMedium;
    return AppTheme.priorityLow;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else {
      return '${dueDate.month}/${dueDate.day}/${dueDate.year}';
    }
  }
}
