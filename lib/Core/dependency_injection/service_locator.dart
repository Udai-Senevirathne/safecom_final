import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Features - Authentication
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/sign_up_usecase.dart';
import '../../features/authentication/domain/usecases/sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/sign_out_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

// Features - Weather
import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../../features/weather/data/datasources/weather_local_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_current_weather_usecase.dart';
import '../../features/weather/domain/usecases/get_weather_forecast_usecase.dart';
import '../../features/weather/domain/usecases/get_current_location_usecase.dart';
import '../../features/weather/presentation/bloc/weather_bloc.dart';

// Features - Safety
import '../../features/safety/data/datasources/safety_remote_datasource.dart';
import '../../features/safety/data/repositories/safety_repository_impl.dart';
import '../../features/safety/domain/repositories/safety_repository.dart';
import '../../features/safety/domain/usecases/get_safety_status_usecase.dart';
import '../../features/safety/domain/usecases/submit_incident_usecase.dart';

// Features - Reporting
import '../../features/reporting/data/datasources/reporting_remote_datasource.dart';
import '../../features/reporting/data/repositories/reporting_repository_impl.dart';
import '../../features/reporting/domain/repositories/reporting_repository.dart';
import '../../features/reporting/domain/usecases/submit_disaster_report_usecase.dart';
import '../../features/reporting/domain/usecases/submit_harassment_report_usecase.dart';
import '../../features/reporting/presentation/bloc/reporting_bloc.dart';

// Legacy Services (to be phased out)

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Authentication
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  //! Features - Weather
  // Bloc
  sl.registerFactory(
    () => WeatherBloc(
      getCurrentWeatherUseCase: sl(),
      getWeatherForecastUseCase: sl(),
      getCurrentLocationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentWeatherUseCase(sl()));
  sl.registerLazySingleton(() => GetWeatherForecastUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentLocationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<WeatherLocalDataSource>(
    () => WeatherLocalDataSourceImpl(),
  );

  //! Features - Safety
  // Use cases
  sl.registerLazySingleton(() => GetSafetyStatusUseCase(sl()));
  sl.registerLazySingleton(() => SubmitIncidentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SafetyRepository>(
    () => SafetyRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SafetyRemoteDataSource>(
    () => SafetyRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Reporting
  // Bloc
  sl.registerFactory(
    () => ReportingBloc(
      submitDisasterReportUseCase: sl(),
      submitHarassmentReportUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SubmitDisasterReportUseCase(sl()));
  sl.registerLazySingleton(() => SubmitHarassmentReportUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ReportingRepository>(
    () => ReportingRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ReportingRemoteDataSource>(
    () => ReportingRemoteDataSourceImpl(firestore: sl()),
  );

  // Authentication Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Authentication Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Authentication Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! External Dependencies
  sl.registerLazySingleton(() => http.Client());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}


// This file sets up the service locator for dependency injection using GetIt.
// It registers all the necessary dependencies for the authentication feature,