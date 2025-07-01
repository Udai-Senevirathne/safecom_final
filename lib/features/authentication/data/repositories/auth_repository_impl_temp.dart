import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../../../../Core/error/failures.dart';
import '../../../../Core/error/exceptions.dart';
import '../../../../Core/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Sign up with remote data source
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      // Cache user data locally
      await localDataSource.cacheUserData(user);

      // Set login status
      await localDataSource.setLoginStatus(true);

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with remote data source
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Cache user data locally
      await localDataSource.cacheUserData(user);

      // Set login status
      await localDataSource.setLoginStatus(true);

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      // Sign out from remote
      await remoteDataSource.signOut();

      // Clear local data
      await localDataSource.clearCachedUserData();
      await localDataSource.setLoginStatus(false);

      return Result.success(null);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUserData();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      }

      // If not in cache, get from remote
      final user = await remoteDataSource.getCurrentUser();
      if (user != null) {
        await localDataSource.cacheUserData(user);
      }

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<bool>> isSignedIn() async {
    try {
      // Check local login status first
      final localStatus = await localDataSource.getLoginStatus();
      if (!localStatus) {
        return Result.success(false);
      }

      // Verify with remote if local status is true
      final remoteStatus = await remoteDataSource.isSignedIn();

      // If remote status doesn't match local, update local
      if (remoteStatus != localStatus) {
        await localDataSource.setLoginStatus(remoteStatus);
      }

      return Result.success(remoteStatus);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<void>> updateProfile({
    required String fullName,
    String? phone,
    String? address,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      // Update profile on remote
      await remoteDataSource.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      // Get updated user data and cache it
      final updatedUser = await remoteDataSource.getUserProfile();
      await localDataSource.cacheUserData(updatedUser);

      return Result.success(null);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Result<User>> getUserProfile() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUserData();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      }

      // If not in cache, get from remote
      final user = await remoteDataSource.getUserProfile();
      await localDataSource.cacheUserData(user);

      return Result.success(user);
    } on AuthException catch (e) {
      return Result.error(AuthFailure(e.message));
    } on CacheException catch (e) {
      return Result.error(CacheFailure(e.message));
    } catch (e) {
      return Result.error(AuthFailure('An unexpected error occurred'));
    }
  }
}
