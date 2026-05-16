import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/router/app_router.dart';
import '../presentation/anomaly_alerts/anomaly_alerts_screen.dart';
import '../presentation/campaign_list/campaign_list_screen.dart';
import '../presentation/spend_summary/spend_summary_screen.dart';
import '../presentation/profile/profile_screen.dart';

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
        backgroundColor: AppColors.background,
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

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.navigatorKey, required this.root});

  final GlobalKey<NavigatorState> navigatorKey;
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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

