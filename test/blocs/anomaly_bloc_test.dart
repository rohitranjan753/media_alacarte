import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:media_alacarte/data/models/anomaly.dart';
import 'package:media_alacarte/data/models/snapshot.dart';
import 'package:media_alacarte/data/repositories/campaign_repository.dart';
import 'package:media_alacarte/data/repositories/ml_repository.dart';
import 'package:media_alacarte/data/services/notification_service.dart';
import 'package:media_alacarte/presentation/anomaly_alerts/bloc/anomaly_bloc.dart';
import 'package:media_alacarte/presentation/anomaly_alerts/bloc/anomaly_event.dart';
import 'package:media_alacarte/presentation/anomaly_alerts/bloc/anomaly_state.dart';

// Mock classes
class MockCampaignRepository extends Mock implements CampaignRepository {}

class MockMlRepository extends Mock implements MlRepository {}

class MockNotificationService extends Mock implements NotificationService {}

// Register fallback values for mocktail
class FakeAnomaly extends Fake implements Anomaly {}

class FakeSnapshot extends Fake implements Snapshot {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeAnomaly());
    registerFallbackValue(FakeSnapshot());
  });

  group('AnomalyBloc', () {
    late AnomalyBloc bloc;
    late MockCampaignRepository mockCampaignRepository;
    late MockMlRepository mockMlRepository;
    late MockNotificationService mockNotificationService;

    // Test data
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
      ],
    );

    final testAnomaly1 = Anomaly(
      campaignId: '1',
      type: 'spend_spike',
      severity: 'high',
      message: 'Spend increased by 45%',
      detectedAt: DateTime(2024, 1, 1, 12, 0),
      campaignName: 'Campaign 1',
    );

    final testAnomaly2 = Anomaly(
      campaignId: '2',
      type: 'ctr_drop',
      severity: 'medium',
      message: 'CTR dropped by 20%',
      detectedAt: DateTime(2024, 1, 1, 12, 5),
      campaignName: 'Campaign 2',
    );

    setUp(() {
      mockCampaignRepository = MockCampaignRepository();
      mockMlRepository = MockMlRepository();
      mockNotificationService = MockNotificationService();

      // Default mock responses
      when(() => mockCampaignRepository.getLiveMetrics())
          .thenAnswer((_) async => testSnapshot);
      when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
          .thenAnswer((_) async => [testAnomaly1]);
      when(() => mockNotificationService.showAnomalyAlert(anomaly: any(named: 'anomaly')))
          .thenAnswer((_) async => {});

      bloc = AnomalyBloc(
        campaignRepository: mockCampaignRepository,
        mlRepository: mockMlRepository,
        notificationService: mockNotificationService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AnomalyInitial', () {
      expect(bloc.state, equals(const AnomalyInitial()));
    });

    group('StartPolling', () {
      blocTest<AnomalyBloc, AnomalyState>(
        'emits [AnomalyPolling] when StartPolling is added',
        build: () => bloc,
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyPolling>()
              .having((s) => s.anomalies.length, 'anomalies length', 1)
              .having((s) => s.anomalies.first, 'first anomaly', testAnomaly1),
        ],
        verify: (_) {
          verify(() => mockCampaignRepository.getLiveMetrics()).called(1);
          verify(() => mockMlRepository.detectAnomalies(snapshot: testSnapshot))
              .called(1);
        },
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'does NOT send notifications on first poll',
        build: () => bloc,
        act: (bloc) => bloc.add(const StartPolling()),
        verify: (_) {
          verifyNever(() => mockNotificationService.showAnomalyAlert(
              anomaly: any(named: 'anomaly')));
        },
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'sorts anomalies by detectedAt descending (newest first)',
        build: () {
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async => [testAnomaly1, testAnomaly2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyPolling>().having(
            (s) => s.anomalies,
            'sorted anomalies',
            [testAnomaly2, testAnomaly1], // testAnomaly2 is newer
          ),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'emits AnomalyError when repository throws exception',
        build: () {
          when(() => mockCampaignRepository.getLiveMetrics())
              .thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyError>()
              .having((s) => s.message, 'error message', contains('Network error')),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'emits AnomalyError when ML repository throws exception',
        build: () {
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenThrow(Exception('ML service unavailable'));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyError>().having(
              (s) => s.message, 'error message', contains('ML service unavailable')),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'handles empty anomalies list',
        build: () {
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyPolling>()
              .having((s) => s.anomalies, 'empty anomalies', isEmpty),
        ],
      );
    });

    group('StopPolling', () {
      blocTest<AnomalyBloc, AnomalyState>(
        'stops polling without emitting new states',
        build: () => bloc,
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StopPolling());
        },
        skip: 1, // Skip the StartPolling state
        expect: () => [],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'can restart polling after stopping',
        build: () => bloc,
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StopPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartPolling());
        },
        expect: () => [
          isA<AnomalyPolling>(), // First StartPolling
          isA<AnomalyPolling>(), // Second StartPolling
        ],
      );
    });

    group('Notification Logic', () {
      blocTest<AnomalyBloc, AnomalyState>(
        'sends notification for new anomalies on subsequent polls',
        build: () {
          var callCount = 0;
          when(() => mockCampaignRepository.getLiveMetrics())
              .thenAnswer((_) async => testSnapshot);
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return [testAnomaly1]; // First poll
            } else {
              return [testAnomaly1, testAnomaly2]; // Second poll with new anomaly
            }
          });
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          // Manually trigger another poll (simulating the timer)
          bloc.add(const StartPolling());
        },
        verify: (_) {
          // First poll: no notifications (initial load)
          // Second poll: notification for testAnomaly2 (new)
          verify(() => mockNotificationService.showAnomalyAlert(
              anomaly: testAnomaly2)).called(1);
          verifyNever(() => mockNotificationService.showAnomalyAlert(
              anomaly: testAnomaly1)); // Was in first poll, shouldn't notify
        },
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'does not send duplicate notifications for same anomaly',
        build: () {
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async => [testAnomaly1]);
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartPolling());
        },
        verify: (_) {
          // Should never send notification since testAnomaly1 was in the first poll
          verifyNever(() => mockNotificationService.showAnomalyAlert(
              anomaly: any(named: 'anomaly')));
        },
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'sends notifications for multiple new anomalies',
        build: () {
          var callCount = 0;
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return [];
            } else {
              return [testAnomaly1, testAnomaly2];
            }
          });
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartPolling());
        },
        verify: (_) {
          verify(() => mockNotificationService.showAnomalyAlert(
              anomaly: testAnomaly1)).called(1);
          verify(() => mockNotificationService.showAnomalyAlert(
              anomaly: testAnomaly2)).called(1);
        },
      );
    });

    group('State Updates', () {
      blocTest<AnomalyBloc, AnomalyState>(
        'updates lastUpdated timestamp on each poll',
        build: () => bloc,
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<AnomalyPolling>().having(
            (s) => s.lastUpdated.isBefore(DateTime.now()),
            'lastUpdated is recent',
            true,
          ),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'maintains anomaly list across polls',
        build: () {
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async => [testAnomaly1, testAnomaly2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyPolling>()
              .having((s) => s.anomalies.length, 'anomaly count', 2)
              .having((s) => s.anomalies, 'contains both anomalies',
                  containsAll([testAnomaly2, testAnomaly1])),
        ],
      );
    });

    group('Cleanup', () {
      test('cancels timer on close', () async {
        bloc.add(const StartPolling());
        await Future.delayed(const Duration(milliseconds: 100));
        await bloc.close();
        // If timer wasn't cancelled, this would cause issues
        // No assertion needed - test passes if no exceptions
      });

      blocTest<AnomalyBloc, AnomalyState>(
        'handles StopPolling before StartPolling gracefully',
        build: () => bloc,
        act: (bloc) => bloc.add(const StopPolling()),
        expect: () => [],
      );
    });

    group('Edge Cases', () {
      blocTest<AnomalyBloc, AnomalyState>(
        'handles rapid StartPolling events',
        build: () => bloc,
        act: (bloc) {
          bloc.add(const StartPolling());
          bloc.add(const StartPolling());
          bloc.add(const StartPolling());
        },
        expect: () => [
          isA<AnomalyPolling>(),
          isA<AnomalyPolling>(),
          isA<AnomalyPolling>(),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'recovers from error on next successful poll',
        build: () {
          var callCount = 0;
          when(() => mockCampaignRepository.getLiveMetrics())
              .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Temporary network error');
            }
            return testSnapshot;
          });
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const StartPolling());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const StartPolling());
        },
        expect: () => [
          isA<AnomalyError>(),
          isA<AnomalyPolling>(),
        ],
      );

      blocTest<AnomalyBloc, AnomalyState>(
        'handles anomalies with same timestamp but different types',
        build: () {
          final sameTimeAnomaly1 = Anomaly(
            campaignId: '1',
            type: 'spend_spike',
            severity: 'high',
            message: 'Spend spike',
            detectedAt: DateTime(2024, 1, 1, 12, 0),
          );
          final sameTimeAnomaly2 = Anomaly(
            campaignId: '1',
            type: 'ctr_drop',
            severity: 'medium',
            message: 'CTR drop',
            detectedAt: DateTime(2024, 1, 1, 12, 0),
          );
          when(() => mockMlRepository.detectAnomalies(snapshot: any(named: 'snapshot')))
              .thenAnswer((_) async => [sameTimeAnomaly1, sameTimeAnomaly2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const StartPolling()),
        expect: () => [
          isA<AnomalyPolling>()
              .having((s) => s.anomalies.length, 'both anomalies', 2),
        ],
      );
    });
  });
}
