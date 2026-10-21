import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import 'login.dart';

/// IPTV abonelikleri (sağlayıcılar): tıklayınca o sağlayıcıya geçer.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  Future<void> _delete(BuildContext context, AppState s, int i) async {
    final name = s.accounts[i].name;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abonelik silinsin mi?'),
        content: Text('"$name" listeden kaldırılacak. Bu aboneliğin favorileri ve geçmişi de silinir.'),
        actions: [
          TextButton(
              autofocus: true,
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
        ],
      ),
    );
    if (ok == true) await s.removeAccount(i);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('IPTV abonelikleri')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text('Kullanmak istediğin sağlayıcıya tıkla, uygulama o aboneliğe geçer.',
                style: Theme.of(context).textTheme.bodySmall),
          ),
          for (var i = 0; i < s.accounts.length; i++)
            Card(
              color: i == s.active ? cs.secondaryContainer : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: i == s.active ? cs.primary : cs.surfaceContainerHighest,
                  foregroundColor: i == s.active ? cs.onPrimary : cs.onSurface,
                  child: Text(s.accounts[i].name.isEmpty
                      ? '?'
                      : s.accounts[i].name.characters.first.toUpperCase()),
                ),
                title: Text(s.accounts[i].name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${s.accounts[i].host} · ${s.accounts[i].username}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: i == s.active,
                onTap: i == s.active
                    ? null
                    : () {
                        s.selectAccount(i);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.accounts[i].name} aboneliğine geçildi')));
                      },
                trailing: i == s.active
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const Chip(label: Text('Kullanımda')),
                        IconButton(
                          tooltip: 'Sil',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, s, i),
                        ),
                      ])
                    : IconButton(
                        tooltip: 'Sil',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, s, i),
                      ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Yeni abonelik ekle'),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen(canClose: true))),
          ),
        ],
      ),
    );
  }
}
