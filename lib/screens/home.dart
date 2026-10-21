import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets.dart';
import 'accounts.dart';
import 'browse.dart';
import 'favorites.dart';
import 'history.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _visited = <int>{0};
  final _stack = <int>[0]; // gezilen menüler (geri tuşu için)

  static const _dests = [
    (Icons.live_tv_outlined, Icons.live_tv, 'Canlı TV'),
    (Icons.movie_outlined, Icons.movie, 'Filmler'),
    (Icons.video_library_outlined, Icons.video_library, 'Diziler'),
    (Icons.star_border, Icons.star, 'Favoriler'),
    (Icons.history, Icons.history, 'Geçmiş'),
    (Icons.dns_outlined, Icons.dns, 'Abonelikler'),
    (Icons.settings_outlined, Icons.settings, 'Ayarlar'),
  ];

  Widget _make(int k) => switch (k) {
        0 => const BrowseScreen(key: ValueKey('live'), type: MediaType.live),
        1 => const BrowseScreen(key: ValueKey('movie'), type: MediaType.movie),
        2 => const BrowseScreen(key: ValueKey('series'), type: MediaType.series),
        3 => const FavoritesScreen(),
        4 => const HistoryScreen(),
        5 => const AccountsScreen(),
        _ => const SettingsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _i,
      children: [
        for (var k = 0; k < _dests.length; k++)
          _visited.contains(k) ? _make(k) : const SizedBox.shrink(),
      ],
    );
    void select(int k) {
      if (k == _i) return;
      setState(() {
        _i = k;
        _visited.add(k);
        _stack.add(k);
        if (_stack.length > 50) _stack.removeAt(0);
      });
    }

    void onBack() {
      if (_stack.length > 1) {
        setState(() {
          _stack.removeLast();
          _i = _stack.last;
        });
      } else {
        confirmExit(context);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 700;
      if (wide) {
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _i,
                  onDestinationSelected: select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _dests)
                      NavigationRailDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2),
                        label: Text(d.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i,
          onDestinationSelected: select,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
          destinations: [
            for (final d in _dests)
              NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
          ],
        ),
      );
    }),
    );
  }
}
