import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/task_actions_widget.dart';
import './widgets/task_description_widget.dart';
import './widgets/task_header_widget.dart';
import './widgets/task_metadata_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock task data
  final Map<String, dynamic> _taskData = {
    "id": 1,
    "title": "Design Mobile App UI Components",
    "description":
        "Create comprehensive UI component library for the mobile application including buttons, cards, forms, and navigation elements. Ensure all components follow Material 3 design guidelines and are responsive across different screen sizes. Include proper accessibility features and dark mode support.",
    "priority": "high",
    "dueDate": DateTime.now().add(Duration(days: 2)),
    "project": "TaskFlow Pro Development",
    "createdAt": DateTime.now().subtract(Duration(days: 5)),
    "isCompleted": false,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTaskCompletion() {
    setState(() {
      _taskData["isCompleted"] = !(_taskData["isCompleted"] as bool);
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Show completion feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _taskData["isCompleted"] as bool
              ? 'Task marked as completed!'
              : 'Task marked as incomplete',
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _updateDescription(String newDescription) {
    setState(() {
      _taskData["description"] = newDescription;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Description updated successfully'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _editTask() {
    Navigator.pushNamed(context, '/task-creation-form');
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Delete Task',
        message:
            'Are you sure you want to delete this task? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        icon: 'delete',
        confirmColor: AppTheme.error,
        onConfirm: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task deleted successfully'),
              backgroundColor: AppTheme.error,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w),
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _duplicateTask() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Duplicate Task',
        message: 'Create a copy of this task with the same details?',
        confirmText: 'Duplicate',
        cancelText: 'Cancel',
        icon: 'content_copy',
        confirmColor: AppTheme.lightTheme.colorScheme.secondary,
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task duplicated successfully'),
              backgroundColor: AppTheme.success,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(4.w),
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _shareTask() {
    final taskTitle = _taskData["title"] as String;
    final taskDescription = _taskData["description"] as String;
    final dueDate = _taskData["dueDate"] as DateTime;
    final priority = _taskData["priority"] as String;

    final shareText = '''
Task: $taskTitle

Description: $taskDescription

Priority: ${priority.toUpperCase()}
Due Date: ${dueDate.day}/${dueDate.month}/${dueDate.year}

Shared from TaskFlow Pro
    '''
        .trim();

    // Copy to clipboard as a simple share implementation
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text('Task details copied to clipboard'),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: AppTheme.lightTheme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _editTask,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateTask();
                  break;
                case 'share':
                  _shareTask();
                  break;
                case 'delete':
                  _deleteTask();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'content_copy',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Text('Duplicate'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.error,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  ],
                ),
              ),
            ],
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                TaskHeaderWidget(
                  title: _taskData["title"] as String,
                  isCompleted: _taskData["isCompleted"] as bool,
                  priority: _taskData["priority"] as String,
                  onCompletionToggle: _toggleTaskCompletion,
                ),
                SizedBox(height: 2.h),
                TaskMetadataWidget(
                  dueDate: _taskData["dueDate"] as DateTime,
                  project: _taskData["project"] as String,
                  createdAt: _taskData["createdAt"] as DateTime,
                  isCompleted: _taskData["isCompleted"] as bool,
                ),
                SizedBox(height: 2.h),
                TaskDescriptionWidget(
                  description: _taskData["description"] as String,
                  onDescriptionChanged: _updateDescription,
                ),
                SizedBox(height: 2.h),
                TaskActionsWidget(
                  onEdit: _editTask,
                  onDelete: _deleteTask,
                  onDuplicate: _duplicateTask,
                  onShare: _shareTask,
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _taskData["isCompleted"] as bool ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: _editTask,
          icon: CustomIconWidget(
            iconName: 'edit',
            color:
                AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
            size: 5.w,
          ),
          label: Text(
            'Edit Task',
            style: AppTheme.lightTheme.textTheme.labelLarge!.copyWith(
              color:
                  AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
