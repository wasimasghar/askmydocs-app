import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_sizes.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/responsive.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/settings/bloc/documents_bloc.dart';
import '../features/settings/view/settings_screen.dart';
import '../shared/widgets/app_background.dart';
import '../shared/widgets/app_logo.dart';
import '../shared/widgets/max_width_container.dart';

/// Responsive app frame: a bottom [NavigationBar] on phones and a
/// [NavigationRail] on wider screens. Only holds the selected tab index.
/// Documents load at start, and again each time the Settings tab is opened.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// (icon, selectedIcon, label) for each tab.
  static const _tabs = [
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded,
        AppStrings.navChat),
    (Icons.settings_outlined, Icons.settings_rounded, AppStrings.navSettings),
  ];

  static const _screens = [DashboardScreen(), SettingsScreen()];
  static const _settingsIndex = 1;

  @override
  void initState() {
    super.initState();
    // Load once at start so Settings is ready even after a hot restart.
    context.read<DocumentsBloc>().add(const DocumentsRequested());
  }

  void _onSelect(int index) {
    if (index == _settingsIndex) {
      context.read<DocumentsBloc>().add(const DocumentsRequested());
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final content = MaxWidthContainer(
      child: IndexedStack(index: _selectedIndex, children: _screens),
    );

    if (!Responsive.useNavigationRail(context)) {
      return Scaffold(
        body: AppBackground(child: content),
        bottomNavigationBar: _buildNavigationBar(),
      );
    }

    return Scaffold(
      body: AppBackground(
        child: Row(
          children: [
            SafeArea(right: false, child: _buildNavigationRail()),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onSelect,
      destinations: [
        for (final (icon, selectedIcon, label) in _tabs)
          NavigationDestination(
            icon: Icon(icon),
            selectedIcon: Icon(selectedIcon),
            label: label,
          ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onSelect,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.lg),
        child: AppLogo(),
      ),
      destinations: [
        for (final (icon, selectedIcon, label) in _tabs)
          NavigationRailDestination(
            icon: Icon(icon),
            selectedIcon: Icon(selectedIcon),
            label: Text(label),
          ),
      ],
    );
  }
}
