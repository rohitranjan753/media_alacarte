import 'package:equatable/equatable.dart';
import '../../../data/models/summary.dart';
import 'spend_summary_event.dart';

/// Base class for all states emitted by [SpendSummaryBloc].
///
/// States represent the different phases of the spend summary screen:
/// initial, loading, loaded with data, or error.
abstract class SpendSummaryState extends Equatable {
  const SpendSummaryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before spend summary data has been loaded.
///
/// This state is active when the bloc is first created and before
/// the [LoadSpendSummary] event is processed.
///
/// **Active during**: Bloc initialization
/// **UI should show**: Loading indicator or splash screen
class SpendSummaryInitial extends SpendSummaryState {
  const SpendSummaryInitial();
}

/// State while spend summary data is being fetched.
///
/// This state can occur during initial load or when changing date ranges.
/// When changing date ranges, [previousSummary] may be non-null to allow
/// the UI to continue displaying stale data while fetching fresh data.
///
/// **Active during**: Data fetch for spend summary
/// **UI should show**: Loading indicator (full-screen if previousSummary is null,
///                     otherwise subtle indicator while showing stale data)
class SpendSummaryLoading extends SpendSummaryState {
  const SpendSummaryLoading({this.previousSummary, this.selectedRange});

  /// The previously loaded summary data, if available.
  ///
  /// Non-null during date range changes to allow the UI to show
  /// stale data while fetching. Null during initial load.
  final Summary? previousSummary;

  /// The date range being loaded.
  ///
  /// Helps the UI display which range is being fetched.
  final DateRangeOption? selectedRange;

  @override
  List<Object?> get props => [previousSummary, selectedRange];
}

/// State when spend summary data has been successfully loaded.
///
/// This state contains all the data needed to display the spend summary screen:
/// - Total spend across all campaigns
/// - Spend breakdown by channel (Search, Social, Display)
/// - List of top-performing campaigns by CTR
/// - The currently selected date range
///
/// **Active during**: Successful data display
/// **UI should show**: KPI cards, donut chart, top campaigns list, and date range selector
class SpendSummaryLoaded extends SpendSummaryState {
  const SpendSummaryLoaded({
    required this.summary,
    required this.selectedRange,
  });

  /// The spend summary data containing all metrics and breakdowns.
  ///
  /// Includes:
  /// - totalSpend: Aggregate spend across all campaigns
  /// - byChannel: Spend breakdown by marketing channel
  /// - topCampaigns: List of campaigns sorted by performance
  /// - dateRange: The time window for the data
  final Summary summary;

  /// The currently selected date range option.
  ///
  /// Used to highlight the active button in the date range selector.
  final DateRangeOption selectedRange;

  /// Computed property: Top 3 campaigns sorted by CTR descending.
  ///
  /// Takes the top campaigns from the summary and returns only the
  /// first 3 after sorting by CTR in descending order.
  ///
  /// Used to display the "Top 3 Campaigns" section in the UI.
  List<TopCampaign> get top3Campaigns {
    final sorted = [...summary.topCampaigns]
      ..sort((a, b) => b.ctr.compareTo(a.ctr));
    return sorted.take(3).toList();
  }

  /// Computed property: Maximum CTR from top campaigns.
  ///
  /// Returns the highest CTR value among the top 3 campaigns,
  /// or 1.0 if no campaigns are available. This is used to scale
  /// the CTR progress bars in the top campaigns list.
  double get maxCtr {
    final top3 = top3Campaigns;
    return top3.isEmpty ? 1.0 : top3.first.ctr;
  }

  @override
  List<Object?> get props => [summary, selectedRange];
}

/// State when an error occurs while fetching spend summary data.
///
/// This state is emitted when the repository throws an exception during
/// a spend summary fetch operation.
///
/// **Active during**: Network errors, API errors, or other fetch failures
/// **UI should show**: Error view with retry button
class SpendSummaryError extends SpendSummaryState {
  const SpendSummaryError(this.message);

  /// The error message describing what went wrong.
  ///
  /// This message is displayed to the user in the error view.
  final String message;

  @override
  List<Object?> get props => [message];
}
