import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_bloc.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_event.dart';
import 'package:foody/presentation/gmaps/bloc/gmaps_state.dart';

class LocationSearchPage extends StatelessWidget {
  const LocationSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GmapsBloc()..add(InitializeMap()),
      child: const _LocationSearchView(),
    );
  }
}

class _LocationSearchView extends StatefulWidget {
  const _LocationSearchView();

  @override
  State<_LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends State<_LocationSearchView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        context.read<GmapsBloc>().add(SearchSubmitted(_searchController.text));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            size: 24,
            color: AppColors.primary,
          ),
          onPressed: () {},
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: AppColors.grey),
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary, fontSize: 16),
            ),
          ),
        ],
      ),
      body: BlocBuilder<GmapsBloc, GmapsState>(
        builder: (context, state) {
          if (state.status == GmapsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GmapsStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load locations',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return ListView.separated(
            itemCount: state.searchResults?.length ?? 0,
            separatorBuilder:
                (context, index) =>
                    const Divider(color: Colors.white24, height: 1, indent: 16),
            itemBuilder: (context, index) {
              final suggestion = state.searchResults![index];
              final parts = suggestion.description.split(',');
              final title = parts.first;
              final address = parts.skip(1).join(',').trim();

              return ListTile(
                title: Text(
                  title,
                  style: const TextStyle(color: AppColors.white),
                ),
                subtitle: Text(
                  '<0.1km ⋅ $address',
                  style: const TextStyle(color: AppColors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  final place = BookmarkPlace(
                    name: title,
                    address: suggestion.description,
                    latitude: suggestion.position.latitude,
                    longitude: suggestion.position.longitude,
                  );
                  Navigator.of(context).pop(place);
                },
              );
            },
          );
        },
      ),
    );
  }
}
