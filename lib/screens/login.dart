import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../pets.dart';
import '../store.dart';
import '../widgets.dart';
import '../xtream_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.canClose = false});
  final bool canClose;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _host = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _fName = FocusNode(), _fHost = FocusNode(), _fUser = FocusNode(), _fPass = FocusNode();
  bool _busy = false, _showPass = false;
  String? _error;

  // Kumandada yukarı/aşağı tuşları alanlar arasında gezdirir (klavye kapalıyken de).
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
    for (final f in [_fName, _fHost, _fUser, _fPass]) {
      f.onKeyEvent = _vkey;
    }
    try {
      final d = context.read<AppState>().draft;
      if (d != null) {
        final m = jsonDecode(d) as Map<String, dynamic>;
        _name.text = (m['n'] ?? '') as String;
        _host.text = (m['h'] ?? '') as String;
        _user.text = (m['u'] ?? '') as String;
        _pass.text = (m['p'] ?? '') as String;
      }
    } catch (_) {}
    for (final c in [_name, _host, _user, _pass]) {
      c.addListener(_saveDraft);
    }
  }

  void _saveDraft() {
    context.read<AppState>().setDraft(jsonEncode(
        {'n': _name.text, 'h': _host.text, 'u': _user.text, 'p': _pass.text}));
  }

  Account? _build() {
    final host = _host.text.trim();
    if (host.isEmpty || _user.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Sunucu, kullanıcı adı ve şifre gerekli.');
      return null;
    }
    return Account(
      name: _name.text.trim().isEmpty
          ? Uri.tryParse(host.contains('://') ? host : 'http://$host')?.host ?? host
          : _name.text.trim(),
      host: host,
      username: _user.text.trim(),
      password: _pass.text,
    );
  }

  Future<void> _saveOnly() async {
    final acc = _build();
    if (acc == null) return;
    final st = context.read<AppState>();
    await st.saveAccountOnly(acc);
    await st.setDraft(null);
    for (final c in [_name, _host, _user, _pass]) {
      c.removeListener(_saveDraft);
      c.clear();
      c.addListener(_saveDraft);
    }
    if (!mounted) return;
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedildi: ${acc.name}. Listeden seçip giriş yapabilirsin.')));
  }

  @override
  void dispose() {
    for (final c in [_name, _host, _user, _pass]) {
      c.removeListener(_saveDraft);
    }
    for (final f in [_fName, _fHost, _fUser, _fPass]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _connect() async {
    final host = _host.text.trim();
    if (host.isEmpty || _user.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Sunucu, kullanıcı adı ve şifre gerekli.');
      return;
    }
    final acc = Account(
      name: _name.text.trim().isEmpty ? Uri.tryParse(host.contains('://') ? host : 'http://$host')?.host ?? host : _name.text.trim(),
      host: host,
      username: _user.text.trim(),
      password: _pass.text,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await XtreamApi(acc).authenticate();
      if (!mounted) return;
      await context.read<AppState>().addAccount(acc);
      await context.read<AppState>().setDraft(null);
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = '$e'.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return PopScope(
      canPop: widget.canClose,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !widget.canClose) confirmExit(context);
      },
      child: Scaffold(
      appBar: widget.canClose ? AppBar(title: const Text('Hesaplar')) : null,
      body: SafeArea(
        child: Center(
          child: FocusTraversalGroup(
           policy: ReadingOrderTraversalPolicy(),
           child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.canClose) ...[
                    const Icon(Icons.live_tv_rounded, size: 64),
                    const SizedBox(height: 8),
                    Text('SF İPTV Player',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                  ],
                  const PetsAnimation(height: 200),
                  const SizedBox(height: 12),
                  if (s.accounts.isNotEmpty) ...[
                    Text('Kayıtlı hesaplar', style: Theme.of(context).textTheme.titleSmall),
                    for (var i = 0; i < s.accounts.length; i++)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.dns),
                          title: Text(s.accounts[i].name),
                          subtitle: Text('${s.accounts[i].host} · ${s.accounts[i].username}',
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          selected: i == s.active,
                          onTap: () {
                            s.selectAccount(i);
                            Navigator.of(context).popUntil((r) => r.isFirst);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => s.removeAccount(i),
                          ),
                        ),
                      ),
                    const Divider(height: 32),
                  ],
                  Text('Kullanıcı ekle (Xtream Codes)',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    focusNode: _fName,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _fHost.requestFocus(),
                    decoration: const InputDecoration(
                        labelText: 'Hesap adı (isteğe bağlı)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _host,
                    focusNode: _fHost,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _fUser.requestFocus(),
                    decoration: const InputDecoration(
                        labelText: 'Sunucu adresi',
                        hintText: 'http://sunucu.com:8080',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _user,
                    focusNode: _fUser,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _fPass.requestFocus(),
                    decoration: const InputDecoration(
                        labelText: 'Kullanıcı adı', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    focusNode: _fPass,
                    obscureText: !_showPass,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _connect(),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                  ),
                  if (context.read<AppState>().prefs.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                          'Uyarı: kayıt belleği açılamadı, bilgiler kalıcı olmayabilir. (${context.read<AppState>().prefs.error})',
                          style: const TextStyle(color: Colors.orangeAccent)),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _busy ? null : _connect,
                    icon: _busy
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: const Text('Bağlan ve kaydet'),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    ),
    );
  }
}
