import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/router/app_router.dart';
import '../presentation/anomaly_alerts/anomaly_alerts_screen.dart';
import '../presentation/campaign_list/campaign_list_screen.dart';
import '../presentation/spend_summary/spend_summary_screen.dart';
import '../presentation/profile/profile_screen.dart';

/// The main application shell providing bottom navigation and tab management.
///
/// This widget serves as the root container for the app's main screens,
/// managing navigation between four tabs:
/// 1. Campaign List (Home)
/// 2. Spend Summary
/// 3. Anomaly Alerts
/// 4. Profile
///
/// Features:
/// - Persistent bottom navigation bar
/// - Independent navigation stacks for each tab
/// - State preservation when switching tabs
/// - Back button handling (pops tab navigation before exiting)
/// - Tap selected tab to pop to root of that tab
///
/// Each tab has its own [Navigator] with a separate [GlobalKey],
/// allowing independent navigation history. The [IndexedStack]
/// keeps all tab widgets mounted to preserve their state.
///
/// The shell uses [PopScope] to handle back button presses correctly,
/// allowing navigation within tabs before popping the entire app.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          final key = _navigatorKeys[_selectedIndex];
          if (key.currentState?.canPop() == true) {
            key.currentState?.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _TabNavigator(
              navigatorKey: _navigatorKeys[0],
              root: const CampaignListScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[1],
              root: const SpendSummaryScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[2],
              root: const AnomalyAlertsScreen(),
            ),
            _TabNavigator(
              navigatorKey: _navigatorKeys[3],
              root: const ProfileScreen(),
            ),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          selectedIndex: _selectedIndex,
          onTap: (i) {
            if (i == _selectedIndex) {
              _navigatorKeys[i]
                  .currentState
                  ?.popUntil((r) => r.isFirst);
            } else {
              setState(() => _selectedIndex = i);
            }
          },
        ),
      ),
    );
  }
}

/// A nested navigator for an individual tab.
///
/// Provides independent navigation within a tab while maintaining
/// the tab's state when switching between tabs.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.root});

  /// The unique key for this tab's navigator.
  final GlobalKey<NavigatorState> navigatorKey;

  /// The root screen widget for this tab.
  final Widget root;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        // If it's the initial route, show the root widget
        if (settings.name == null || settings.name == '/') {
          return MaterialPageRoute(builder: (_) => root);
        }
        // Otherwise, use the app's route generator
        return onGenerateRoute(settings);
      },
    );
  }
}

/// The bottom navigation bar for switching between main tabs.
///
/// Displays four navigation items with icons and labels:
/// - Campaigns (campaign icon)
/// - Spend Summary (bar chart icon)
/// - Alerts (notification icon)
/// - Profile (person icon)
///
/// The selected tab is highlighted with the primary color.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  /// The index of the currently selected tab (0-3).
  final int selectedIndex;

  /// Callback invoked when a tab is tapped.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: theme.brightness == Brightness.dark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Spend Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

