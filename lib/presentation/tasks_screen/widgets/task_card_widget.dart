import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskCardWidget extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final bool isSelected;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.isSelected = false,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task['completed'] ?? false;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1) {
      return '${difference}d left';
    } else {
      return '${difference.abs()}d overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task['title'] as String? ?? '';
    final priority = widget.task['priority'] as String? ?? 'medium';
    final dueDate = widget.task['dueDate'] as DateTime?;
    final projectName = widget.task['projectName'] as String? ?? '';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
              });
              widget.onTap?.call();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              // Long press handled by parent for multi-select
            },
            child: Dismissible(
              key: Key('task_${widget.task['id']}'),
              background: _buildSwipeBackground(isLeft: true),
              secondaryBackground: _buildSwipeBackground(isLeft: false),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  widget.onToggleComplete?.call();
                } else {
                  _showQuickActions(context);
                }
              },
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  _showQuickActions(context);
                  return false;
                }
                return true;
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.7)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppTheme.lightTheme.primaryColor, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _isCompleted = !_isCompleted;
                          });
                          widget.onToggleComplete?.call();
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: _isCompleted
                                ? AppTheme.lightTheme.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: _isCompleted
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.outlineLight,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _isCompleted
                              ? CustomIconWidget(
                                  iconName: 'check',
                                  color:
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                  size: 4.w,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: 3.w),

                      // Task content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                decoration: _isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: _isCompleted
                                    ? AppTheme.lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6)
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),

                            // Project name and due date
                            Row(
                              children: [
                                if (projectName.isNotEmpty) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.lightTheme.colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      projectName,
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                ],
                                if (dueDate != null) ...[
                                  CustomIconWidget(
                                    iconName: 'schedule',
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    _formatDate(dueDate),
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: dueDate.isBefore(DateTime.now()) &&
                                              !_isCompleted
                                          ? AppTheme.error
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Priority badge
                      Container(
                        width: 3.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.success : AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'check_circle' : 'more_horiz',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(height: 1.h),
              Text(
                isLeft ? 'Complete' : 'Actions',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.outlineLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text(
                'Edit Task',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text(
                'Duplicate Task',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDuplicate?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.error,
                size: 6.w,
              ),
              title: Text(
                'Delete Task',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}