import 'package:flutter/material.dart';

/// Trendyol Süper Lig 2026-27 takımları ve (yaklaşık) renkleri.
/// pri: düğme/vurgu rengi · acc: ikinci (parlak) renk · on: pri üzerindeki yazı rengi.
class Team {
  const Team(this.id, this.name, this.pri, this.acc, this.on);
  final String id, name;
  final Color pri, acc, on;
}

const teams = <Team>[
  Team('', 'Takımım yok', Color(0xFF5C7CFF), Color(0xFF8FA6FF), Colors.white),
  Team('gs', 'Galatasaray', Color(0xFFB0062F), Color(0xFFFDB912), Colors.white),
  Team('fb', 'Fenerbahçe', Color(0xFF1F47A0), Color(0xFFFFE600), Colors.white),
  Team('bjk', 'Beşiktaş', Color(0xFFECECEC), Color(0xFFFFFFFF), Color(0xFF111111)),
  Team('ts', 'Trabzonspor', Color(0xFF8B1E3F), Color(0xFF5BB4F0), Colors.white),
  Team('ibfk', 'Başakşehir', Color(0xFFF26B21), Color(0xFFFF8A4C), Color(0xFF111111)),
  Team('kasim', 'Kasımpaşa', Color(0xFF2D4BB5), Color(0xFF8FA8FF), Colors.white),
  Team('eyup', 'Eyüpspor', Color(0xFF7B2CBF), Color(0xFFFFD400), Colors.white),
  Team('goz', 'Göztepe', Color(0xFFE10600), Color(0xFFFFD100), Colors.white),
  Team('sam', 'Samsunspor', Color(0xFFD40F14), Color(0xFFF2F2F2), Colors.white),
  Team('rize', 'Çaykur Rizespor', Color(0xFF00873E), Color(0xFF4FA3FF), Colors.white),
  Team('konya', 'Konyaspor', Color(0xFF00A650), Color(0xFF7DE3A9), Colors.white),
  Team('koc', 'Kocaelispor', Color(0xFF0B8A3F), Color(0xFF9CE8B8), Colors.white),
  Team('alan', 'Alanyaspor', Color(0xFFF28C1C), Color(0xFF2ECC71), Color(0xFF111111)),
  Team('gfk', 'Gaziantep FK', Color(0xFFD4161C), Color(0xFFFF6B6B), Colors.white),
  Team('gb', 'Gençlerbirliği', Color(0xFFD4161C), Color(0xFFFF6B6B), Colors.white),
  Team('erz', 'Erzurumspor FK', Color(0xFF1E88E5), Color(0xFF6EC1FF), Colors.white),
  Team('amed', 'Amed SF', Color(0xFFE30613), Color(0xFF3DDC84), Colors.white),
  Team('corum', 'Çorum FK', Color(0xFFD4161C), Color(0xFFFF6B6B), Colors.white),
];

Team teamById(String id) =>
    teams.firstWhere((t) => t.id == id, orElse: () => teams.first);

/// Takım rengine göre koyu tema.
ThemeData buildTheme(Team t) {
  final base = ColorScheme.fromSeed(seedColor: t.pri, brightness: Brightness.dark);
  final bg = Color.alphaBlend(t.pri.withAlpha(20), const Color(0xFF0B0D16));
  final bg2 = Color.alphaBlend(t.pri.withAlpha(34), const Color(0xFF11152A));
  final bg3 = Color.alphaBlend(t.pri.withAlpha(54), const Color(0xFF1A1F36));
  final cs = base.copyWith(
    primary: t.pri,
    onPrimary: t.on,
    secondary: t.acc,
    onSecondary: t.on,
    surface: bg,
    surfaceContainer: bg2,
    surfaceContainerHighest: bg3,
    secondaryContainer: bg3,
    onSecondaryContainer: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(backgroundColor: bg),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: bg2, indicatorColor: bg3),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: bg2, indicatorColor: bg3),
    dialogTheme: DialogThemeData(backgroundColor: bg2),
  );
}
