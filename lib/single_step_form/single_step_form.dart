import 'package:flutter/material.dart';
import 'package:playground/core/screen_base.dart';

class SingleStepFormScreen extends StatefulWidget {
  const SingleStepFormScreen({super.key});

  @override
  State<SingleStepFormScreen> createState() => _SingleStepFormScreenState();
}

class _SingleStepFormScreenState extends State<SingleStepFormScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return ScreenBase(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            spacing: 32,
            children: [
              Text('アカウント作成', style: textTheme.headlineMedium),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 250, maxWidth: 600),
                  child: Column(
                    spacing: 16,
                    children: [
                      _TextFormField(
                        labelText: '名前',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '名前を入力してください';
                          }
                          return null;
                        },
                      ),
                      _TextFormField(
                        labelText: 'パスワード',
                        controller: _passwordController,
                        useObscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワードを入力してください';
                          }
                          if (value.length < 8) {
                            return 'パスワードは8文字以上で入力してください';
                          }
                          return null;
                        },
                      ),
                      _TextFormField(
                        labelText: 'パスワード(再入力)',
                        controller: _passwordConfirmController,
                        useObscure: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'パスワードを入力してください';
                          }
                          if (value.length < 8) {
                            return 'パスワードは8文字以上で入力してください';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          final isValid = _formKey.currentState?.validate();
                          if (isValid == null || !isValid) {
                            return;
                          }
                          final showSnackBar = ScaffoldMessenger.of(
                            context,
                          ).showSnackBar;

                          if (_passwordController.text !=
                              _passwordConfirmController.text) {
                            showSnackBar(
                              SnackBar(
                                content: Text(
                                  'パスワードが一致しません。',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onError,
                                  ),
                                ),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            return;
                          }
                          showSnackBar(SnackBar(content: Text('OK!')));
                        },
                        child: Text('作成'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextFormField extends StatefulWidget {
  const _TextFormField({
    required this.controller,
    required this.labelText,
    this.useObscure = false,
    this.validator,
  });

  final String labelText;
  final TextEditingController controller;
  final String? Function(String? value)? validator;
  final bool useObscure;

  @override
  State<_TextFormField> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends State<_TextFormField> {
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.useObscure ? _obscurePassword : false,
            decoration: InputDecoration(
              label: Text(widget.labelText),
              border: OutlineInputBorder(),
              suffixIcon: widget.useObscure
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    )
                  : null,
            ),
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}
