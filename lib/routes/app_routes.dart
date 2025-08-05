import 'package:flutter/material.dart';
import '../presentation/task_creation_form/task_creation_form.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/tasks_screen/tasks_screen.dart';
import '../presentation/task_detail_screen/task_detail_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/ai_assistant_screen/ai_assistant_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String taskCreationForm = '/task-creation-form';
  static const String splash = '/splash-screen';
  static const String tasks = '/tasks-screen';
  static const String taskDetail = '/task-detail-screen';
  static const String home = '/home-screen';
  static const String aiAssistant = '/ai-assistant-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    taskCreationForm: (context) => const TaskCreationForm(),
    splash: (context) => const SplashScreen(),
    tasks: (context) => const TasksScreen(),
    taskDetail: (context) => const TaskDetailScreen(),
    home: (context) => const HomeScreen(),
    aiAssistant: (context) => const AiAssistantScreen(),
    // TODO: Add your other routes here
  };
}
