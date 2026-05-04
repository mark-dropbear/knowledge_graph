import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') {
      return 0;
    } else if (location.startsWith('/tasks') || location.startsWith('/lists')) {
      return 1;
    } else if (location.startsWith('/people')) {
      return 2;
    } else if (location.startsWith('/organizations')) {
      return 3;
    } else if (location.startsWith('/things')) {
      return 4;
    } else if (location.startsWith('/creative-works')) {
      return 5;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (int index) {
              if (index == 0) {
                context.go('/');
              } else if (index == 1) {
                context.go('/tasks');
              } else if (index == 2) {
                context.go('/people');
              } else if (index == 3) {
                context.go('/organizations');
              } else if (index == 4) {
                context.go('/things');
              } else if (index == 5) {
                context.go('/creative-works');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.task),
                selectedIcon: Icon(Icons.task),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('People'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                selectedIcon: Icon(Icons.business),
                label: Text('Orgs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                selectedIcon: Icon(Icons.category),
                label: Text('Things'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book),
                selectedIcon: Icon(Icons.book),
                label: Text('Creative'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
