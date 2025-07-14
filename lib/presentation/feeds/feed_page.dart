import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foody/core/constants/colors.dart';
import 'package:foody/data/models/local/bookmark_place_model.dart';
import 'package:foody/data/models/response/feeds/feed_response_model.dart';
import 'package:foody/data/repository/feed_repository.dart';
import 'package:foody/presentation/feeds/bloc/feed_bloc.dart';
import 'package:foody/presentation/feeds/widgets/location_search_page.dart';
import 'package:image_picker/image_picker.dart';

class FeedPage extends StatelessWidget {
  final FeedsResponseModel? feedToEdit;
    final BookmarkPlace? preselectedLocation;

  const FeedPage({super.key, this.feedToEdit, this.preselectedLocation});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedBloc(
        RepositoryProvider.of<FeedRepository>(context),
      )..add(
          InitializeFeed(
            feed: feedToEdit,
            location: preselectedLocation,
          ),
        ),
      child: AddPostView(feedToEdit: feedToEdit),
    );
  }
}

class AddPostView extends StatefulWidget {
  final FeedsResponseModel? feedToEdit;
  const AddPostView({super.key, this.feedToEdit});

  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final _titleController = TextEditingController();
  final _captionController = TextEditingController();

  bool get _isEditMode => widget.feedToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.feedToEdit!.title ?? '';
      _captionController.text = widget.feedToEdit!.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      context.read<FeedBloc>().add(ImageSelected(File(pickedFile.path)));
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  _isEditMode
                      ? 'Post updated successfully!'
                      : 'Post created successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          // Kembali dan kirim sinyal sukses untuk refresh
          Navigator.of(context).pop(true);
        }
        if (state.status == FormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            // Judul dinamis sesuai mode
            title: Text(_isEditMode ? 'Edit Post' : 'New Post'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed:
                  () => Navigator.of(context).pop(false), // Kirim sinyal gagal
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Widget untuk menampilkan gambar
                GestureDetector(
                  onTap: () => _showImagePicker(context),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildImageWidget(state),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: 'Name Place'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(
                    hintText: 'Add a caption...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.white,
                  ),
                  title: Text(
                    state.selectedLocation?.name ?? 'Add a location',
                    style: TextStyle(
                      color:
                          state.selectedLocation != null
                              ? AppColors.white
                              : AppColors.grey,
                    ),
                  ),
                  onTap: () async {
                    final result = await Navigator.push<BookmarkPlace>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationSearchPage(),
                      ),
                    );

                    if (result != null && mounted) {
                      context.read<FeedBloc>().add(LocationSelected(result));
                    }
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed:
                      state.status == FormStatus.submitting
                          ? null
                          : () {
                            context.read<FeedBloc>().add(
                              PostSubmitted(
                                title: _titleController.text,
                                description: _captionController.text,
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                  ),
                  child:
                      state.status == FormStatus.submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          // Teks tombol dinamis
                          : Text(_isEditMode ? 'Save Changes' : 'Share'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(FeedState state) {
    // 1. Prioritaskan gambar baru yang dipilih
    if (state.selectedImage != null) {
      return Image.file(state.selectedImage!, fit: BoxFit.cover);
    }
    // 2. Jika tidak ada gambar baru, tampilkan gambar lama (mode edit)
    if (_isEditMode && state.existingImageBytes != null) {
      return Image.memory(state.existingImageBytes!, fit: BoxFit.cover);
    }
    // 3. Tampilan default
    return const Center(
      child: Text('Tap to add image', style: TextStyle(color: AppColors.grey)),
    );
  }
}
