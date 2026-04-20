import 'package:flutter/foundation.dart';
import 'package:playground/multi_step_form/state/form_state.dart';

class MultiStepFormViewModel {
  final ValueNotifier<FormState> _notifier;
  ValueListenable<FormState> get notifier => _notifier;

  MultiStepFormViewModel.init() : _notifier = ValueNotifier(FormState.reset());

  void dispatchNext({Object? value}) {
    final state = _notifier.value.transition(FormEvent.next, value: value);
    if (state == null) {
      return;
    }
    _notifier.value = state;
  }

  void dispatchBack() {
    final state = _notifier.value.transition(FormEvent.back);
    if (state == null) {
      return;
    }
    _notifier.value = state;
  }

  void dispatchReset() {
    final state = _notifier.value.transition(FormEvent.reset);
    if (state == null) {
      return;
    }
    _notifier.value = state;
  }
}
