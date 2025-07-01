import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/utils/result.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      return Result.error(AuthFailure('Email and password are required'));
    }

    if (!_isEmailValid(email)) {
      return Result.error(AuthFailure('Invalid email format'));
    }

    return repository.signIn(email: email, password: password);
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
