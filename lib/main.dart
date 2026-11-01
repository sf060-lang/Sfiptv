import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

import 'march.dart';
import 'models.dart';
import 'prefs.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/splash.dart';
import 'teams.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hata olursa beyaz ekranda kalmak yerine hatayı ekranda göster.
  ErrorWidget.builder = (d) => Material(
        color: const Color(0xFF200000),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Text('Hata: ${d.exceptionAsString()}',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      );
  String? initError;
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    initError = 'Oynatıcı başlatılamadı: $e';
  }
  final prefs = await Prefs.open();
  runApp(ChangeNotifierProvider(
    create: (_) => AppState(prefs),
    child: const IptvApp(),
  ));
  if (initError != null) debugPrint(initError);
}

class IptvApp extends StatefulWidget {
  const IptvApp({super.key});
  @override
  State<IptvApp> createState() => _IptvAppState();
}

class _IptvAppState extends State<IptvApp> with WidgetsBindingObserver {
  bool _splash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Her açılışta kayıtlı takımın marşından 3 sn çal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      March.launch(context.read<AppState>().team);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Uygulama arka plana alınınca yetişkin kilidi otomatik kapanır.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AppState>().lockAdult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = context.select<AppState, String>((s) => s.team);
    final lang = context.select<AppState, String>((s) => s.lang);
    return MaterialApp(
      key: ValueKey(lang), // dil değişince tüm arayüz yeniden çizilir
      locale: Locale(lang),
      supportedLocales: const [Locale('tr'), Locale('en'), Locale('de'), Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'SF İPTV Player',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(teamById(teamId)),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _splash
            ? SplashScreen(
                key: const ValueKey('splash'),
                onDone: () => setState(() => _splash = false),
              )
            : Selector<AppState, Account?>(
                key: const ValueKey('app'),
                selector: (_, s) => s.account,
                builder: (_, acc, __) => acc == null
                    ? const LoginScreen()
                    : HomeScreen(key: ValueKey(acc.key)),
              ),
      ),
    );
  }
}
