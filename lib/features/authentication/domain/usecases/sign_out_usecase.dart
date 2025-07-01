import '../repositories/auth_repository.dart';
import '../../../../Core/utils/result.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Result<void>> call() async {
    return repository.signOut();
  }
}
