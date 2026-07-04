import 'package:field_tracker/core/constants/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/core/widgets/error_view.dart';
import 'package:field_tracker/core/widgets/loading_indicator.dart';
import 'package:field_tracker/core/widgets/offline_banner.dart';

import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/todo_filter_tabs.dart';
import '../widgets/todo_item_tile.dart';
import '../widgets/todo_progress_card.dart';

/// Screen 07: My tasks — Main Todo list page.
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const LoadTodosEvent());
  }

  String _formatHeaderDate() {
    final now = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: BlocConsumer<TodoBloc, TodoState>(
          listener: (context, state) {
            if (state is TodoErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: isDark ? AppColors.errorDark : AppColors.errorLight,
                ),
              );
            }
          },
          builder: (context, state) {
            final bloc = context.read<TodoBloc>();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header ("My tasks" + Date)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My tasks',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatHeaderDate(),
                            style: AppTextStyles.subtitle.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      if (state is TodoLoadedState) ...[
                        IconButton(
                          icon: state.isSyncing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                  ),
                                )
                              : Image.asset(
                                  AppIcon.syncInactive,
                                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                  width: 24,
                                  height: 24,
                                ),
                          onPressed: state.isSyncing
                              ? null
                              : () => bloc.add(const SyncPendingTodosEvent()),
                          tooltip: 'Sync pending changes',
                        ),
                      ],
                    ],
                  ),
                ),

                // Main Content Body
                Expanded(
                  child: _buildBody(context, state, bloc),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodoState state, TodoBloc bloc) {
    if (state is TodoLoadingState || state is TodoInitialState) {
      return const LoadingIndicator();
    }

    if (state is TodoErrorState) {
      return ErrorView(
        message: state.message,
        onRetry: () => bloc.add(const LoadTodosEvent(forceRefresh: true)),
      );
    }

    if (state is TodoLoadedState) {
      return RefreshIndicator(
        onRefresh: () async {
          bloc.add(const LoadTodosEvent(forceRefresh: true));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline Status Banner (when disconnected)
              if (state.isOffline) ...[
                const OfflineBanner(
                  title: "You're offline",
                  message: "Changes are saved locally and synced when reconnected.",
                ),
                const SizedBox(height: 16),
              ],

              // Today's Progress Card
              TodoProgressCard(
                done: state.doneCount,
                total: state.totalCount,
              ),

              const SizedBox(height: 20),

              // Filter Chips ("All", "Pending", "Completed")
              TodoFilterTabs(
                current: state.filter,
                onChanged: (newFilter) {
                  bloc.add(FilterChangedEvent(newFilter));
                },
              ),

              const SizedBox(height: 16),

              // Tasks List
              if (state.visibleTodos.isEmpty)
                _buildEmptyState(context, state.filter)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.visibleTodos.length,
                  itemBuilder: (context, index) {
                    final todo = state.visibleTodos[index];
                    return TodoItemTile(
                      todo: todo,
                      onChanged: (newValue) {
                        bloc.add(ToggleTodoEvent(
                          todoId: todo.id,
                          newValue: newValue,
                        ));
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context, TodoFilter filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    String message;
    switch (filter) {
      case TodoFilter.pending:
        message = 'No pending tasks left!';
        break;
      case TodoFilter.completed:
        message = 'No completed tasks yet.';
        break;
      case TodoFilter.all:
        message = 'No tasks available.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 48,
              color: textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.cardSubtitle.copyWith(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}