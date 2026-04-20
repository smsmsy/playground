import 'package:flutter/foundation.dart';

@immutable
class FormData {
  final String? name;
  final String? email;

  const FormData._({required this.name, required this.email});

  const FormData.empty() : name = null, email = null;

  FormData copyWith({String? Function()? name, String? Function()? email}) {
    return FormData._(
      name: name != null ? name() : this.name,
      email: email != null ? email() : this.email,
    );
  }
}
