enum FormEvent { next, back, reset }

sealed class FormState {
  const FormState._();

  const factory FormState.reset() = InputNameState._reset;

  const factory FormState.inputName({
    required String name,
    ValidationResult? validationResult,
  }) = InputNameState._;
  const factory FormState.inputEmail({
    required String name,
    required String? email,
    ValidationResult? validationResult,
  }) = InputEmailState._;
  const factory FormState.confirm({
    required String name,
    required String email,
  }) = ConfirmState._;
  const factory FormState.completed({
    required String name,
    required String email,
  }) = CompletedState._;

  FormState? transition(FormEvent event, {Object? value});

  bool get hasBack;

  bool get hasNext;
}

class InputNameState extends FormState {
  final String name;
  final ValidationResult? validationResult;

  const InputNameState._({required this.name, this.validationResult})
    : super._();
  const InputNameState._reset() : name = '', validationResult = null, super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.next => _buildNext(value),
      FormEvent.reset => FormState.reset(),
      FormEvent.back => null,
    };
  }

  FormState? _buildNext(Object? value) {
    if (value is! String) return null;
    if (value.isEmpty) {
      return FormState.inputName(
        name: name,
        validationResult: Invalid(errorText: '名前を入力してください。'),
      );
    }
    return FormState.inputEmail(name: value, email: null);
  }

  @override
  bool get hasBack => false;

  @override
  bool get hasNext => true;
}

class InputEmailState extends FormState {
  final String name;
  final String? email;
  final ValidationResult? validationResult;

  const InputEmailState._({
    required this.name,
    required this.email,
    this.validationResult,
  }) : super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.next => _buildNext(value),
      FormEvent.back => FormState.inputName(name: name),
      FormEvent.reset => FormState.reset(),
    };
  }

  static const _pattern =
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
  FormState? _buildNext(Object? value) {
    if (value is! String) return null;
    final reg = RegExp(_pattern);
    if (reg.hasMatch(value) == false) {
      return FormState.inputEmail(
        name: name,
        email: value,
        validationResult: Invalid(errorText: '正しい形のE-mailアドレスを入力してください。'),
      );
    }
    return FormState.confirm(name: name, email: value);
  }

  @override
  bool get hasBack => true;

  @override
  bool get hasNext => true;
}

class ConfirmState extends FormState {
  final String name;
  final String email;

  const ConfirmState._({required this.name, required this.email}) : super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.next => FormState.completed(name: name, email: email),
      FormEvent.back => FormState.inputEmail(name: name, email: email),
      FormEvent.reset => FormState.reset(),
    };
  }

  @override
  bool get hasBack => true;

  @override
  bool get hasNext => true;
}

class CompletedState extends FormState {
  final String name;
  final String email;

  const CompletedState._({required this.name, required this.email}) : super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.reset => FormState.reset(),
      FormEvent.next => null,
      FormEvent.back => null,
    };
  }

  @override
  bool get hasBack => false;

  @override
  bool get hasNext => false;
}

sealed class ValidationResult {}

class Valid extends ValidationResult {}

class Invalid extends ValidationResult {
  final String errorText;
  Invalid({required this.errorText});
}
