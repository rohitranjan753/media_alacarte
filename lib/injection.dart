import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/constants/api_constants.dart';
import 'data/repositories/campaign_repository.dart';
import 'data/repositories/ml_repository.dart';
import 'data/services/ads_api_service.dart';
import 'data/services/ml_api_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/onboarding_service.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ));

  sl.registerLazySingleton<AdsApiService>(() => AdsApiService(sl()));
  sl.registerLazySingleton<MlApiService>(() => MlApiService(sl()));

  sl.registerLazySingleton<CampaignRepository>(
      () => CampaignRepository(sl()));
  sl.registerLazySingleton<MlRepository>(() => MlRepository(sl()));

  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<OnboardingService>(() => OnboardingService());
}
