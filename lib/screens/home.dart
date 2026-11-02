import 'package:flutter/material.dart' hide Text;
import '../i18n.dart';

import 'package:provider/provider.dart';

import '../models.dart';
import '../store.dart';
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
        _ => const _SettingsGate(),
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
    final st = context.read<AppState>();
    Future<void> select(int k) async {
      if (k == _i) return;
      if (k == 6 && !st.settingsUnlocked) {
        final ok = await showDialog<bool>(
            context: context, builder: (_) => const PinDialog(create: false, settings: true));
        if (ok != true || !mounted) return;
      }
      if (_i == 6) st.lockSettings();
      setState(() {
        _i = k;
        _visited.add(k);
        _stack.add(k);
        if (_stack.length > 50) _stack.removeAt(0);
      });
    }

    void onBack() {
      if (_stack.length > 1) {
        if (_i == 6) st.lockSettings();
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


/// Ayarlar sekmesi: şifre girilmeden içerik gösterilmez.
class _SettingsGate extends StatelessWidget {
  const _SettingsGate();
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.settingsUnlocked) return const SettingsScreen();
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 48),
        const SizedBox(height: 12),
        const Text('Ayarlar kilitli'),
        const SizedBox(height: 12),
        FilledButton(
          autofocus: true,
          onPressed: () => showDialog<bool>(
              context: context, builder: (_) => const PinDialog(create: false, settings: true)),
          child: const Text('Şifreyi gir'),
        ),
      ]),
    );
  }
}
