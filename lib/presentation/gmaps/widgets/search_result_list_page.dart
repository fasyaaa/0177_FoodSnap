// presentation/gmaps/widgets/search_result_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/constants.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';

class SearchResultListPage extends StatelessWidget {
  final List<Suggestion> results;
  const SearchResultListPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white24, height: 1),
        itemBuilder: (context, index) {
          final suggestion = results[index];
          return ListTile(
            leading: const Icon(Icons.location_on_outlined, color: AppColors.grey),
            title: Text(suggestion.description, style: const TextStyle(color: AppColors.white)),
            onTap: () {
              context.read<GmapsBloc>().add(PlaceSelected(suggestion));
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}