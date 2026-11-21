import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../data/services/auth_api_service.dart';
class EditProfileScreen extends StatefulWidget { const EditProfileScreen({super.key}); @override State<EditProfileScreen> createState() => _EditProfileScreenState(); }
class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nickname;
  String? error; bool saving = false;
  @override void initState() { super.initState(); nickname = TextEditingController(text: context.read<AuthViewModel>().member?.nickname ?? ''); }
  @override void dispose() { nickname.dispose(); super.dispose(); }
  Future<void> save() async {
    final text = nickname.text.trim();
    if (text.length < 2 || text.length > 12) { setState(() => error = '닉네임은 2~12자로 입력해 주세요.'); return; }
    final auth = context.read<AuthViewModel>();
    if (text == auth.member?.nickname) { Navigator.pop(context); return; }
    setState(() { saving = true; error = null; });
    try { await auth.updateNickname(text); if (mounted) Navigator.pop(context); }
    on DioException catch (e) { if (mounted) setState(() => error = responseErrorCode(e) == 'MEMBER409_1' ? '이미 사용 중인 닉네임입니다.' : responseErrorMessage(e)); }
    catch (_) { if (mounted) setState(() => error = '수정에 실패했습니다.'); }
    finally { if (mounted) setState(() => saving = false); }
  }
  @override Widget build(BuildContext context) { final auth = context.watch<AuthViewModel>(); return Scaffold(appBar: AppBar(title: const Text('프로필 수정')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    TextFormField(initialValue: auth.member?.email, enabled: false, decoration: const InputDecoration(labelText: '이메일')),
    const SizedBox(height: 16), TextField(controller: nickname, enabled: !saving, maxLength: 12, decoration: InputDecoration(labelText: '닉네임', errorText: error)),
    const Spacer(), SizedBox(width: double.infinity, child: FilledButton(onPressed: saving ? null : save, child: Text(saving ? '저장 중...' : '저장'))),
  ]))); }
}
