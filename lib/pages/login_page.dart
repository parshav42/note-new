import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginPage extends StatefulWidget {
const LoginPage({super.key});


@override
State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
final _formKey = GlobalKey<FormState>();
final _email = TextEditingController();
final _password = TextEditingController();
bool _loading = false;


@override
void dispose() {
_email.dispose();
_password.dispose();
super.dispose();
}


Future<void> _login() async {
if (!_formKey.currentState!.validate()) return;
setState(() => _loading = true);
try {
await AuthService().signIn(_email.text.trim(), _password.text.trim());
if (mounted) Navigator.pushReplacementNamed(context, '/notes');
} on Exception catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(e.toString())),
);
} finally {
if (mounted) setState(() => _loading = false);
}
}


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Login')),
body: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 420),
child: Padding(
padding: const EdgeInsets.all(16.0),
child: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: _email,
keyboardType: TextInputType.emailAddress,
decoration: const InputDecoration(labelText: 'Email'),
validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
),
const SizedBox(height: 12),
TextFormField(
controller: _password,
obscureText: true,
decoration: const InputDecoration(labelText: 'Password'),
validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
),
const SizedBox(height: 20),
FilledButton(
onPressed: _loading ? null : _login,
child: _loading ? const CircularProgressIndicator() : const Text('Login'),
),
const SizedBox(height: 12),
TextButton(
onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
child: const Text("Don't have an account? Sign up"),
),
],
),
),
),
),
),
);
}
}