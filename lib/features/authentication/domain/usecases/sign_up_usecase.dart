import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/utils/result.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Result<User>> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    // Validate inputs
    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty) {
      return Result.error(AuthFailure('All fields are required'));
    }

    if (!_isEmailValid(email)) {
      return Result.error(AuthFailure('Invalid email format'));
    }

    if (password.length < 6) {
      return Result.error(WeakPasswordFailure());
    }

    if (!_isPhoneValid(phone)) {
      return Result.error(AuthFailure('Invalid phone number format'));
    }

    return await repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isPhoneValid(String phone) {
    // Sri Lankan phone number validation
    return RegExp(r'^(\+94|0)?[1-9][0-9]{8}$').hasMatch(phone);
  }
}
