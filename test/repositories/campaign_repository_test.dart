import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:media_alacarte/data/models/campaign.dart';
import 'package:media_alacarte/data/models/campaign.g.dart';
import 'package:media_alacarte/data/repositories/campaign_repository.dart';
import 'package:media_alacarte/data/services/ads_api_service.dart';

// Mock classes
class MockAdsApiService extends Mock implements AdsApiService {}

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CampaignRepository', () {
    late CampaignRepository repository;
    late MockAdsApiService mockService;

    // Test data
    final testCampaign1 = Campaign(
      id: '1',
      name: 'Test Campaign 1',
      status: 'active',
      objective: 'conversions',
      channel: 'search',
      totalSpend: 1000.0,
      budget: 5000.0,
      impressions: 10000,
      clicks: 500,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      currency: 'USD',
      budgetUtilization: 20.0,
    );

    final testCampaign2 = Campaign(
      id: '2',
      name: 'Test Campaign 2',
      status: 'paused',
      objective: 'awareness',
      channel: 'social',
      totalSpend: 2000.0,
      budget: 3000.0,
      impressions: 20000,
      clicks: 400,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      currency: 'USD',
      budgetUtilization: 66.7,
    );

    final testCampaigns = [testCampaign1, testCampaign2];

    setUp(() async {
      // Initialize Hive in memory for testing
      Hive.init('./test/hive_test');

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CampaignAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(TargetAudienceAdapter());
      }

      mockService = MockAdsApiService();
      repository = CampaignRepository(mockService);
    });

    tearDown(() async {
      // Clean up Hive boxes
      await Hive.deleteFromDisk();
    });

    group('getCampaigns', () {
      test('returns CampaignResult with campaigns when API call succeeds',
          () async {
        // Arrange
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => testCampaigns);

        // Act
        final result = await repository.getCampaigns();

        // Assert
        expect(result.campaigns, testCampaigns);
        expect(result.isFromCache, false);
        verify(() => mockService.getCampaigns()).called(1);
      });

      test('caches campaigns after successful API call', () async {
        // Arrange
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => testCampaigns);

        // Act
        await repository.getCampaigns();

        // Make a second call that will fail
        when(() => mockService.getCampaigns())
            .thenThrow(Exception('Network error'));

        final cachedResult = await repository.getCampaigns();

        // Assert
        expect(cachedResult.campaigns.length, 2);
        expect(cachedResult.campaigns.first.id, '1');
        expect(cachedResult.campaigns.last.id, '2');
        expect(cachedResult.isFromCache, true);
      });

      test('returns cached data when API call fails and cache exists',
          () async {
        // Arrange - First successful call to populate cache
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => testCampaigns);
        await repository.getCampaigns();

        // Arrange - Second call fails
        when(() => mockService.getCampaigns())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getCampaigns();

        // Assert
        expect(result.campaigns.length, 2);
        expect(result.isFromCache, true);
      });

      test('throws error when API fails and no cache exists', () async {
        // Arrange
        when(() => mockService.getCampaigns())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        await expectLater(
          repository.getCampaigns(),
          throwsException,
        );
      });

      test('updates cache with new data on subsequent successful calls',
          () async {
        // Arrange - First call
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => [testCampaign1]);
        await repository.getCampaigns();

        // Arrange - Second call with different data
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => testCampaigns);

        // Act
        final result = await repository.getCampaigns();

        // Assert
        expect(result.campaigns.length, 2);
        expect(result.isFromCache, false);
      });
    });

    group('clearCache', () {
      test('clears the campaigns cache', () async {
        // Arrange - Populate cache
        when(() => mockService.getCampaigns())
            .thenAnswer((_) async => testCampaigns);
        await repository.getCampaigns();

        // Act - Clear cache
        await repository.clearCache();

        // Arrange - API now fails
        when(() => mockService.getCampaigns())
            .thenThrow(Exception('Network error'));

        // Assert - Should throw since cache is cleared
        expect(
          () => repository.getCampaigns(),
          throwsException,
        );
      });
    });

    group('other methods', () {
      test('getCampaign forwards call to service', () async {
        // Arrange
        when(() => mockService.getCampaign('1'))
            .thenAnswer((_) async => testCampaign1);

        // Act
        final result = await repository.getCampaign('1');

        // Assert
        expect(result, testCampaign1);
        verify(() => mockService.getCampaign('1')).called(1);
      });
    });
  });
}
