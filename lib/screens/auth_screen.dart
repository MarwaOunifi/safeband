import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePwd = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl   = TextEditingController();
  final _nameCtrl  = TextEditingController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _fadeCtrl.reset();
    setState(() => _isLogin = !_isLogin);
    _fadeCtrl.forward();
    ref.read(authFormProvider.notifier).reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authFormProvider.notifier);
    final ok = _isLogin
        ? await notifier.login(_emailCtrl.text.trim(), _pwdCtrl.text)
        : await notifier.register(_emailCtrl.text.trim(), _pwdCtrl.text, _nameCtrl.text.trim());
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormProvider);
    final loading   = formState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo ──
                  Center(
                    child: Column(children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accent2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(
                            color: AppTheme.accent.withOpacity(0.35),
                            blurRadius: 24, spreadRadius: 2,
                          )],
                        ),
                        child: const Center(child: Text('🩺', style: TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: 18),
                      RichText(text: const TextSpan(
                        style: TextStyle(fontFamily: 'Sora', fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -1),
                        children: [
                          TextSpan(text: 'Safe'),
                          TextSpan(text: 'Band', style: TextStyle(color: AppTheme.accent)),
                        ],
                      )),
                      const SizedBox(height: 6),
                      const Text('Surveillance bracelet Alzheimer',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ]),
                  ),

                  const SizedBox(height: 40),

                  Text(_isLogin ? 'Connexion' : 'Créer un compte',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(_isLogin ? 'Accédez au suivi de votre patient' : 'Rejoignez SafeBand',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 28),

                  // ── Champs ──
                  if (!_isLogin) ...[
                    _Field(ctrl: _nameCtrl, label: 'Nom complet', icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Requis' : null),
                    const SizedBox(height: 14),
                  ],
                  _Field(
                    ctrl: _emailCtrl, label: 'Adresse email', icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Email invalide' : null,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    ctrl: _pwdCtrl, label: 'Mot de passe', icon: Icons.lock_outline,
                    obscure: _obscurePwd,
                    suffix: IconButton(
                      icon: Icon(_obscurePwd ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted, size: 20),
                      onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                    ),
                    validator: (v) => v!.length < 6 ? 'Min. 6 caractères' : null,
                  ),

                  // ── Erreur ──
                  if (formState.status == AuthStatus.error) ...[
                    const SizedBox(height: 14),
                    _ErrorBox(message: formState.errorMessage ?? ''),
                  ],

                  const SizedBox(height: 24),

                  // ── Bouton submit ──
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.bg))
                          : Text(_isLogin ? 'Se connecter' : 'Créer le compte'),
                    ),
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    Center(child: TextButton(
                      onPressed: () {},
                      child: const Text('Mot de passe oublié ?',
                        style: TextStyle(color: AppTheme.accent2, fontSize: 13)),
                    )),
                  ],

                  const SizedBox(height: 20),

                  Center(child: GestureDetector(
                    onTap: _toggle,
                    child: RichText(text: TextSpan(
                      style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
                      children: [
                        TextSpan(
                          text: _isLogin ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
                          style: const TextStyle(color: AppTheme.textSecondary)),
                        TextSpan(
                          text: _isLogin ? 'S\'inscrire' : 'Se connecter',
                          style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                      ],
                    )),
                  )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboard;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl, required this.label, required this.icon,
    this.keyboard, this.obscure = false, this.suffix, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
          style: const TextStyle(color: AppTheme.danger, fontSize: 12))),
      ]),
    );
  }
}
