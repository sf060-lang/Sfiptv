import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

/// Seçilen takımın marşının ilk saniyelerini çalar (assets/marslar/<takım kodu>.mp3).
class March {
  static Player? _p;
  static Timer? _stop, _fade;
  static int _gen = 0;

  static Future<void> play(String teamId, {int seconds = 3}) async {
    final gen = ++_gen;
    await stop();
    if (teamId.isEmpty) return;
    try {
      await rootBundle.load('assets/marslar/$teamId.mp3'); // yoksa hata verir
    } catch (_) {
      return; // bu takım için marş dosyası yok
    }
    if (gen != _gen) return;
    try {
      final p = _p ??= Player();
      await p.setVolume(100);
      await p.open(Media('asset:///assets/marslar/$teamId.mp3'), play: true);
      if (gen != _gen) return;
      // son yarım saniyede sesi kıs
      _fade = Timer(Duration(milliseconds: seconds * 1000 - 600), () {
        var v = 100.0;
        _fade = Timer.periodic(const Duration(milliseconds: 100), (t) {
          v -= 18;
          if (v <= 0) {
            t.cancel();
          } else {
            p.setVolume(v);
          }
        });
      });
      _stop = Timer(Duration(seconds: seconds), () => p.stop());
    } catch (_) {}
  }

  static Future<void> stop() async {
    _stop?.cancel();
    _fade?.cancel();
    try {
      await _p?.stop();
    } catch (_) {}
  }
}
