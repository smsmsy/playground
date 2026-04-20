enum FormEvent { next, back, reset }

sealed class FormState {
  const FormState._();

  const factory FormState.reset() = InputNameState._reset;

  const factory FormState.inputName({required String name}) = InputNameState._;
  const factory FormState.inputEmail({
    required String name,
    required String? email,
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

  const InputNameState._({required this.name}) : super._();
  const InputNameState._reset() : name = '', super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.next =>
        value is! String
            ? null
            : FormState.inputEmail(name: value, email: null),
      FormEvent.reset => FormState.reset(),
      FormEvent.back => null,
    };
  }

  @override
  bool get hasBack => false;

  @override
  bool get hasNext => true;
}

class InputEmailState extends FormState {
  final String name;
  final String? email;

  const InputEmailState._({required this.name, required this.email})
    : super._();

  @override
  FormState? transition(FormEvent event, {Object? value}) {
    return switch (event) {
      FormEvent.next =>
        value is! String ? null : FormState.confirm(name: name, email: value),
      FormEvent.back => FormState.inputName(name: name),
      FormEvent.reset => FormState.reset(),
    };
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
