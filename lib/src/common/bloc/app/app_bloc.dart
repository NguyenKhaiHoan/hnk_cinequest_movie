import 'package:cinequest/src/common/constants/app_keys.dart';
import 'package:cinequest/src/core/errors/failure.dart';
import 'package:cinequest/src/core/repositories/user_repository.dart';
import 'package:cinequest/src/core/routes/route_pages.dart';
import 'package:cinequest/src/external/services/storage/local/get_storage_service.dart';
import 'package:cinequest/src/external/services/storage/local/sqlite_service.dart';
import 'package:cinequest/src/features/auth/domain/entities/params/get_profile_user_params.dart';
import 'package:cinequest/src/features/auth/domain/usecases/get_profile_user_use_case.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

/// Quản lý trạng thái của App khi vừa bắt đầu app hoặc thay đổi trạng thái
/// xác thực
class AppBloc extends Bloc<AppEvent, AppState> {
  /// Constructor
  AppBloc({
    required FirebaseAuth firebaseAuth,
    required GetProfileUserUseCase getProfileUserUseCase,
    required UserRepository userRepository,
    required GetStorageService getStorageService,
  })  : _firebaseAuth = firebaseAuth,
        _useCase = getProfileUserUseCase,
        _repository = userRepository,
        _service = getStorageService,
        super(const AppInitialState()) {
    on<AppEvent>((event, emit) async {
      await event.map(
        started: (event) async => _onStarted(event, emit),
      );
    });
  }

  final FirebaseAuth _firebaseAuth;
  final GetProfileUserUseCase _useCase;
  final UserRepository _repository;
  final GetStorageService _service;

  Future<void> _onStarted(
    EventAppStarted event,
    Emitter<AppState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    // Xét nếu user của firebase là null tức app chưa được đăng nhập
    if (user != null) {
      // Nếu user khác null tức đã đăng nhập thì lấy data từ firestore về
      final result = await _useCase.call(
        params: GetProfileUserParams(userId: user.uid),
      );

      /// Khởi tạo storage để lưu trạng thái đã setup account hay chưa.
      /// Nếu trạng thái là null thì cho mặc định là `false`
      await GetStorageService.initializeStorage(user.uid);
      if (_service.getData<bool>('IsSetupAccout') == null) {
        await _service.saveData<bool>('IsSetupAccout', false);
      }
      await result.fold(
        (failure) async {
          /// Lỗi không lấy được data xảy ra 2 trường hợp
          ///
          /// - Do chưa setup account nên chưa đẩy thông tin user lên Firebase
          /// vì vậy Firebase sẽ đưa ra lỗi
          /// - Do các lỗi Firebase khác: lỗi mạng không thể truy cập vào
          /// Firebase để lấy dữ liệu, ...
          if (_service.getData<bool>('IsSetupAccout') == false) {
            emit(const AppState.accountNotSetup());
          } else {
            emit(AppState.unAuthenticated(failure: failure));
          }
        },
        (data) async {
          // Nếu user khác null tức đã đăng nhập thì lấy data từ firestore về
          // dữ liệu user mới trong app
          _repository.setUser(data);
          await _service.saveData<bool>('IsSetupAccout', true);
          await SqliteService.initializeDatabase(user.uid, _createDatabase);
          // Cập nhật trạng thái app đã xác thực
          emit(const AppState.authenticated());
        },
      );
    } else {
      emit(const AppState.unAuthenticated());
    }
    RouterPages.router.refresh();
  }

  Future<void> _createDatabase(Database table, int _) async {
    await table.execute('''
    CREATE TABLE $favouriteMoviesTableKey(
      $colId INTEGER PRIMARY KEY,
      $colAdult INTEGER,
      $colBackdropPath TEXT,
      $colGenreIds TEXT, 
      $colOriginalLanguage TEXT,
      $colOriginalTitle TEXT,
      $colOverview TEXT,
      $colPopularity REAL,
      $colPosterPath TEXT,
      $colReleaseDate TEXT,
      $colTitle TEXT,
      $colVideo INTEGER,
      $colVoteAverage REAL,
      $colVoteCount INTEGER
    )
    ''');
  }
}
