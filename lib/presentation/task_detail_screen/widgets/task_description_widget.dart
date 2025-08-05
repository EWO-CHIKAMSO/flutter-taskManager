import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskDescriptionWidget extends StatefulWidget {
  final String description;
  final Function(String) onDescriptionChanged;

  const TaskDescriptionWidget({
    super.key,
    required this.description,
    required this.onDescriptionChanged,
  });

  @override
  State<TaskDescriptionWidget> createState() => _TaskDescriptionWidgetState();
}

class _TaskDescriptionWidgetState extends State<TaskDescriptionWidget> {
  bool _isEditing = false;
  bool _isExpanded = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
        widget.onDescriptionChanged(_controller.text);
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.description;
      _focusNode.unfocus();
    });
  }

  void _saveEdit() {
    setState(() {
      _isEditing = false;
      _focusNode.unfocus();
    });
    widget.onDescriptionChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.description.isNotEmpty;
    final shouldShowExpand = widget.description.length > 150;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: AppTheme.lightTheme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!_isEditing)
                  GestureDetector(
                    onTap: _toggleEdit,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: CustomIconWidget(
                        iconName: 'edit',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            if (_isEditing) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter task description...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(3.w),
                    hintStyle:
                        AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelEdit,
                    child: Text(
                      'Cancel',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium!.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: _saveEdit,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    ),
                    child: Text('Save'),
                  ),
                ],
              ),
            ] else ...[
              if (hasDescription) ...[
                AnimatedCrossFade(
                  duration: Duration(milliseconds: 300),
                  crossFadeState: _isExpanded || !shouldShowExpand
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Text(
                    widget.description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      height: 1.5,
                    ),
                  ),
                  secondChild: Text(
                    '${widget.description.substring(0, 150)}...',
                    style: AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                if (shouldShowExpand) ...[
                  SizedBox(height: 2.h),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Show Less' : 'Show More',
                          style: AppTheme.lightTheme.textTheme.labelMedium!
                              .copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: _isExpanded ? 'expand_less' : 'expand_more',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'description',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                        size: 8.w,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No description added',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Tap edit to add details',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
