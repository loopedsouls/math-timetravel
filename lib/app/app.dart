import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import '../main.dart';

/// Main Application Widget
class Math TimeTravelApp extends StatelessWidget {
  const Math TimeTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math TimeTravel - Tutoria Inteligente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      navigatorObservers: firebaseAvailable
          ? [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)]
          : [],
      onGenerateRoute: AppRoutes.generateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
