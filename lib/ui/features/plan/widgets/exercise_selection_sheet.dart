import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:capyfit/providers/app_provider.dart';
import 'package:capyfit/data/models/exercise.dart';
import 'package:capyfit/data/services/exercise_db_service.dart';
import 'package:capyfit/ui/common/theme/app_colors.dart';
import 'package:capyfit/ui/common/widgets/hand_drawn_widgets.dart';

class ExerciseSelectionSheet extends StatefulWidget {
  final Function(Exercise) onSelect;

  const ExerciseSelectionSheet({super.key, required this.onSelect});

  @override
  State<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends State<ExerciseSelectionSheet> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadExercises(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadExercises();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          _isLoading = true; // Show loading immediately
        });
        _loadExercises(refresh: true);
      }
    });
  }

  Future<void> _loadExercises({bool refresh = false}) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _exercises.clear();
      // Don't set isLoading here if we want to show existing data while typing?
      // But we are refreshing, so yes.
    }

    if (!_hasMore || (_isLoading && !refresh)) return;

    if (mounted) setState(() => _isLoading = true);

    try {
      // Load from DB
      final newExercises = await ExerciseDbService().search(
        _searchQuery,
        limit: _limit,
        offset: _offset,
      );

      // If refreshing, also check local exercises for first page
      if (refresh && _offset == 0) {
        final localExercises = context.read<AppProvider>().exercises;
        // Filter local exercises based on query
        final filteredLocal = localExercises.where((e) {
          final q = _searchQuery.toLowerCase();
          return e.name.toLowerCase().contains(q) ||
              e.targetMuscles.any((m) => m.toLowerCase().contains(q));
        }).toList();

        // Combine: Local first, then DB (deduplicated)
        final existingNames = filteredLocal.map((e) => e.name).toSet();
        final dedupedNew = newExercises
            .where((e) => !existingNames.contains(e.name))
            .toList();

        if (mounted) {
          setState(() {
            _exercises = [...filteredLocal, ...dedupedNew];
            _offset += newExercises.length;
            _hasMore = newExercises.length >= _limit;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Simple dedupe check against current list
            final currentNames = _exercises.map((e) => e.name).toSet();
            final dedupedNew = newExercises
                .where((e) => !currentNames.contains(e.name))
                .toList();

            _exercises.addAll(dedupedNew);
            _offset += newExercises.length;
            _hasMore = newExercises.length >= _limit;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '项目库',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextMainColor(context),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(LucideIcons.xCircle, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        HandDrawnTextField(
          controller: _searchController,
          hintText: '搜索动作或部位...',
          onChanged: _onSearchChanged,
          prefixIcon: const Icon(LucideIcons.search, size: 20),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: _exercises.isEmpty && !_isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '未找到相关动作',
                      style: TextStyle(
                        color: AppColors.getTextMutedColor(context),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _exercises.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _exercises.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final ex = _exercises[index];
                    final calPerSet = context
                        .read<AppProvider>()
                        .calculateExerciseCalories(ex);

                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: HandDrawnContainer(
                        padding: const EdgeInsets.all(4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              ex.image ?? '',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 44,
                                  height: 44,
                                  color: AppColors.accentMint.withOpacity(0.2),
                                  child: const Icon(
                                    LucideIcons.dumbbell,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            ex.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '$calPerSet kcal/组 · ${ex.sets ?? 3}组',
                            style: TextStyle(
                              color: AppColors.getTextMutedColor(context),
                              fontSize: 13,
                            ),
                          ),
                          onTap: () => widget.onSelect(ex),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
