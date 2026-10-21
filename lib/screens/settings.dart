import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../store.dart';
import '../teams.dart';
import '../widgets.dart';
import 'login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _presets = <List<String>>[
    ['', 'Dahili oynatıcı (önerilen)'],
    ['org.videolan.vlc', 'VLC'],
    ['com.mxtech.videoplayer.ad', 'MX Player'],
    ['com.mxtech.videoplayer.pro', 'MX Player Pro'],
    ['com.brouken.player', 'Just Player'],
    ['org.xbmc.kodi', 'Kodi'],
    ['chooser', 'Her seferinde sor (yüklü oynatıcılardan seç)'],
  ];

  List<Widget> _players(BuildContext context, AppState s) {
    Widget tile(String pkg, String name, {bool custom = false}) => ListTile(
          leading: Icon(s.extPlayer == pkg ? Icons.radio_button_checked : Icons.radio_button_off),
          title: Text(name),
          subtitle: pkg.isEmpty || pkg == 'chooser' ? null : Text(pkg),
          selected: s.extPlayer == pkg,
          onTap: () => s.setExtPlayer(pkg),
          trailing: custom
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => s.removeCustomPlayer(pkg))
              : null,
        );
    return [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Kanalları hangi oynatıcıda açmak istediğini seç. VLC, MX Player gibi '
            'oynatıcıların telefona/TV\'ye kurulu olması gerekir (Play Store).'),
      ),
      for (final p in _presets) tile(p[0], p[1]),
      for (final p in s.customPlayers) tile(p[1], p[0], custom: true),
      ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Başka oynatıcı ekle'),
        subtitle: const Text('Oynatıcının paket adını gir (ör. org.videolan.vlc)'),
        onTap: () => _addPlayer(context, s),
      ),
    ];
  }

  Future<void> _addPlayer(BuildContext context, AppState s) async {
    final n = TextEditingController(), p = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oynatıcı ekle'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: n,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Ad (ör. Benim oynatıcım)')),
          TextField(
              controller: p,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Paket adı (ör. org.videolan.vlc)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ekle')),
        ],
      ),
    );
    if (ok == true && p.text.trim().isNotEmpty) {
      s.addCustomPlayer(n.text.trim().isEmpty ? p.text.trim() : n.text.trim(), p.text);
    }
    n.dispose();
    p.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final acc = s.account;

    return ListView(
      children: [
        const _Header('Hesap'),
        ListTile(
          leading: const Icon(Icons.dns),
          title: Text(acc?.name ?? '-'),
          subtitle: Text('${acc?.host ?? ''} · ${acc?.username ?? ''}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LoginScreen(canClose: true)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Listeleri yenile'),
          subtitle: const Text('Kanal, film ve dizi listelerini sunucudan yeniden çeker'),
          onTap: () {
            s.reloadAll();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Listeler bir sonraki açılışta yenilenecek.')));
          },
        ),
        const _Header('Görünüm'),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Tuttuğun takım'),
          subtitle: Text('${teamById(s.team).name} — uygulama renkleri takımına göre değişir'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Tuttuğun takım'),
              content: const SingleChildScrollView(child: TeamGrid()),
              actions: [
                FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bitti')),
              ],
            ),
          ),
        ),
        const _Header('Oynatıcı'),
        ListTile(
          leading: const Icon(Icons.stream),
          title: const Text('Canlı yayın formatı'),
          subtitle: const Text('MPEG-TS genelde daha hızlı açılır; HLS (m3u8) bazı sunucularda daha kararlıdır'),
          trailing: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'ts', label: Text('TS')),
              ButtonSegment(value: 'm3u8', label: Text('HLS')),
            ],
            selected: {s.liveFormat},
            onSelectionChanged: (v) => s.setLiveFormat(v.first),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.memory),
          title: const Text('Donanım hızlandırma'),
          subtitle: const Text('4K/8K için açık kalmalı. Görüntü bozuksa kapatıp dene.'),
          value: s.hwAccel,
          onChanged: s.setHwAccel,
        ),
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('Ara bellek'),
          subtitle: Text('${s.bufPreset.info} — oynatmadan önce ${s.bufPreset.pre} sn biriktirir. '
              'Sık takılıyorsa yükseltin; kanal geç açılıyorsa düşürün.'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in bufPresets)
                ChoiceChip(
                  label: Text(b.label),
                  selected: s.buf == b.id,
                  onSelected: (_) => s.setBuf(b.id),
                ),
            ],
          ),
        ),
        const _Header('Oynatıcı'),
        ..._players(context, s),
        const _Header('Yetişkin içerik'),
        ListTile(
          leading: Icon(s.adultUnlocked ? Icons.lock_open : Icons.lock_outline),
          title: Text(s.adultUnlocked ? 'Kilit açık — şimdi kilitle' : 'Kilidi aç'),
          subtitle: Text(s.hasPin
              ? 'Yetişkin kategoriler PIN ile korunuyor. Uygulama arka plana alınınca otomatik kilitlenir.'
              : 'Henüz PIN belirlenmedi. Kilidi açmaya çalışınca PIN oluşturulur.'),
          onTap: () async {
            if (s.adultUnlocked) {
              s.lockAdult();
            } else {
              await askUnlock(context);
            }
          },
        ),
        if (s.hasPin)
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('PIN değiştir'),
            onTap: () async {
              if (!await askUnlock(context)) return;
              if (!context.mounted) return;
              await showDialog<bool>(
                context: context,
                builder: (_) => const PinDialog(create: true),
              );
            },
          ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Yetişkin kategorilerini seç'),
          subtitle: const Text('Otomatik algılananları düzeltebilir, yenilerini ekleyebilirsin'),
          onTap: () async {
            if (!await askUnlock(context)) return;
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdultCatsScreen()),
            );
          },
        ),
        const _Header('Veri'),
        ListTile(
          leading: const Icon(Icons.history_toggle_off),
          title: const Text('İzleme geçmişini temizle'),
          onTap: s.clearHistory,
        ),
        ListTile(
          leading: const Icon(Icons.star_border),
          title: const Text('Favorileri temizle'),
          onTap: s.clearFavorites,
        ),
        const _Header('Kısayollar (Windows)'),
        const ListTile(
          leading: Icon(Icons.keyboard),
          title: Text('Boşluk: oynat/duraklat · F: tam ekran · M: sessiz'),
          subtitle: Text('↑ / ↓: önceki / sonraki kanal · ← / →: ±10 sn · Esc: geri'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
      );
}

class AdultCatsScreen extends StatefulWidget {
  const AdultCatsScreen({super.key});
  @override
  State<AdultCatsScreen> createState() => _AdultCatsScreenState();
}

class _AdultCatsScreenState extends State<AdultCatsScreen> {
  late Future<void> _fut;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _fut = Future.wait([for (final t in MediaType.values) s.ensureCats(t)]);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Yetişkin kategorileri')),
      body: FutureBuilder<void>(
        future: _fut,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'.replaceFirst('Exception: ', '')));
          }
          return ListView(
            children: [
              for (final t in MediaType.values) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(switch (t) {
                    MediaType.live => 'Canlı TV',
                    MediaType.movie => 'Filmler',
                    MediaType.series => 'Diziler',
                  }, style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final c in s.cats[t] ?? const <MediaCat>[])
                  CheckboxListTile(
                    dense: true,
                    title: Text(c.name),
                    value: s.catIsAdult(t, c),
                    onChanged: (v) => s.setCatAdult(t, c, v ?? false),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
