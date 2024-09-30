import 'package:cinequest/src/core/generics/type_def.dart';
import 'package:cinequest/src/core/generics/usecase.dart';
import 'package:cinequest/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:cinequest/src/features/auth/domain/usecases/params/auth_params.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Use case đăng nhập
class LoginUseCase extends UseCase<UserCredential, AuthParams> {
  /// Constructor
  LoginUseCase(this._authRepository);
  final AuthRepository _authRepository;

  @override
  FutureEither<UserCredential> call({AuthParams? params}) {
    return _authRepository.login(params!);
  }
}
