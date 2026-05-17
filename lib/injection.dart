/// Dependency Injection (DI) configuration using GetIt service locator.
///
/// This module sets up all app-wide singleton dependencies in a centralized
/// location, making them accessible throughout the app via the [sl] instance.
///
/// **Registered Dependencies:**
/// - **HTTP Client**: Dio with base URL and timeout configuration
/// - **Services**: API services for campaigns and ML operations
/// - **Repositories**: Data layer with caching support
/// - **Platform Services**: Notifications and onboarding management
///
/// **Usage:**
/// ```dart
/// // In BLoC or screen
/// final repository = sl<CampaignRepository>();
/// final mlService = sl<MlRepository>();
/// ```
///
/// All dependencies are registered as lazy singletons, meaning they're created
/// only when first accessed and then reused throughout the app lifecycle.
library;

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'core/constants/api_constants.dart';
import 'data/repositories/campaign_repository.dart';
import 'data/repositories/ml_repository.dart';
import 'data/services/ads_api_service.dart';
import 'data/services/ml_api_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/onboarding_service.dart';

/// Global service locator instance.
///
/// Provides access to all registered dependencies throughout the app.
/// Use `sl<Type>()` to retrieve a registered dependency.
final sl = GetIt.instance;

/// Initializes and registers all app dependencies.
///
/// Must be called during app startup in `main()` before running the app.
///
/// **Registration Order:**
/// 1. HTTP client (Dio) with base configuration
/// 2. API services (Ads API, ML API)
/// 3. Repositories (Campaign, ML)
/// 4. Platform services (Notifications, Onboarding)
///
/// **HTTP Configuration:**
/// - Base URL: Postman mock server
/// - Connect timeout: 10 seconds
/// - Receive timeout: 15 seconds
///
/// All services are registered as lazy singletons for memory efficiency.
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
