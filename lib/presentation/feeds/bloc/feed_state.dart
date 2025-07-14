part of 'feed_bloc.dart';

enum FormStatus { initial, submitting, success, failure }

class FeedState extends Equatable {
  final File? selectedImage;
  final BookmarkPlace? selectedLocation;
  final FormStatus status;
  final String? errorMessage;

  // Ditambahkan: Properti untuk menampung data feed yang diedit
  final FeedsResponseModel? feedToEdit;
  final Uint8List? existingImageBytes;

  const FeedState({
    this.selectedImage,
    this.selectedLocation,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.feedToEdit,
    this.existingImageBytes,
  });

  FeedState copyWith({
    File? selectedImage,
    BookmarkPlace? selectedLocation,
    FormStatus? status,
    String? errorMessage,
    FeedsResponseModel? feedToEdit,
    Uint8List? existingImageBytes,
    bool clearLocation = false,
  }) {
    return FeedState(
      selectedImage: selectedImage ?? this.selectedImage,
      selectedLocation:
          clearLocation ? null : selectedLocation ?? this.selectedLocation,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      feedToEdit: feedToEdit ?? this.feedToEdit,
      existingImageBytes: existingImageBytes ?? this.existingImageBytes,
    );
  }

  @override
  List<Object?> get props => [
    selectedImage,
    selectedLocation,
    status,
    errorMessage,
    feedToEdit,
    existingImageBytes,
  ];
}
