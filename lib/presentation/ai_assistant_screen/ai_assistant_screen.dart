import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/error_state_widget.dart';
import './widgets/generated_task_card_widget.dart';
import './widgets/loading_skeleton_widget.dart';
import './widgets/prompt_input_widget.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _errorType;
  List<Map<String, dynamic>> _generatedTasks = [];
  List<String> _recentPrompts = [];
  final Set<int> _acceptedTaskIds = {};

  // Mock data for AI-generated tasks
  final List<Map<String, dynamic>> _mockTaskTemplates = [
    {
      "id": 1,
      "title": "Create social media content calendar",
      "description":
          "Develop a comprehensive 30-day social media content calendar including post ideas, hashtags, and optimal posting times for Instagram, Twitter, and LinkedIn.",
      "priority": "high",
      "estimatedDuration": "2-3 hours",
      "dueDate": "Dec 15, 2024",
      "category": "Marketing"
    },
    {
      "id": 2,
      "title": "Design app wireframes and mockups",
      "description":
          "Create detailed wireframes and high-fidelity mockups for the mobile app's main screens including onboarding, dashboard, and user profile sections.",
      "priority": "high",
      "estimatedDuration": "4-5 hours",
      "dueDate": "Dec 18, 2024",
      "category": "Design"
    },
    {
      "id": 3,
      "title": "Write email marketing sequences",
      "description":
          "Craft a series of 5 welcome emails for new app users, including onboarding tips, feature highlights, and engagement strategies.",
      "priority": "medium",
      "estimatedDuration": "3-4 hours",
      "dueDate": "Dec 20, 2024",
      "category": "Marketing"
    },
    {
      "id": 4,
      "title": "Conduct competitor analysis research",
      "description":
          "Research and analyze top 5 competitors in the mobile app space, documenting their features, pricing, and user feedback patterns.",
      "priority": "medium",
      "estimatedDuration": "2-3 hours",
      "dueDate": "Dec 22, 2024",
      "category": "Research"
    },
    {
      "id": 5,
      "title": "Set up analytics and tracking",
      "description":
          "Implement Google Analytics, Firebase Analytics, and user behavior tracking tools to monitor app performance and user engagement.",
      "priority": "high",
      "estimatedDuration": "1-2 hours",
      "dueDate": "Dec 25, 2024",
      "category": "Development"
    },
    {
      "id": 6,
      "title": "Plan launch event strategy",
      "description":
          "Organize a virtual launch event including guest speakers, product demos, and media outreach to generate buzz for the app release.",
      "priority": "low",
      "estimatedDuration": "5-6 hours",
      "dueDate": "Dec 28, 2024",
      "category": "Events"
    }
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRecentPrompts();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRecentPrompts() {
    // Mock recent prompts
    _recentPrompts = [
      "Create a marketing campaign for a new mobile app launch",
      "Plan a 30-day content strategy for social media",
      "Organize project tasks for website redesign",
    ];
  }

  Future<void> _generateTasks() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt to generate tasks', 'validation');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _generatedTasks.clear();
      _acceptedTaskIds.clear();
    });

    try {
      // Simulate AI processing delay
      await Future.delayed(Duration(seconds: 3));

      // Add current prompt to recent prompts
      final currentPrompt = _promptController.text.trim();
      if (!_recentPrompts.contains(currentPrompt)) {
        _recentPrompts.insert(0, currentPrompt);
        if (_recentPrompts.length > 5) {
          _recentPrompts = _recentPrompts.take(5).toList();
        }
      }

      // Generate mock tasks based on prompt
      final generatedTasks = _generateMockTasks(currentPrompt);

      setState(() {
        _generatedTasks = generatedTasks;
        _isLoading = false;
      });

      // Scroll to show generated tasks
      if (_generatedTasks.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    } catch (e) {
      _showError('Failed to generate tasks. Please try again.', 'service');
    }
  }

  List<Map<String, dynamic>> _generateMockTasks(String prompt) {
    // Simple logic to select relevant tasks based on prompt keywords
    final promptLower = prompt.toLowerCase();
    List<Map<String, dynamic>> selectedTasks = [];

    if (promptLower.contains('marketing') ||
        promptLower.contains('social') ||
        promptLower.contains('campaign')) {
      selectedTasks.addAll(_mockTaskTemplates
          .where((task) =>
              (task['category'] as String).toLowerCase() == 'marketing')
          .take(2));
    }

    if (promptLower.contains('design') ||
        promptLower.contains('ui') ||
        promptLower.contains('wireframe')) {
      selectedTasks.addAll(_mockTaskTemplates
          .where(
              (task) => (task['category'] as String).toLowerCase() == 'design')
          .take(1));
    }

    if (promptLower.contains('research') ||
        promptLower.contains('analysis') ||
        promptLower.contains('competitor')) {
      selectedTasks.addAll(_mockTaskTemplates
          .where((task) =>
              (task['category'] as String).toLowerCase() == 'research')
          .take(1));
    }

    if (promptLower.contains('development') ||
        promptLower.contains('analytics') ||
        promptLower.contains('tracking')) {
      selectedTasks.addAll(_mockTaskTemplates
          .where((task) =>
              (task['category'] as String).toLowerCase() == 'development')
          .take(1));
    }

    // If no specific keywords found, return a mix of tasks
    if (selectedTasks.isEmpty) {
      selectedTasks = _mockTaskTemplates.take(3).toList();
    }

    // Ensure we don't exceed 4 tasks and remove duplicates
    final uniqueTasks = selectedTasks.toSet().take(4).toList();

    // Add some randomization to task IDs to simulate fresh generation
    return uniqueTasks.map((task) {
      final newTask = Map<String, dynamic>.from(task);
      newTask['id'] =
          DateTime.now().millisecondsSinceEpoch + uniqueTasks.indexOf(task);
      return newTask;
    }).toList();
  }

  void _showError(String message, String type) {
    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = message;
      _errorType = type;
    });
  }

  void _acceptTask(Map<String, dynamic> task) {
    setState(() {
      _acceptedTaskIds.add(task['id'] as int);
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" added to your task list'),
        backgroundColor: AppTheme.success,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );

    // Simulate adding to main task database
    Future.delayed(Duration(seconds: 2), () {
      // Here you would typically add the task to your main task list
      // For now, we'll just show it as accepted
    });
  }

  void _editTask(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-creation-form', arguments: task);
  }

  void _dismissTask(Map<String, dynamic> task) {
    setState(() {
      _generatedTasks.removeWhere((t) => t['id'] == task['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task dismissed'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  void _useRecentPrompt(String prompt) {
    _promptController.text = prompt;
    // Auto-focus on the text field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _retryGeneration() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _errorType = null;
    });
    _generateTasks();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _promptController.clear();
              setState(() {
                _generatedTasks.clear();
                _acceptedTaskIds.clear();
                _hasError = false;
                _isLoading = false;
              });
            },
            icon: CustomIconWidget(
              iconName: 'clear_all',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header section with instructions
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'psychology',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'AI Task Generator',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Describe your project or goals, and I\'ll generate a list of actionable tasks to help you achieve them.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prompt input section
                    PromptInputWidget(
                      controller: _promptController,
                      onGenerate: _generateTasks,
                      isLoading: _isLoading,
                      recentPrompts: _recentPrompts,
                      onRecentPromptTap: _useRecentPrompt,
                    ),

                    SizedBox(height: 3.h),

                    // Results section
                    if (_isLoading)
                      LoadingSkeletonWidget()
                    else if (_hasError)
                      ErrorStateWidget(
                        errorMessage: _errorMessage,
                        errorType: _errorType,
                        onRetry: _retryGeneration,
                      )
                    else if (_generatedTasks.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'task_alt',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Generated Tasks (${_generatedTasks.length})',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Generated tasks list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _generatedTasks.length,
                        itemBuilder: (context, index) {
                          final task = _generatedTasks[index];
                          final isAccepted =
                              _acceptedTaskIds.contains(task['id']);

                          return GeneratedTaskCardWidget(
                            task: task,
                            isAccepted: isAccepted,
                            onAccept: () => _acceptTask(task),
                            onEdit: () => _editTask(task),
                            onDismiss: () => _dismissTask(task),
                          );
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Action buttons for accepted tasks
                      if (_acceptedTaskIds.isNotEmpty)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(3.w),
                            border: Border.all(
                              color: AppTheme.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: AppTheme.success,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      '${_acceptedTaskIds.length} task${_acceptedTaskIds.length > 1 ? 's' : ''} added to your list',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              SizedBox(
                                width: double.infinity,
                                height: 6.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/tasks-screen');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.success,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'list_alt',
                                        color: Colors.white,
                                        size: 5.w,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'View All Tasks',
                                        style: AppTheme
                                            .lightTheme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ] else if (_promptController.text.isEmpty) ...[
                      // Empty state with suggestions
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'lightbulb_outline',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 12.w,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Get Started with AI',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try these example prompts to see how AI can help organize your work:',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 3.h),
                            ...[
                              'Launch a new product',
                              'Plan a team meeting',
                              'Organize a marketing campaign'
                            ].map((example) {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 2.h),
                                child: OutlinedButton(
                                  onPressed: () => _useRecentPrompt(example),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    side: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                  ),
                                  child: Text(
                                    example,
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 10.h), // Extra space for better scrolling
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
