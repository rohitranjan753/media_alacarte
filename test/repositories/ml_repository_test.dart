import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:media_alacarte/data/models/anomaly.dart';
import 'package:media_alacarte/data/models/daily_metric.dart';
import 'package:media_alacarte/data/models/forecast_point.dart';
import 'package:media_alacarte/data/models/snapshot.dart';
import 'package:media_alacarte/data/repositories/ml_repository.dart';
import 'package:media_alacarte/data/services/ml_api_service.dart';

// Mock classes
class MockMlApiService extends Mock implements MlApiService {}

// Fake classes for mocktail
class FakeSnapshot extends Fake implements Snapshot {}

class FakeDailyMetric extends Fake implements DailyMetric {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSnapshot());
    registerFallbackValue(<DailyMetric>[]);
  });

  group('MlRepository', () {
    late MlRepository repository;
    late MockMlApiService mockService;

    // Test data
    final testHistory = [
      DailyMetric(date: DateTime(2024, 1, 1), ctr: 3.5),
      DailyMetric(date: DateTime(2024, 1, 2), ctr: 3.7),
      DailyMetric(date: DateTime(2024, 1, 3), ctr: 3.6),
    ];

    final testForecastPoints = [
      ForecastPoint(
        date: DateTime(2024, 1, 4),
        predictedCtr: 3.8,
        lowerBound: 3.2,
        upperBound: 4.4,
      ),
      ForecastPoint(
        date: DateTime(2024, 1, 5),
        predictedCtr: 3.9,
        lowerBound: 3.3,
        upperBound: 4.5,
      ),
      ForecastPoint(
        date: DateTime(2024, 1, 6),
        predictedCtr: 4.0,
        lowerBound: 3.4,
        upperBound: 4.6,
      ),
    ];

    final testSnapshot = Snapshot(
      timestamp: DateTime(2024, 1, 1, 12, 0),
      campaigns: const [
        CampaignSnapshot(
          id: '1',
          impressionsLastHour: 10000,
          clicksLastHour: 450,
          spendLastHour: 500.0,
          ctrLastHour: 4.5,
        ),
        CampaignSnapshot(
          id: '2',
          impressionsLastHour: 5000,
          clicksLastHour: 100,
          spendLastHour: 200.0,
          ctrLastHour: 2.0,
        ),
      ],
    );

    final testAnomalies = [
      Anomaly(
        campaignId: '1',
        type: 'spend_spike',
        severity: 'high',
        message: 'Spend increased by 45% in the last hour',
        detectedAt: DateTime(2024, 1, 1, 12, 0),
        campaignName: 'Test Campaign 1',
        actualValue: 500.0,
        expectedValue: 345.0,
        changePercentage: 45.0,
      ),
      Anomaly(
        campaignId: '2',
        type: 'ctr_drop',
        severity: 'medium',
        message: 'CTR dropped by 20% in the last hour',
        detectedAt: DateTime(2024, 1, 1, 12, 0),
        campaignName: 'Test Campaign 2',
        actualValue: 2.0,
        expectedValue: 2.5,
        changePercentage: -20.0,
      ),
    ];

    setUp(() {
      mockService = MockMlApiService();
      repository = MlRepository(mockService);
    });

    group('getForecast', () {
      test('returns forecast points when API call succeeds', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => testForecastPoints);

        // Act
        final result = await repository.getForecast(
          campaignId: '1',
          history: testHistory,
        );

        // Assert
        expect(result, testForecastPoints);
        expect(result.length, 3);
        expect(result.first.predictedCtr, 3.8);
        expect(result.last.predictedCtr, 4.0);
        verify(() => mockService.getForecast(
              campaignId: '1',
              history: testHistory,
            )).called(1);
      });

      test('sends correct request parameters', () async {
        // Arrange
        const campaignId = 'test-campaign-123';
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => testForecastPoints);

        // Act
        await repository.getForecast(
          campaignId: campaignId,
          history: testHistory,
        );

        // Assert
        final captured = verify(() => mockService.getForecast(
              campaignId: captureAny(named: 'campaignId'),
              history: captureAny(named: 'history'),
            )).captured;

        expect(captured[0], campaignId);
        expect(captured[1], testHistory);
      });

      test('maps response to ForecastPoint list correctly', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => testForecastPoints);

        // Act
        final result = await repository.getForecast(
          campaignId: '1',
          history: testHistory,
        );

        // Assert
        expect(result, isA<List<ForecastPoint>>());
        expect(result[0].date, DateTime(2024, 1, 4));
        expect(result[0].lowerBound, 3.2);
        expect(result[0].upperBound, 4.4);
      });

      test('throws exception when API call fails', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenThrow(Exception('ML service unavailable'));

        // Act & Assert
        expect(
          () => repository.getForecast(
            campaignId: '1',
            history: testHistory,
          ),
          throwsException,
        );
      });

      test('handles empty forecast response', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getForecast(
          campaignId: '1',
          history: testHistory,
        );

        // Assert
        expect(result, isEmpty);
      });

      test('handles empty history input', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => testForecastPoints);

        // Act
        final result = await repository.getForecast(
          campaignId: '1',
          history: [],
        );

        // Assert
        expect(result, testForecastPoints);
        final captured = verify(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: captureAny(named: 'history'),
            )).captured;
        expect(captured[0], isEmpty);
      });
    });

    group('detectAnomalies', () {
      test('returns anomalies when API call succeeds', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => testAnomalies);

        // Act
        final result = await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        expect(result, testAnomalies);
        expect(result.length, 2);
        expect(result[0].type, 'spend_spike');
        expect(result[1].type, 'ctr_drop');
        verify(() => mockService.detectAnomalies(snapshot: testSnapshot))
            .called(1);
      });

      test('sends correct snapshot data', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => testAnomalies);

        // Act
        await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        final captured = verify(() => mockService.detectAnomalies(
              snapshot: captureAny(named: 'snapshot'),
            )).captured;

        expect(captured[0], testSnapshot);
        expect(captured[0], isA<Snapshot>());
      });

      test('maps response to Anomaly list correctly', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => testAnomalies);

        // Act
        final result = await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        expect(result, isA<List<Anomaly>>());
        expect(result[0].campaignId, '1');
        expect(result[0].severity, 'high');
        expect(result[0].changePercentage, 45.0);
        expect(result[1].campaignId, '2');
        expect(result[1].severity, 'medium');
        expect(result[1].changePercentage, -20.0);
      });

      test('throws exception when API call fails', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenThrow(Exception('Anomaly detection service unavailable'));

        // Act & Assert
        expect(
          () => repository.detectAnomalies(snapshot: testSnapshot),
          throwsException,
        );
      });

      test('handles empty anomalies response', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        expect(result, isEmpty);
      });

      test('handles snapshot with no campaigns', () async {
        // Arrange
        final emptySnapshot = Snapshot(
          timestamp: DateTime(2024, 1, 1, 12, 0),
          campaigns: const [],
        );
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => []);

        // Act
        final result =
            await repository.detectAnomalies(snapshot: emptySnapshot);

        // Assert
        expect(result, isEmpty);
        verify(() => mockService.detectAnomalies(snapshot: emptySnapshot))
            .called(1);
      });

      test('preserves anomaly metadata in response', () async {
        // Arrange
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => testAnomalies);

        // Act
        final result = await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        expect(result[0].campaignName, 'Test Campaign 1');
        expect(result[0].actualValue, 500.0);
        expect(result[0].expectedValue, 345.0);
        expect(result[1].campaignName, 'Test Campaign 2');
        expect(result[1].actualValue, 2.0);
        expect(result[1].expectedValue, 2.5);
      });
    });

    group('integration', () {
      test('can call both methods sequentially', () async {
        // Arrange
        when(() => mockService.getForecast(
              campaignId: any(named: 'campaignId'),
              history: any(named: 'history'),
            )).thenAnswer((_) async => testForecastPoints);
        when(() => mockService.detectAnomalies(snapshot: any(named: 'snapshot')))
            .thenAnswer((_) async => testAnomalies);

        // Act
        final forecast = await repository.getForecast(
          campaignId: '1',
          history: testHistory,
        );
        final anomalies =
            await repository.detectAnomalies(snapshot: testSnapshot);

        // Assert
        expect(forecast, testForecastPoints);
        expect(anomalies, testAnomalies);
      });
    });
  });
}
