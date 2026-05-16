import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_texts.dart';
import '../../data/repositories/campaign_repository.dart';
import '../../injection.dart';
import '../../presentation/campaign_detail/campaign_detail_screen.dart';
import '../../shared/widgets/empty_state_view.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/shimmer_layouts.dart';
import 'bloc/campaign_list_bloc.dart';
import 'bloc/campaign_list_event.dart';
import 'bloc/campaign_list_state.dart';
import 'widgets/filter_bar.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/animated_campaign_card.dart';

class CampaignListScreen extends StatelessWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignListBloc(sl<CampaignRepository>())
        ..add(const LoadCampaigns()),
      child: const _CampaignListView(),
    );
  }
}

class _CampaignListView extends StatefulWidget {
  const _CampaignListView();

  @override
  State<_CampaignListView> createState() => _CampaignListViewState();
}

class _CampaignListViewState extends State<_CampaignListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null) {
        if (notification.scrollDelta! > 0 && _showFab) {
          setState(() => _showFab = false);
          _fabController.reverse();
        } else if (notification.scrollDelta! < 0 && !_showFab) {
          setState(() => _showFab = true);
          _fabController.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppTexts.campaignsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          BlocBuilder<CampaignListBloc, CampaignListState>(
            builder: (context, state) {
              if (state is CampaignListLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.campaigns.length} ${state.campaigns.length == 1 ? AppTexts.campaign : AppTexts.campaigns}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (state is CampaignListLoaded && state.isRefreshing) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: BlocBuilder<CampaignListBloc, CampaignListState>(
          builder: (context, state) {
            if (state is CampaignListLoading) {
              return Column(
                children: [
                  // Search bar shimmer
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                    ),
                  ),
                  // Filter bar shimmer
                  const SizedBox(
                    height: 50,
                    child: CampaignListShimmer(itemCount: 0),
                  ),
                  // Campaign cards shimmer
                  const Expanded(
                    child: CampaignListShimmer(itemCount: 6),
                  ),
                ],
              );
            }

            if (state is CampaignListError) {
              return ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<CampaignListBloc>().add(const LoadCampaigns()),
              );
            }

            if (state is CampaignListLoaded) {
              final counts = {
                'all': state.allCampaigns.length,
                'active': state.allCampaigns
                    .where((c) => c.status.toLowerCase() == 'active')
                    .length,
                'paused': state.allCampaigns
                    .where((c) => c.status.toLowerCase() == 'paused')
                    .length,
              };

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  context
                      .read<CampaignListBloc>()
                      .add(const RefreshCampaigns());
                  await context.read<CampaignListBloc>().stream.firstWhere(
                        (s) =>
                            s is CampaignListLoaded && !s.isRefreshing ||
                            s is CampaignListError,
                      );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Search Bar with animation
                    SliverToBoxAdapter(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: SearchBarWidget(
                          onSearchChanged: (query) => context
                              .read<CampaignListBloc>()
                              .add(SearchCampaigns(query)),
                        ),
                      ),
                    ),

                    // Filter Bar with animation
                    SliverToBoxAdapter(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FilterBar(
                            selected: state.filter,
                            campaignCounts: counts,
                            onFilterChanged: (filter) => context
                                .read<CampaignListBloc>()
                                .add(FilterCampaigns(filter)),
                          ),
                        ),
                      ),
                    ),

                    // Campaign List
                    if (state.campaigns.isEmpty)
                      const SliverFillRemaining(
                        child: EmptyStateView(
                          title: AppTexts.noCampaigns,
                          message: AppTexts.noCampaignsFound,
                          subtitle: AppTexts.noCampaignsSubtitle,
                          icon: Icons.campaign_outlined,
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final campaign = state.campaigns[index];
                            return AnimatedCampaignCard(
                              key: ValueKey(campaign.id),
                              index: index,
                              campaign: campaign,
                              onTap: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      CampaignDetailScreen(
                                    campaignId: campaign.id,
                                  ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOut;
                                    final tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          childCount: state.campaigns.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
