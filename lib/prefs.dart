import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Kendi dosya tabanlı kalıcı depolamamız (eklenti kullanmaz, her cihazda aynı çalışır).
/// Hesaplar, favoriler, geçmiş ve ayarlar uygulama klasöründeki tek bir JSON dosyasında tutulur.
class Prefs {
  Prefs._(this._file, this.error);
  final File? _file;
  final String? error; // depolama açılamadıysa nedeni
  final Map<String, dynamic> _m = {};

  static Future<Prefs> open() async {
    File? f;
    String? err;
    try {
      final dir = await getApplicationSupportDirectory();
      await dir.create(recursive: true);
      f = File('${dir.path}/sf_iptv_data.json');
    } catch (e) {
      err = '$e';
      try {
        f = File('${Directory.systemTemp.path}/sf_iptv_data.json');
      } catch (_) {}
    }
    final p = Prefs._(f, err);
    try {
      if (f != null && f.existsSync()) {
        final d = jsonDecode(f.readAsStringSync());
        if (d is Map) p._m.addAll(Map<String, dynamic>.from(d));
      }
    } catch (_) {
      // bozuk dosya: yedeği dene
      try {
        final b = File('${f!.path}.bak');
        if (b.existsSync()) {
          final d = jsonDecode(b.readAsStringSync());
          if (d is Map) p._m.addAll(Map<String, dynamic>.from(d));
        }
      } catch (_) {}
    }
    return p;
  }

  Future<bool> _flush() async {
    final f = _file;
    if (f == null) return false;
    try {
      final tmp = File('${f.path}.tmp');
      tmp.writeAsStringSync(jsonEncode(_m), flush: true);
      if (f.existsSync()) {
        try {
          f.copySync('${f.path}.bak');
        } catch (_) {}
      }
      tmp.renameSync(f.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  String? getString(String k) => _m[k] is String ? _m[k] as String : null;
  int? getInt(String k) => _m[k] is int ? _m[k] as int : null;
  bool? getBool(String k) => _m[k] is bool ? _m[k] as bool : null;
  List<String>? getStringList(String k) =>
      _m[k] is List ? [for (final e in _m[k] as List) '$e'] : null;

  Future<bool> setString(String k, String v) {
    _m[k] = v;
    return _flush();
  }

  Future<bool> setInt(String k, int v) {
    _m[k] = v;
    return _flush();
  }

  Future<bool> setBool(String k, bool v) {
    _m[k] = v;
    return _flush();
  }

  Future<bool> setStringList(String k, List<String> v) {
    _m[k] = v;
    return _flush();
  }

  Future<bool> remove(String k) {
    _m.remove(k);
    return _flush();
  }
}
