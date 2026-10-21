import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'march.dart';
import 'models.dart';
import 'store.dart';
import 'teams.dart';

IconData typeIcon(MediaType t) => switch (t) {
      MediaType.live => Icons.live_tv,
      MediaType.movie => Icons.movie,
      MediaType.series => Icons.video_library,
    };

/// Geri tuşunda "çıkılsın mı?" sorar; onaylanırsa uygulamayı kapatır.
Future<void> confirmExit(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Uygulamadan çıkılsın mı?'),
      content: const Text('Çıkarsan açık yayın da kapanır.'),
      actions: [
        TextButton(autofocus: true, onPressed: () => Navigator.pop(ctx, false), child: const Text('Hayır, kal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Evet, çık')),
      ],
    ),
  );
  if (ok != true) return;
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemNavigator.pop();
  } else {
    exit(0);
  }
}

/// Tuttuğun takımı seçtiren liste; seçince uygulama renkleri anında değişir.
class TeamGrid extends StatelessWidget {
  const TeamGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in teams)
          ChoiceChip(
            avatar: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.5, 0.5],
                  colors: [t.pri, t.acc],
                ),
              ),
            ),
            label: Text(t.name),
            selected: s.team == t.id,
            onSelected: (_) {
              s.setTeam(t.id);
              March.play(t.id);
            },
          ),
      ],
    );
  }
}

/// PIN ile yetişkin içeriğin kilidini açar. İlk kullanımda PIN oluşturtur.
Future<bool> askUnlock(BuildContext context) async {
  final s = context.read<AppState>();
  if (s.adultUnlocked) return true;
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => PinDialog(create: !s.hasPin),
  );
  return ok == true;
}

class PinDialog extends StatefulWidget {
  const PinDialog({super.key, required this.create});
  final bool create;
  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _fa = FocusNode(), _fb = FocusNode();
  String? _err;

  KeyEventResult _vkey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.arrowDown) {
      FocusScope.of(context).nextFocus();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
      FocusScope.of(context).previousFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _fa.onKeyEvent = _vkey;
    _fb.onKeyEvent = _vkey;
  }

  void _submit() {
    final s = context.read<AppState>();
    final pin = _a.text.trim();
    if (widget.create) {
      if (pin.length < 4) {
        setState(() => _err = 'PIN en az 4 haneli olmalı.');
      } else if (pin != _b.text.trim()) {
        setState(() => _err = 'PIN\'ler eşleşmiyor.');
      } else {
        s.setPin(pin).then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } else {
      if (s.unlock(pin)) {
        Navigator.pop(context, true);
      } else {
        setState(() => _err = 'Yanlış PIN.');
      }
    }
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _fa.dispose();
    _fb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.create ? 'Yetişkin PIN\'i oluştur' : 'Yetişkin içerik PIN\'i'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _a,
            focusNode: _fa,
            autofocus: true,
            textInputAction: widget.create ? TextInputAction.next : TextInputAction.done,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
                labelText: widget.create ? 'Yeni PIN (en az 4 hane)' : 'PIN'),
            onSubmitted: (_) {
              if (widget.create) {
                _fb.requestFocus();
              } else {
                _submit();
              }
            },
          ),
          if (widget.create)
            TextField(
              controller: _b,
              focusNode: _fb,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(labelText: 'PIN (tekrar)'),
              onSubmitted: (_) => _submit(),
            ),
          if (_err != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_err!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: _submit, child: Text(widget.create ? 'Kaydet' : 'Aç')),
      ],
    );
  }
}

Widget _imgPlaceholder(BuildContext c, IconData icon) => Container(
      color: Theme.of(c).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(icon, color: Theme.of(c).colorScheme.onSurfaceVariant),
    );

Widget netImage(BuildContext c, String? url, IconData fallback,
    {BoxFit fit = BoxFit.cover, int cache = 240}) {
  if (url == null) return _imgPlaceholder(c, fallback);
  return Image.network(
    url,
    fit: fit,
    cacheWidth: cache,
    gaplessPlayback: true,
    errorBuilder: (ctx, _, __) => _imgPlaceholder(ctx, fallback),
  );
}

/// Canlı kanal satırı.
class LiveTile extends StatelessWidget {
  const LiveTile({
    super.key,
    required this.item,
    required this.onTap,
    this.dragIndex,
    this.onMoveUp,
    this.onMoveDown,
    this.showFav = true,
  });
  final Item item;
  final VoidCallback onTap;
  final int? dragIndex;
  final VoidCallback? onMoveUp, onMoveDown; // kumanda/klavye ile sıralama
  final bool showFav;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final fav = s.isFav(item);
    return ListTile(
      onTap: onTap,
      onLongPress: () => s.toggleFav(item),
      leading: SizedBox(
        width: 52,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: netImage(context, item.icon, Icons.live_tv, fit: BoxFit.contain, cache: 120),
        ),
      ),
      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFav)
            IconButton(
              tooltip: fav ? 'Favorilerden çıkar' : 'Favorilere ekle',
              icon: Icon(fav ? Icons.star : Icons.star_border,
                  color: fav ? Colors.amber : null),
              onPressed: () => s.toggleFav(item),
            ),
          if (onMoveUp != null || onMoveDown != null) ...[
            IconButton(
              tooltip: 'Yukarı taşı',
              icon: const Icon(Icons.arrow_upward),
              onPressed: onMoveUp,
            ),
            IconButton(
              tooltip: 'Aşağı taşı',
              icon: const Icon(Icons.arrow_downward),
              onPressed: onMoveDown,
            ),
          ],
          if (dragIndex != null)
            ReorderableDragStartListener(
              index: dragIndex!,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
        ],
      ),
    );
  }
}

/// Film / dizi afişi. Kumandayla gezilirken odaktaki afişin etrafında çerçeve görünür;
/// Menü tuşu favoriye ekler/çıkarır.
class Poster extends StatefulWidget {
  const Poster({super.key, required this.item, required this.onTap});
  final Item item;
  final VoidCallback onTap;
  @override
  State<Poster> createState() => _PosterState();
}

class _PosterState extends State<Poster> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final item = widget.item;
    final fav = s.isFav(item);
    final accent = Theme.of(context).colorScheme.secondary;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, e) {
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.contextMenu) {
          s.toggleFav(item);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _focused ? accent : Colors.transparent, width: 3),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onFocusChange: (v) => setState(() => _focused = v),
          onTap: widget.onTap,
          onLongPress: () => s.toggleFav(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                netImage(context, item.icon, typeIcon(item.type)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Text(item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  // Yıldız dokunmatik içindir; kumandada gezinmeyi yavaşlatmasın diye odak dışı.
                  child: ExcludeFocus(
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(backgroundColor: Colors.black45),
                      icon: Icon(fav ? Icons.star : Icons.star_border,
                          size: 20, color: fav ? Colors.amber : Colors.white),
                      onPressed: () => s.toggleFav(item),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
