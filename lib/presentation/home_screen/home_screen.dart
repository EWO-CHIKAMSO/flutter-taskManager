import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/project_card_widget.dart';
import './widgets/project_context_menu_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  Map<String, dynamic>? _selectedProject;
  OverlayEntry? _overlayEntry;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
  };

  // Mock projects data
  final List<Map<String, dynamic>> _projects = [
    {
      "id": 1,
      "title": "Mobile App Redesign",
      "description":
          "Complete UI/UX overhaul for the company's flagship mobile application with modern design principles.",
      "totalTasks": 12,
      "completedTasks": 8,
      "priority": "high",
      "dueDate": DateTime.now().add(Duration(days: 5)),
      "createdAt": DateTime.now().subtract(Duration(days: 15)),
    },
    {
      "id": 2,
      "title": "Marketing Campaign Q4",
      "description":
          "Launch comprehensive digital marketing campaign for Q4 product releases across all channels.",
      "totalTasks": 8,
      "completedTasks": 3,
      "priority": "medium",
      "dueDate": DateTime.now().add(Duration(days: 12)),
      "createdAt": DateTime.now().subtract(Duration(days: 8)),
    },
    {
      "id": 3,
      "title": "Website Performance Optimization",
      "description":
          "Improve website loading speed and overall performance metrics to enhance user experience.",
      "totalTasks": 15,
      "completedTasks": 15,
      "priority": "low",
      "dueDate": DateTime.now().subtract(Duration(days: 2)),
      "createdAt": DateTime.now().subtract(Duration(days: 20)),
    },
    {
      "id": 4,
      "title": "Team Training Program",
      "description":
          "Develop and implement comprehensive training program for new team members and skill development.",
      "totalTasks": 6,
      "completedTasks": 2,
      "priority": "medium",
      "dueDate": DateTime.now().add(Duration(days: 18)),
      "createdAt": DateTime.now().subtract(Duration(days: 5)),
    },
    {
      "id": 5,
      "title": "Database Migration",
      "description":
          "Migrate legacy database systems to modern cloud infrastructure with zero downtime.",
      "totalTasks": 20,
      "completedTasks": 1,
      "priority": "high",
      "dueDate": DateTime.now().add(Duration(days: 25)),
      "createdAt": DateTime.now().subtract(Duration(days: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProjects() async {
    await _loadProjects();

    // Add haptic feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Projects refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToProjectDetail(Map<String, dynamic> project) {
    // Navigate to project detail screen
    Navigator.pushNamed(context, '/task-detail-screen');
  }

  void _showProjectContextMenu(Map<String, dynamic> project, Offset position) {
    _removeOverlay();

    _selectedProject = project;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background tap to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Context menu
          Positioned(
            left: position.dx - 40.w,
            top: position.dy - 10.h,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 80.w,
                constraints: BoxConstraints(maxHeight: 50.h),
                child: ProjectContextMenuWidget(
                  project: project,
                  onEdit: () => _editProject(project),
                  onDelete: () => _deleteProject(project),
                  onArchive: () => _archiveProject(project),
                  onDismiss: _removeOverlay,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _selectedProject = null;
  }

  void _editProject(Map<String, dynamic> project) {
    // Navigate to project edit screen
    Navigator.pushNamed(context, '/task-creation-form');
  }

  void _deleteProject(Map<String, dynamic> project) {
    setState(() {
      _projects.removeWhere((p) => (p['id'] as int) == (project['id'] as int));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "${project['title']}" deleted'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _projects.add(project);
            });
          },
        ),
      ),
    );
  }

  void _archiveProject(Map<String, dynamic> project) {
    setState(() {
      _projects.removeWhere((p) => (p['id'] as int) == (project['id'] as int));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "${project['title']}" archived'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _createNewProject() {
    Navigator.pushNamed(context, '/task-creation-form');
  }

  void _createQuickTask() {
    Navigator.pushNamed(context, '/task-creation-form');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting Header
            GreetingHeaderWidget(
              userName: (_userData['name'] as String?) ?? 'User',
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _projects.isEmpty
                      ? EmptyStateWidget(
                          onCreateProject: _createNewProject,
                        )
                      : _buildProjectsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading your projects...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshProjects,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          top: 1.h,
          bottom: 20.h, // Space for FABs
        ),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return ProjectCardWidget(
            project: project,
            onTap: () => _navigateToProjectDetail(project),
            onLongPress: () {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);
              _showProjectContextMenu(
                project,
                Offset(position.dx + 50.w, position.dy + (index * 15.h) + 10.h),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Task FAB (only show when projects exist)
        if (_projects.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: FloatingActionButton(
              heroTag: "quickTask",
              onPressed: _createQuickTask,
              backgroundColor:
                  AppTheme.lightTheme.colorScheme.secondaryContainer,
              foregroundColor:
                  AppTheme.lightTheme.colorScheme.onSecondaryContainer,
              child: CustomIconWidget(
                iconName: 'add_task',
                color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
            ),
          ),

        // Main Project FAB
        FloatingActionButton.extended(
          heroTag: "newProject",
          onPressed: _createNewProject,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          icon: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
          label: Text(
            'New Project',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
