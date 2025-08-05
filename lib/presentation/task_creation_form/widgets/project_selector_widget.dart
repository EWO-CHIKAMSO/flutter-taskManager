import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProjectSelectorWidget extends StatefulWidget {
  final String? selectedProject;
  final Function(String?) onProjectChanged;

  const ProjectSelectorWidget({
    super.key,
    required this.selectedProject,
    required this.onProjectChanged,
  });

  @override
  State<ProjectSelectorWidget> createState() => _ProjectSelectorWidgetState();
}

class _ProjectSelectorWidgetState extends State<ProjectSelectorWidget> {
  final List<Map<String, dynamic>> projects = [
    {
      "id": 1,
      "name": "Mobile App Development",
      "taskCount": 12,
      "color": "0xFF6750A4",
    },
    {
      "id": 2,
      "name": "Website Redesign",
      "taskCount": 8,
      "color": "0xFF625B71",
    },
    {
      "id": 3,
      "name": "Marketing Campaign",
      "taskCount": 15,
      "color": "0xFF7D5260",
    },
    {
      "id": 4,
      "name": "Product Launch",
      "taskCount": 6,
      "color": "0xFF4CAF50",
    },
    {
      "id": 5,
      "name": "Team Training",
      "taskCount": 4,
      "color": "0xFFFF9800",
    },
  ];

  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _filteredProjects = projects;
    _searchController.addListener(_filterProjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = projects.where((project) {
        final name = (project["name"] as String).toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedProject ?? 'Select Project',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: widget.selectedProject != null
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName:
                      _isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: _isExpanded ? 30.h : 0,
          child: _isExpanded
              ? Container(
                  margin: EdgeInsets.only(top: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search projects...',
                            prefixIcon: CustomIconWidget(
                              iconName: 'search',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                          ),
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = _filteredProjects[index];
                            final isSelected =
                                widget.selectedProject == project["name"];

                            return ListTile(
                              onTap: () {
                                widget.onProjectChanged(
                                    project["name"] as String);
                                setState(() {
                                  _isExpanded = false;
                                });
                                _searchController.clear();
                              },
                              leading: Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: Color(
                                      int.parse(project["color"] as String)),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(
                                project["name"] as String,
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                '${project["taskCount"]} tasks',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                              ),
                              trailing: isSelected
                                  ? CustomIconWidget(
                                      iconName: 'check',
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      size: 20,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}
