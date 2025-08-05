import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/active_filters_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/task_card_widget.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  final List<int> _selectedTaskIds = [];
  bool _isMultiSelectMode = false;
  bool _isRefreshing = false;

  // Mock data for tasks
  final List<Map<String, dynamic>> _allTasks = [
    {
      "id": 1,
      "title": "Complete project proposal for Q4 marketing campaign",
      "priority": "high",
      "dueDate": DateTime.now().add(Duration(days: 2)),
      "completed": false,
      "projectName": "Work",
      "description":
          "Finalize the marketing strategy and budget allocation for the upcoming quarter.",
    },
    {
      "id": 2,
      "title": "Review and update team performance metrics",
      "priority": "medium",
      "dueDate": DateTime.now().add(Duration(days: 5)),
      "completed": false,
      "projectName": "Work",
      "description":
          "Analyze current team productivity and identify areas for improvement.",
    },
    {
      "id": 3,
      "title": "Schedule annual health checkup appointment",
      "priority": "low",
      "dueDate": DateTime.now().add(Duration(days: 10)),
      "completed": true,
      "projectName": "Health",
      "description":
          "Book appointment with primary care physician for routine examination.",
    },
    {
      "id": 4,
      "title": "Prepare presentation for client meeting",
      "priority": "high",
      "dueDate": DateTime.now().subtract(Duration(days: 1)),
      "completed": false,
      "projectName": "Work",
      "description":
          "Create comprehensive presentation showcasing project deliverables and timeline.",
    },
    {
      "id": 5,
      "title": "Buy groceries for weekly meal prep",
      "priority": "medium",
      "dueDate": DateTime.now().add(Duration(days: 1)),
      "completed": false,
      "projectName": "Personal",
      "description":
          "Purchase ingredients for healthy meal preparation for the upcoming week.",
    },
    {
      "id": 6,
      "title": "Complete online course module on Flutter development",
      "priority": "low",
      "dueDate": DateTime.now().add(Duration(days: 7)),
      "completed": false,
      "projectName": "Learning",
      "description":
          "Finish the advanced widgets module and complete the practical exercises.",
    },
    {
      "id": 7,
      "title": "Organize home office workspace",
      "priority": "low",
      "dueDate": DateTime.now().add(Duration(days: 3)),
      "completed": true,
      "projectName": "Personal",
      "description":
          "Declutter desk area and organize documents for better productivity.",
    },
    {
      "id": 8,
      "title": "Submit monthly expense reports",
      "priority": "high",
      "dueDate": DateTime.now().add(Duration(hours: 6)),
      "completed": false,
      "projectName": "Work",
      "description":
          "Compile and submit all business expenses from the previous month.",
    },
    {
      "id": 9,
      "title": "Plan weekend hiking trip with friends",
      "priority": "medium",
      "dueDate": DateTime.now().add(Duration(days: 4)),
      "completed": false,
      "projectName": "Personal",
      "description":
          "Research hiking trails and coordinate with friends for weekend adventure.",
    },
    {
      "id": 10,
      "title": "Update LinkedIn profile and resume",
      "priority": "low",
      "dueDate": DateTime.now().add(Duration(days: 14)),
      "completed": false,
      "projectName": "Personal",
      "description":
          "Refresh professional profile with recent achievements and skills.",
    },
  ];

  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> tasks = List.from(_allTasks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        final title = (task['title'] as String).toLowerCase();
        final projectName = (task['projectName'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || projectName.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters.containsKey('status')) {
      final status = _activeFilters['status'] as String;
      if (status == 'Completed') {
        tasks = tasks.where((task) => task['completed'] == true).toList();
      } else if (status == 'Pending') {
        tasks = tasks.where((task) => task['completed'] == false).toList();
      }
    }

    // Apply priority filter
    if (_activeFilters.containsKey('priorities')) {
      final priorities = _activeFilters['priorities'] as List<String>;
      if (priorities.isNotEmpty) {
        tasks = tasks.where((task) {
          final taskPriority = task['priority'] as String;
          return priorities.contains(taskPriority);
        }).toList();
      }
    }

    // Apply project filter
    if (_activeFilters.containsKey('projects')) {
      final projects = _activeFilters['projects'] as List<String>;
      if (projects.isNotEmpty) {
        tasks = tasks.where((task) {
          final taskProject = task['projectName'] as String;
          return projects.contains(taskProject);
        }).toList();
      }
    }

    // Apply date range filter
    if (_activeFilters.containsKey('dateRange')) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      tasks = tasks.where((task) {
        final dueDate = task['dueDate'] as DateTime?;
        if (dueDate == null) return false;
        return dueDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            dueDate.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    // Sort tasks by due date and priority
    tasks.sort((a, b) {
      // Completed tasks go to bottom
      if (a['completed'] != b['completed']) {
        return a['completed'] ? 1 : -1;
      }

      // Sort by due date
      final aDate = a['dueDate'] as DateTime?;
      final bDate = b['dueDate'] as DateTime?;
      if (aDate != null && bDate != null) {
        final comparison = aDate.compareTo(bDate);
        if (comparison != 0) return comparison;
      }

      // Sort by priority
      final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
      final aPriority = priorityOrder[a['priority']] ?? 1;
      final bPriority = priorityOrder[b['priority']] ?? 1;
      return aPriority.compareTo(bPriority);
    });

    return tasks;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll events if needed
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tasks refreshed successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _activeFilters = filters;
            });
          },
        ),
      ),
    );
  }

  void _onRemoveFilter(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _activeFilters.remove(key);
      } else {
        if (_activeFilters.containsKey(key)) {
          final list = _activeFilters[key] as List;
          list.remove(value);
          if (list.isEmpty) {
            _activeFilters.remove(key);
          }
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
  }

  void _toggleTaskCompletion(int taskId) {
    setState(() {
      final taskIndex = _allTasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _allTasks[taskIndex]['completed'] = !_allTasks[taskIndex]['completed'];
      }
    });

    HapticFeedback.lightImpact();
  }

  void _editTask(int taskId) {
    Navigator.pushNamed(context, '/task-creation-form');
  }

  void _deleteTask(int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTasks.removeWhere((task) => task['id'] == taskId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task deleted successfully')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateTask(int taskId) {
    final originalTask = _allTasks.firstWhere((task) => task['id'] == taskId);
    final newTask = Map<String, dynamic>.from(originalTask);
    newTask['id'] = _allTasks.length + 1;
    newTask['title'] = '${originalTask['title']} (Copy)';
    newTask['completed'] = false;

    setState(() {
      _allTasks.add(newTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task duplicated successfully')),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedTaskIds.clear();
      }
    });
  }

  void _toggleTaskSelection(int taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _deleteSelectedTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Tasks'),
        content: Text(
            'Are you sure you want to delete ${_selectedTaskIds.length} selected tasks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allTasks.removeWhere(
                    (task) => _selectedTaskIds.contains(task['id']));
                _selectedTaskIds.clear();
                _isMultiSelectMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tasks deleted successfully')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _markSelectedTasksComplete() {
    setState(() {
      for (int taskId in _selectedTaskIds) {
        final taskIndex = _allTasks.indexWhere((task) => task['id'] == taskId);
        if (taskIndex != -1) {
          _allTasks[taskIndex]['completed'] = true;
        }
      }
      _selectedTaskIds.clear();
      _isMultiSelectMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tasks marked as complete')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final hasActiveFilters = _activeFilters.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onFilterTap: _showFilterBottomSheet,
            hasActiveFilters: hasActiveFilters,
          ),

          // Active filters
          if (hasActiveFilters)
            ActiveFiltersWidget(
              activeFilters: _activeFilters,
              onRemoveFilter: _onRemoveFilter,
              onClearAll: _clearAllFilters,
            ),

          // Multi-select toolbar
          if (_isMultiSelectMode && _selectedTaskIds.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedTaskIds.length} selected',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: _markSelectedTasksComplete,
                    icon: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.success,
                      size: 6.w,
                    ),
                  ),
                  IconButton(
                    onPressed: _deleteSelectedTasks,
                    icon: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.error,
                      size: 6.w,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleMultiSelectMode,
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),

          // Task list
          Expanded(
            child: filteredTasks.isEmpty
                ? EmptyStateWidget(
                    title: _searchQuery.isNotEmpty || hasActiveFilters
                        ? 'No tasks found'
                        : 'No tasks yet',
                    subtitle: _searchQuery.isNotEmpty || hasActiveFilters
                        ? 'Try adjusting your search or filters to find what you\'re looking for.'
                        : 'Create your first task to get started with organizing your workflow.',
                    buttonText: 'Create Task',
                    onButtonPressed: () {
                      Navigator.pushNamed(context, '/task-creation-form');
                    },
                    iconName: _searchQuery.isNotEmpty || hasActiveFilters
                        ? 'search_off'
                        : 'task_alt',
                  )
                : RefreshIndicator(
                    onRefresh: _refreshTasks,
                    color: AppTheme.lightTheme.primaryColor,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 10.h),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final taskId = task['id'] as int;

                        return GestureDetector(
                          onLongPress: () {
                            HapticFeedback.mediumImpact();
                            if (!_isMultiSelectMode) {
                              _toggleMultiSelectMode();
                            }
                            _toggleTaskSelection(taskId);
                          },
                          child: TaskCardWidget(
                            task: task,
                            isSelected: _selectedTaskIds.contains(taskId),
                            onTap: () {
                              if (_isMultiSelectMode) {
                                _toggleTaskSelection(taskId);
                              } else {
                                Navigator.pushNamed(
                                    context, '/task-detail-screen');
                              }
                            },
                            onToggleComplete: () =>
                                _toggleTaskCompletion(taskId),
                            onEdit: () => _editTask(taskId),
                            onDelete: () => _deleteTask(taskId),
                            onDuplicate: () => _duplicateTask(taskId),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      // Floating action button
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/task-creation-form');
              },
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 7.w,
              ),
            ),
    );
  }
}
