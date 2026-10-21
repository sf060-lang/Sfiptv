import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
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
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  }
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
    return MaterialApp(
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
