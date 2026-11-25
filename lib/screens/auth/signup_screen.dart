import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import 'auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidden = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final ok = await auth.signUp(_name.text, _email.text, _password.text);
    if (ok && mounted) navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Start tracking prices, charts and your favourite coins.',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            if (auth.error != null) ErrorBanner(message: auth.error!),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: Validators.name,
              onChanged: (_) => auth.clearError(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
              textInputAction: TextInputAction.next,
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
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: _hidden,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_reset_rounded),
              ),
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
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
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Already registered?'),
          TextButton(
            onPressed: () {
              auth.clearError();
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
