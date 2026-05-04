import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/shared/theme.dart';

class MainApp extends StatelessWidget {
  final GoRouter router;

  const MainApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    const theme = MaterialTheme(TextTheme());
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      highContrastDarkTheme: theme.darkHighContrast(),
      highContrastTheme: theme.lightHighContrast(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
