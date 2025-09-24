import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isObscureText;
  final bool rememberMe;
  final String email;
  final String password;

  const LoginState({
    this.isObscureText = true,
    this.rememberMe = false,
    this.email = '',
    this.password = '',
  });

  LoginState copyWith({
    bool? isObscureText,
    bool? rememberMe,
    String? email,
    String? password,
  }) {
    return LoginState(
      isObscureText: isObscureText ?? this.isObscureText,
      rememberMe: rememberMe ?? this.rememberMe,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [isObscureText, rememberMe, email, password];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isObscureText: !state.isObscureText));
  }

  void toggleRememberMe(bool? value) {
    emit(state.copyWith(rememberMe: value ?? false));
  }

  void setEmail(String email) {
    emit(state.copyWith(email: email));
  }

  void setPassword(String password) {
    emit(state.copyWith(password: password));
  }

  void resetForm() {
    emit(const LoginState());
  }
}
