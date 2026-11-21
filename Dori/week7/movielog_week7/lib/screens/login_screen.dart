import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'register_screen.dart';
class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(); final password = TextEditingController();
  late AuthViewModel auth;
  @override void initState() { super.initState(); auth = context.read<AuthViewModel>(); auth.addListener(_expired); WidgetsBinding.instance.addPostFrameCallback((_) => _expired()); }
  void _expired() { if (!mounted || !auth.sessionExpired) return; auth.consumeExpired(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 만료됐어요. 다시 로그인해 주세요.'))); }
  @override void dispose() { auth.removeListener(_expired); email.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('MovieLog 로그인')), body: Consumer<AuthViewModel>(builder: (context, vm, _) {
    final busy = vm.status == AuthStatus.authenticating;
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 48), const Icon(Icons.movie_filter, size: 76), const SizedBox(height: 24),
      const Text('MovieLog · 7주차', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 35), TextField(controller: email, enabled: !busy, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder())),
      const SizedBox(height: 16), TextField(controller: password, enabled: !busy, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder())),
      if (vm.message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(vm.message!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      const SizedBox(height: 24), FilledButton(onPressed: busy ? null : () => vm.login(email.text, password.text), child: Text(busy ? '로그인 중...' : '로그인')),
      TextButton(onPressed: busy ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('회원가입')),
    ]);
  }));
}
