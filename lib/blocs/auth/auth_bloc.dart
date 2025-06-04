import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginWithPhone>(_onLoginWithPhone);
    on<VerifyOtp>(_onVerifyOtp);
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLoginWithPhone(LoginWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.loginWithPhone(
      event.phoneNumber,
      codeSent: (verificationId) {
        emit(AuthCodeSent(verificationId));
      },
      onFailed: (error) {
        emit(AuthFailure(error.message ?? 'Phone auth failed'));
      },
    );
  }

  Future<void> _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyOtp(event.verificationId, event.otp);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLoginWithEmail(LoginWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.loginWithEmail(event.email, event.password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthLoggedOut());
  }
}

