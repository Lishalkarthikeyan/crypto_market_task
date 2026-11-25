import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import 'auth_scaffold.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to track the market and your watchlist.',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            if (auth.error != null) ErrorBanner(message: auth.error!),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: Validators.email,
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _hidden,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidden = !_hidden),
                  icon: Icon(
                    _hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: Validators.password,
              onChanged: (_) => auth.clearError(),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.busy ? null : _submit,
              child: auth.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Text('Sign in'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Don't have an account?"),
          TextButton(
            onPressed: () {
              auth.clearError();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
