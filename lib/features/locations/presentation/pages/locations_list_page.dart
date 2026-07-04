import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/router/route_names.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/location_card.dart';
import '../widgets/location_search_bar.dart';

class LocationsListPage extends StatefulWidget {
  const LocationsListPage({super.key});

  @override
  State<LocationsListPage> createState() => _LocationsListPageState();
}

class _LocationsListPageState extends State<LocationsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(const LoadLocations());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddLocation() {
    context.push(RouteNames.addLocation);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Top Header Row: "Locations" title + '+' button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Locations',
                    style: AppTextStyles.h1.copyWith(
                      color: titleColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: IconButton(
                      onPressed: _navigateToAddLocation,
                      icon: Icon(
                        Icons.add,
                        color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search Bar
              LocationSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  context.read<LocationBloc>().add(SearchLocations(query));
                },
              ),
              const SizedBox(height: 20),
              // Locations List Content
              Expanded(
                child: BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    if (state is LocationLoading) {
                      return Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      );
                    }

                    if (state is LocationError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: isDark ? AppColors.errorDark : AppColors.errorLight),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: AppTextStyles.bodyMedium.copyWith(color: titleColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<LocationBloc>().add(const LoadLocations());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is LocationLoaded) {
                      final locations = state.filteredLocations;

                      if (locations.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<LocationBloc>().add(const LoadLocations());
                          },
                          color: primaryColor,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_off_outlined,
                                      size: 56,
                                      color: subtitleColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.searchQuery.isNotEmpty
                                          ? 'No locations match "${state.searchQuery}"'
                                          : 'No locations added yet',
                                      style: AppTextStyles.h4.copyWith(color: titleColor),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      state.searchQuery.isNotEmpty
                                          ? 'Try searching with a different keyword'
                                          : 'Tap the + button to add your first geofence location',
                                      style: AppTextStyles.bodySmall.copyWith(color: subtitleColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<LocationBloc>().add(const LoadLocations());
                        },
                        color: primaryColor,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: locations.length,
                          itemBuilder: (context, index) {
                            final loc = locations[index];
                            return LocationCard(
                              location: loc,
                              onTap: () {
                                context.push(
                                  RouteNames.editLocationPath(loc.id),
                                  extra: loc,
                                );
                              },
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _navigateToAddLocation,
          backgroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Icon(
            Icons.add,
            color: isDark ? AppColors.onPrimaryDark : AppColors.onPrimaryLight,
            size: 28,
          ),
        ),
      ),
    );
  }
}