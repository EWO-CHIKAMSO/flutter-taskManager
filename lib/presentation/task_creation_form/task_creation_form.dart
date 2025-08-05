import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_picker_widget.dart';
import './widgets/form_action_buttons_widget.dart';
import './widgets/priority_selector_widget.dart';
import './widgets/project_selector_widget.dart';

class TaskCreationForm extends StatefulWidget {
  const TaskCreationForm({super.key});

  @override
  State<TaskCreationForm> createState() => _TaskCreationFormState();
}

class _TaskCreationFormState extends State<TaskCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String _selectedPriority = 'Medium';
  String? _selectedProject;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  final int _maxDescriptionLength = 500;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {
      _hasUnsavedChanges = _titleController.text.isNotEmpty ||
          _descriptionController.text.isNotEmpty ||
          _selectedProject != null ||
          _selectedDate != null;
    });
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty && _selectedProject != null;
  }

  void _onPriorityChanged(String priority) {
    setState(() {
      _selectedPriority = priority;
    });
    _onFormChanged();
  }

  void _onProjectChanged(String? project) {
    setState(() {
      _selectedProject = project;
    });
    _onFormChanged();
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
    _onFormChanged();
  }

  Future<void> _createTask() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(Duration(milliseconds: 1500));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.getSuccessColor(),
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Task "${_titleController.text.trim()}" created successfully!',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onInverseSurface,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getSuccessColor(),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to tasks screen
        Navigator.pushReplacementNamed(context, '/tasks-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Failed to create task. Please try again.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getErrorColor(),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onCancel() async {
    if (_hasUnsavedChanges) {
      final shouldDiscard = await _showDiscardDialog();
      if (shouldDiscard == true) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Discard Changes?',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Editing',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.getErrorColor(),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          final shouldDiscard = await _showDiscardDialog();
          return shouldDiscard ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Create New Task',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          leading: IconButton(
            onPressed: _onCancel,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title Field
                      Text(
                        'Task Title *',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 100,
                        decoration: InputDecoration(
                          hintText: 'Enter task title...',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'task_alt',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          counterText: '',
                          errorStyle:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.getErrorColor(),
                          ),
                        ),
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Task title is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Task title must be at least 3 characters';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Project Selector
                      ProjectSelectorWidget(
                        selectedProject: _selectedProject,
                        onProjectChanged: _onProjectChanged,
                      ),

                      SizedBox(height: 3.h),

                      // Priority Selector
                      PrioritySelectorWidget(
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: _onPriorityChanged,
                      ),

                      SizedBox(height: 3.h),

                      // Due Date Picker
                      DatePickerWidget(
                        selectedDate: _selectedDate,
                        onDateChanged: _onDateChanged,
                      ),

                      SizedBox(height: 3.h),

                      // Description Field
                      Text(
                        'Description (Optional)',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        maxLength: _maxDescriptionLength,
                        decoration: InputDecoration(
                          hintText:
                              'Add task description, notes, or requirements...',
                          alignLabelWithHint: true,
                          counterText:
                              '${_descriptionController.text.length}/$_maxDescriptionLength',
                          counterStyle:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                        onFieldSubmitted: (_) {
                          if (_isFormValid) {
                            _createTask();
                          }
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Form Validation Summary
                      if (!_isFormValid &&
                          (_titleController.text.isNotEmpty ||
                              _selectedProject != null))
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.getErrorColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.getErrorColor()
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.getErrorColor(),
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Please complete the following:',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme.getErrorColor(),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_titleController.text.trim().isEmpty)
                                      Text(
                                        '• Task title is required',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.getErrorColor(),
                                        ),
                                      ),
                                    if (_selectedProject == null)
                                      Text(
                                        '• Project selection is required',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.getErrorColor(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 10.h), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            FormActionButtonsWidget(
              isFormValid: _isFormValid,
              isLoading: _isLoading,
              onCreateTask: _createTask,
              onCancel: _onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
