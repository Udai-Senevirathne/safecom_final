import '../../../../Core/utils/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<User?>> getCurrentUser();

  Future<Result<bool>> isSignedIn();

  Future<Result<void>> updateProfile({
    required String fullName,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  });

  Future<Result<User>> getUserProfile();
}
