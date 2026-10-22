import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

/// Marş çalar. Dosyalar: assets/marslar/<ad>.mp3
///  acilis.mp3 : uygulama açılırken 10 sn
class March {
  static Player? _p;
  static int _gen = 0;

  static Future<bool> _exists(String name) async {
    try {
      await rootBundle.load('assets/marslar/$name.mp3');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Dosya varsa [seconds] sn çalar ve çalma bitince döner. Yoksa hemen false döner.
  static Future<bool> _playOne(String name, int seconds, int gen) async {
    if (name.isEmpty || !await _exists(name) || gen != _gen) return false;
    try {
      final p = _p ??= Player();
      await p.setVolume(100);
      await p.open(Media('asset:///assets/marslar/$name.mp3'), play: true);
      final fadeAt = seconds * 1000 - 600;
      await Future<void>.delayed(Duration(milliseconds: fadeAt));
      for (var v = 82.0; v > 0 && gen == _gen; v -= 18) {
        await p.setVolume(v);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (gen == _gen) await p.stop();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Takım seçilince ses çalmaz (yalnızca açılış müziği vardır).
  static Future<void> play(String teamId) async {}

  /// Uygulama açılışı: assets/marslar/acilis.mp3 dosyasının ilk 10 sn'si.
  static Future<void> launch(String teamId) async {
    final gen = ++_gen;
    await _playOne('acilis', 10, gen);
  }

  static Future<void> stop({bool keepGen = false}) async {
    if (!keepGen) _gen++;
    try {
      await _p?.stop();
    } catch (_) {}
  }
}
