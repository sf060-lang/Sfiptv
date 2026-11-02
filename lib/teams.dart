import 'package:flutter/material.dart';

/// Trendyol Süper Lig 2026-27 takımları ve (yaklaşık) renkleri.
/// pri: düğme/vurgu rengi · acc: ikinci (parlak) renk · on: pri üzerindeki yazı rengi.
class Team {
  const Team(this.id, this.name, this.pri, this.acc, this.on);
  final String id, name;
  final Color pri, acc, on;
}

const teams = <Team>[
  Team('', 'Takımım yok', Color(0xFFE53945), Color(0xFF4D7CFF), Colors.white),
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

/// Uygulama artık tek bir lacivert + kırmızı temayla çalışır (takım seçimi kaldırıldı).
Team teamById(String id) => teams.first;

/// Koyu mavi (lacivert) yüzeyler + kırmızı vurgu teması.
ThemeData buildTheme(Team t) {
  const bg = Color(0xFF070F28);
  const bg2 = Color(0xFF0C1A44);
  const bg3 = Color(0xFF14295F);
  const red = Color(0xFFE53945);
  const blue = Color(0xFF4D7CFF);
  final cs = ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark).copyWith(
    primary: red,
    onPrimary: Colors.white,
    secondary: blue,
    onSecondary: Colors.white,
    tertiary: const Color(0xFFFF6A73),
    surface: bg,
    surfaceContainer: bg2,
    surfaceContainerHighest: bg3,
    secondaryContainer: bg3,
    onSecondaryContainer: Colors.white,
    outline: const Color(0xFF5A6FA8),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: bg,
    focusColor: blue.withAlpha(110),
    hoverColor: blue.withAlpha(50),
    appBarTheme: const AppBarTheme(backgroundColor: bg),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: bg2, indicatorColor: red),
    navigationRailTheme: const NavigationRailThemeData(backgroundColor: bg2, indicatorColor: red),
    dialogTheme: const DialogThemeData(backgroundColor: bg2),
    cardTheme: const CardThemeData(color: bg2),
    chipTheme: ChipThemeData(selectedColor: red, backgroundColor: bg3, labelStyle: const TextStyle(color: Colors.white)),
  );
}
