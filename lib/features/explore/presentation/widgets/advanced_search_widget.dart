import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

class AdvancedSearchWidget extends ConsumerStatefulWidget {
  final Function(Map<String, String?>) onSearch;
  final VoidCallback? onVoiceSearch;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearch,
    this.onVoiceSearch,
  });

  @override
  ConsumerState<AdvancedSearchWidget> createState() =>
      _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends ConsumerState<AdvancedSearchWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  bool _showFilters = false;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String? _selectedDuration;
  String _sortBy = 'recent';

  final List<String> _categories = [
    'Technology',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Fitness',
    'Cooking',
    'Education',
    'Art',
  ];

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _durations = [
    'Short (< 5 min)',
    'Medium (5-20 min)',
    'Long (> 20 min)',
  ];
  final Map<String, String> _sortOptions = {
    'recent': 'Most Recent',
    'popular': 'Most Popular',
    'views': 'Most Viewed',
  };

  @override
  void initState() {
    super.initState();

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void _performSearch() {
    final filters = <String, String?>{
      'query': _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      'category': _selectedCategory,
      'difficulty': _selectedDifficulty,
      'duration': _selectedDuration,
      'sortBy': _sortBy,
    };

    widget.onSearch(filters);
    HapticFeedback.lightImpact();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDifficulty = null;
      _selectedDuration = null;
      _sortBy = 'recent';
    });
    _performSearch();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Main search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search skills, creators, topics...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.onVoiceSearch != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.mic_rounded,
                                      color: colorScheme.primary,
                                    ),
                                    onPressed: widget.onVoiceSearch,
                                  ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch();
                                    },
                                  ),
                              ],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 0,
                            ),
                          ),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter toggle button
                      Container(
                        decoration: BoxDecoration(
                          color: _showFilters
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: AnimatedRotation(
                            turns: _filterAnimation.value * 0.5,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.tune_rounded,
                              color: _showFilters
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onPressed: _toggleFilters,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters section
                AnimatedBuilder(
                  animation: _filterAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _filterAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filters',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: _clearFilters,
                                    child: Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Category filter
                              _buildFilterSection(
                                'Category',
                                _categories,
                                _selectedCategory,
                                (value) =>
                                    setState(() => _selectedCategory = value),
                                colorScheme,
                              ),

                              const SizedBox(height: 16),

                              // Difficulty filter
                              _buildFilterSection(
                                'Difficulty',
                                _difficulties,
                                _selectedDifficulty,
                                (value) =>
                                    setState(() => _selectedDifficulty = value),
                                colorScheme,
                              ),

                              const SizedBox(height: 16),

                              // Duration filter
                              _buildFilterSection(
                                'Duration',
                                _durations,
                                _selectedDuration,
                                (value) =>
                                    setState(() => _selectedDuration = value),
                                colorScheme,
                              ),

                              const SizedBox(height: 16),

                              // Sort by
                              Text(
                                'Sort By',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _sortOptions.entries.map((entry) {
                                  final isSelected = _sortBy == entry.key;
                                  return FilterChip(
                                    label: Text(entry.value),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() => _sortBy = entry.key);
                                      _performSearch();
                                    },
                                    backgroundColor: colorScheme.surface,
                                    selectedColor: colorScheme.primary,
                                    checkmarkColor: colorScheme.onPrimary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 16),

                              // Apply button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _performSearch,
                                  icon: const Icon(Icons.search_rounded),
                                  label: const Text('Apply Filters'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // Clear option
            FilterChip(
              label: const Text('Any'),
              selected: selectedValue == null,
              onSelected: (selected) {
                if (selected) {
                  onChanged(null);
                  _performSearch();
                }
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.surfaceContainerHighest,
              checkmarkColor: colorScheme.onSurface,
              labelStyle: TextStyle(
                color: selectedValue == null
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withOpacity(0.7),
                fontWeight: selectedValue == null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            // Options
            ...options.map((option) {
              final isSelected = selectedValue == option;
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                  _performSearch();
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary,
                checkmarkColor: colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
}
