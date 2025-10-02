import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/profile/providers/learning_stats_providers.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  final String userId;
  
  const InterestsScreen({super.key, required this.userId});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  final List<String> _allCategories = [
    'Design', 'Development', 'Marketing', 'Business',
    'Photography', 'Music', 'Cooking', 'Fitness',
    'Language', 'Science', 'Math', 'Art',
    'Writing', 'Finance', 'Technology', 'Health',
  ];
  
  late List<String> _selectedInterests;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _selectedInterests = [];
  }
  
  @override
  Widget build(BuildContext context) {
    final interestsAsync = ref.watch(userInterestsProvider(widget.userId));
    final notifier = ref.watch(interestsNotifierProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Interests'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                setState(() {
                  _isEditing = false;
                });
                
                await notifier.updateInterests(widget.userId, _selectedInterests);
              },
            ),
        ],
      ),
      body: interestsAsync.when(
        data: (interests) {
          if (!_isEditing && _selectedInterests.isEmpty) {
            _selectedInterests = List.from(interests);
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _isEditing
                      ? 'Select your interests to get personalized recommendations'
                      : 'Your interests help us recommend relevant content',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: _isEditing
                    ? _buildEditableInterests()
                    : _buildInterestsList(interests),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
  
  Widget _buildInterestsList(List<String> interests) {
    if (interests.isEmpty) {
      return const Center(
        child: Text('No interests selected yet'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: interests.map((interest) {
          return Chip(
            label: Text(interest),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildEditableInterests() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _allCategories.map((category) {
              final isSelected = _selectedInterests.contains(category);
              
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(category);
                    } else {
                      _selectedInterests.remove(category);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 