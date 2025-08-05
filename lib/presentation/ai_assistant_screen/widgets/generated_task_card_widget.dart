import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GeneratedTaskCardWidget extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onAccept;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;
  final bool isAccepted;

  const GeneratedTaskCardWidget({
    super.key,
    required this.task,
    required this.onAccept,
    required this.onEdit,
    required this.onDismiss,
    this.isAccepted = false,
  });

  @override
  State<GeneratedTaskCardWidget> createState() =>
      _GeneratedTaskCardWidgetState();
}

class _GeneratedTaskCardWidgetState extends State<GeneratedTaskCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.surface,
      end: AppTheme.lightTheme.colorScheme.primaryContainer,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority) {
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dismissible(
            key: Key(widget.task['id'].toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => widget.onDismiss(),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'delete',
                    color: Colors.white,
                    size: 6.w,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Dismiss',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: widget.isAccepted
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                    : _colorAnimation.value,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: widget.isAccepted
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                  width: widget.isAccepted ? 2 : 1,
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
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.task['title'] ?? 'Untitled Task',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                    widget.task['priority'] ?? 'medium'),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Text(
                                (widget.task['priority'] ?? 'medium')
                                    .toUpperCase(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.task['description'] != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.task['description'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                            maxLines: _isExpanded ? null : 2,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if ((widget.task['description'] as String).length >
                              100)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 1.h),
                                child: Text(
                                  _isExpanded ? 'Show less' : 'Show more',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 4.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Est. ${widget.task['estimatedDuration'] ?? '30 min'}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            Spacer(),
                            if (widget.task['dueDate'] != null) ...[
                              CustomIconWidget(
                                iconName: 'event',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                widget.task['dueDate'],
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
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
                  if (!widget.isAccepted)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: widget.onEdit,
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(3.w),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'edit',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Edit',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 6.h,
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                _animationController.forward().then((_) {
                                  widget.onAccept();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.success,
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(3.w),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: AppTheme.success,
                                    size: 4.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Accept',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.isAccepted)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(3.w),
                          bottomRight: Radius.circular(3.w),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.success,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Added to Tasks',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
