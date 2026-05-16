import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:media_alacarte/data/models/campaign.dart';
import 'package:media_alacarte/data/repositories/campaign_repository.dart';
import 'package:media_alacarte/presentation/campaign_list/bloc/campaign_list_bloc.dart';
import 'package:media_alacarte/presentation/campaign_list/bloc/campaign_list_event.dart';
import 'package:media_alacarte/presentation/campaign_list/bloc/campaign_list_state.dart';

// Mock classes
class MockCampaignRepository extends Mock implements CampaignRepository {}

void main() {
  group('CampaignListBloc', () {
    late CampaignListBloc bloc;
    late MockCampaignRepository mockRepository;

    // Test data
    final testCampaign1 = Campaign(
      id: '1',
      name: 'Active Campaign',
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
      name: 'Paused Campaign',
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

    final testCampaign3 = Campaign(
      id: '3',
      name: 'Another Active Campaign',
      status: 'active',
      objective: 'traffic',
      channel: 'display',
      totalSpend: 500.0,
      budget: 2000.0,
      impressions: 5000,
      clicks: 250,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      currency: 'USD',
      budgetUtilization: 25.0,
    );

    final testCampaigns = [testCampaign1, testCampaign2, testCampaign3];
    final testResult = CampaignResult(
      campaigns: testCampaigns,
      isFromCache: false,
    );

    setUp(() {
      mockRepository = MockCampaignRepository();
      bloc = CampaignListBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is CampaignListInitial', () {
      expect(bloc.state, const CampaignListInitial());
    });

    group('LoadCampaigns', () {
      blocTest<CampaignListBloc, CampaignListState>(
        'emits [Loading, Loaded] when getCampaigns succeeds',
        build: () {
          when(() => mockRepository.getCampaigns())
              .thenAnswer((_) async => testResult);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCampaigns()),
        expect: () => [
          const CampaignListLoading(),
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: testCampaigns,
            filter: 'all',
            isFromCache: false,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getCampaigns()).called(1);
        },
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'emits [Loading, Loaded] with isFromCache=true when data is from cache',
        build: () {
          when(() => mockRepository.getCampaigns()).thenAnswer(
            (_) async => CampaignResult(
              campaigns: testCampaigns,
              isFromCache: true,
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCampaigns()),
        expect: () => [
          const CampaignListLoading(),
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: testCampaigns,
            filter: 'all',
            isFromCache: true,
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'emits [Loading, Error] when getCampaigns fails',
        build: () {
          when(() => mockRepository.getCampaigns())
              .thenThrow(Exception('Network error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCampaigns()),
        expect: () => [
          const CampaignListLoading(),
          const CampaignListError('Exception: Network error'),
        ],
      );
    });

    group('RefreshCampaigns', () {
      blocTest<CampaignListBloc, CampaignListState>(
        'sets isRefreshing=true while fetching',
        build: () {
          when(() => mockRepository.getCampaigns())
              .thenAnswer((_) async => testResult);
          return bloc;
        },
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const RefreshCampaigns()),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: testCampaigns,
            filter: 'all',
            isRefreshing: true,
          ),
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: testCampaigns,
            filter: 'all',
            isRefreshing: false,
            isFromCache: false,
          ),
        ],
      );
    });

    group('FilterCampaigns', () {
      blocTest<CampaignListBloc, CampaignListState>(
        'filters campaigns by active status',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const FilterCampaigns('active')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: [testCampaign1, testCampaign3], // Only active campaigns
            filter: 'active',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'filters campaigns by paused status',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const FilterCampaigns('paused')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: [testCampaign2], // Only paused campaign
            filter: 'paused',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'shows all campaigns when filter is "all"',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: [testCampaign1],
          filter: 'active',
        ),
        act: (bloc) => bloc.add(const FilterCampaigns('all')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: testCampaigns,
            filter: 'all',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'does nothing when state is not CampaignListLoaded',
        build: () => bloc,
        seed: () => const CampaignListLoading(),
        act: (bloc) => bloc.add(const FilterCampaigns('active')),
        expect: () => [],
      );
    });

    group('SearchCampaigns', () {
      blocTest<CampaignListBloc, CampaignListState>(
        'filters campaigns by search query (name)',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const SearchCampaigns('Active')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: [
              testCampaign1,
              testCampaign3
            ], // Campaigns with "Active" in name
            filter: 'all',
            searchQuery: 'Active',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'filters campaigns by search query (channel)',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const SearchCampaigns('search')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: [testCampaign1], // Campaign with "search" channel
            filter: 'all',
            searchQuery: 'search',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'returns empty list when no campaigns match search query',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: testCampaigns,
          filter: 'all',
        ),
        act: (bloc) => bloc.add(const SearchCampaigns('NonExistent')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: const [],
            filter: 'all',
            searchQuery: 'NonExistent',
          ),
        ],
      );

      blocTest<CampaignListBloc, CampaignListState>(
        'combines filter and search query',
        build: () => bloc,
        seed: () => CampaignListLoaded(
          allCampaigns: testCampaigns,
          campaigns: [testCampaign1, testCampaign3], // Already filtered to active
          filter: 'active',
        ),
        act: (bloc) => bloc.add(const SearchCampaigns('Another')),
        expect: () => [
          CampaignListLoaded(
            allCampaigns: testCampaigns,
            campaigns: [testCampaign3], // Active + contains "Another"
            filter: 'active',
            searchQuery: 'Another',
          ),
        ],
      );
    });
  });
}
