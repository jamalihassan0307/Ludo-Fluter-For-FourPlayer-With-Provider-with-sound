import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/color_constants.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/utils/helpers.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const _AuthViewContent(),
    );
  }
}

class _AuthViewContent extends StatefulWidget {
  const _AuthViewContent();

  @override
  State<_AuthViewContent> createState() => _AuthViewContentState();
}

class _AuthViewContentState extends State<_AuthViewContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = context.read<AuthViewModel>();
      if (viewModel.isLogin) {
        viewModel.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        viewModel.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      viewModel.isLogin ? 'Welcome Back!' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    if (!viewModel.isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: Helpers.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: Helpers.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.error != null)
                      Text(
                        viewModel.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: viewModel.isLogin ? 'Sign In' : 'Sign Up',
                      onPressed: _submitForm,
                      isLoading: viewModel.isLoading,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Continue with Google',
                      onPressed: viewModel.signInWithGoogle,
                      color: Colors.white,
                      isLoading: viewModel.isLoading,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: viewModel.toggleAuthMode,
                      child: Text(
                        viewModel.isLogin
                            ? 'Don\'t have an account? Sign Up'
                            : 'Already have an account? Sign In',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 