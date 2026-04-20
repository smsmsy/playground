import 'package:flutter/material.dart' hide FormState;
import 'package:playground/core/screen_base.dart';
import 'package:playground/multi_step_form/state/form_state.dart';
import 'package:playground/multi_step_form/view_model/multi_step_form_view_model.dart';

class MultiStepFormScreen extends StatefulWidget {
  const MultiStepFormScreen({super.key});

  @override
  State<MultiStepFormScreen> createState() => _MultiStepFormScreenState();
}

class _MultiStepFormScreenState extends State<MultiStepFormScreen> {
  final MultiStepFormViewModel _viewModel = MultiStepFormViewModel.init();

  final TextEditingController nameController = TextEditingController();
  String getName() {
    return nameController.text;
  }

  final TextEditingController emailController = TextEditingController();
  String getEmail() {
    return emailController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _viewModel.notifier,
        builder: (context, state, child) {
          const double w = 60;
          final getValue = switch (state) {
            InputNameState() => getName,
            InputEmailState() => getEmail,
            _ => null,
          };
          return ScreenBase(
            floatingActionButton: FloatingActionButton(
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$state'))),
            ),
            body: Stack(
              alignment: .center,
              children: [
                AnimatedSwitcher(
                  duration: Durations.medium2,
                  child: switch (state) {
                    InputNameState() => _InputNameView(
                      key: ValueKey('input_name'),
                      state: state,
                      controller: nameController,
                      getValue: getName,
                    ),
                    InputEmailState() => _InputEmailView(
                      key: ValueKey('input_email'),
                      state: state,
                      controller: emailController,
                      getValue: getEmail,
                    ),
                    ConfirmState() => _ConfirmView(
                      key: ValueKey('confirm'),
                      state: state,
                    ),
                    CompletedState() => _CompleteView(
                      key: ValueKey('completed'),
                      state: state,
                    ),
                  },
                ),
                Align(
                  alignment: Alignment(0.5, 0.65),
                  child: _TransitionSelector(
                    w: w,
                    viewModel: _viewModel,
                    getValue: getValue,
                    state: state,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransitionSelector extends StatelessWidget {
  const _TransitionSelector({
    required this.w,
    required MultiStepFormViewModel viewModel,
    required this.getValue,
    required this.state,
  }) : _viewModel = viewModel;

  final double w;
  final MultiStepFormViewModel _viewModel;
  final String Function()? getValue;
  final FormState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: .center,
          spacing: 32,
          children: [
            SizedBox(
              width: w,
              child: state.hasBack
                  ? IconButton(
                      onPressed: () {
                        _viewModel.dispatchBack();
                      },
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 24),
                    )
                  : null,
            ),
            TextButton(
              onPressed: () {
                _viewModel.dispatchReset();
              },
              style: TextButton.styleFrom(textStyle: TextStyle(fontSize: 24)),
              child: Text('Restart'),
            ),
            SizedBox(
              width: w,
              child: state.hasNext
                  ? IconButton(
                      onPressed: () {
                        _viewModel.dispatchNext(value: getValue?.call());
                      },
                      icon: Icon(Icons.arrow_forward_ios_rounded, size: 24),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputNameView extends StatefulWidget {
  const _InputNameView({
    super.key,
    required this.state,
    required this.controller,
    required this.getValue,
  });

  final InputNameState state;
  final TextEditingController controller;
  final String Function() getValue;

  @override
  State<_InputNameView> createState() => _InputNameViewState();
}

class _InputNameViewState extends State<_InputNameView> {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.controller.text = widget.state.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return _ViewBase(
      children: [
        Text('名前を入力してください', style: textTheme.headlineMedium),
        _TextFieldBase(
          controller: widget.controller,
          icon: Icon(Icons.person),
          labelText: '名前',
        ),
        SizedBox(height: 16),
        switch (widget.state.validationResult) {
          null => SizedBox.shrink(),
          Valid() => SizedBox.shrink(),
          Invalid(:final errorText) => Text(
            errorText,
            style: textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        },
      ],
    );
  }
}

class _InputEmailView extends StatefulWidget {
  const _InputEmailView({
    super.key,
    required this.state,
    required this.controller,
    required this.getValue,
  });

  final InputEmailState state;

  final TextEditingController controller;

  final String Function() getValue;

  @override
  State<_InputEmailView> createState() => __InputEmailViewState();
}

class __InputEmailViewState extends State<_InputEmailView> {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.controller.text = widget.state.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return _ViewBase(
      children: [
        Text('E-mailアドレスを入力してください', style: textTheme.headlineMedium),
        _TextFieldBase(
          controller: widget.controller,
          icon: Icon(Icons.mail),
          labelText: 'E-mail',
        ),
        SizedBox(height: 16),
        switch (widget.state.validationResult) {
          null => SizedBox.shrink(),
          Valid() => SizedBox.shrink(),
          Invalid(:final errorText) => Text(
            errorText,
            style: textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        },
      ],
    );
  }
}

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({super.key, required this.state});

  final ConfirmState state;

  @override
  Widget build(BuildContext context) {
    return _ViewBase(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '以下の入力内容で正しければ次に進めてください。',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          '名前: ${state.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'E-mailアドレス: ${state.email}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({super.key, required this.state});

  final CompletedState state;

  @override
  Widget build(BuildContext context) {
    return _ViewBase(
      children: [
        Text("登録完了です！👏", style: Theme.of(context).textTheme.headlineLarge),
        SizedBox(height: 16),
        Text(
          "もう一度試す場合はRestartボタンをタップしてください",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _ViewBase<T> extends StatelessWidget {
  const _ViewBase({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            spacing: 16,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _TextFieldBase extends StatelessWidget {
  const _TextFieldBase({required this.controller, this.icon, this.labelText});

  final TextEditingController controller;
  final Icon? icon;
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          label: labelText != null ? Text(labelText!) : null,
          icon: icon,
        ),
      ),
    );
  }
}
