import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/pet_image/data/datasources/pet_image_remote_datasource.dart';
import 'package:pixel_love/features/pet_image/data/repositories/pet_image_repository_impl.dart';
import 'package:pixel_love/features/pet_image/domain/repositories/pet_image_repository.dart';
import 'package:pixel_love/features/pet_image/domain/usecases/get_pet_images_usecase.dart';
import 'package:pixel_love/features/pet_image/domain/usecases/send_image_to_pet_usecase.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_album_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_notifier.dart';
import 'package:pixel_love/features/pet_image/presentation/notifiers/pet_capture_state.dart';

// ============================================
// Pet Image Feature Providers
// ============================================

/// Pet Image Remote DataSource provider
final petImageRemoteDataSourceProvider = Provider<PetImageRemoteDataSource>((
  ref,
) {
  final dioApi = ref.watch(dioApiProvider);
  return PetImageRemoteDataSourceImpl(dioApi);
});

/// Pet Image Repository provider
final petImageRepositoryProvider = Provider<PetImageRepository>((ref) {
  final remoteDataSource = ref.watch(petImageRemoteDataSourceProvider);
  return PetImageRepositoryImpl(remoteDataSource);
});

/// Get Pet Images UseCase provider
final getPetImagesUseCaseProvider = Provider<GetPetImagesUseCase>((ref) {
  final repository = ref.watch(petImageRepositoryProvider);
  return GetPetImagesUseCase(repository);
});

/// Send Image To Pet UseCase provider
final sendImageToPetUseCaseProvider = Provider<SendImageToPetUseCase>((ref) {
  final repository = ref.watch(petImageRepositoryProvider);
  return SendImageToPetUseCase(repository);
});

/// Pet Album Notifier provider (Riverpod v3)
final petAlbumNotifierProvider =
    NotifierProvider<PetAlbumNotifier, PetAlbumState>(PetAlbumNotifier.new);

/// Pet Capture Notifier provider (Riverpod v3)
final petCaptureNotifierProvider =
    NotifierProvider<PetCaptureNotifier, PetCaptureState>(
      PetCaptureNotifier.new,
    );

/// Temporary captured image state - dùng để hiển thị ảnh vừa chụp trong swipe screen
class TemporaryCapturedImage {
  final Uint8List bytes;
  final String? caption;
  final DateTime capturedAt;
  final int sensorRotation;
  final SensorPosition sensorPosition;

  TemporaryCapturedImage({
    required this.bytes,
    this.caption,
    required this.capturedAt,
    this.sensorRotation = 0,
    this.sensorPosition = SensorPosition.back,
  });
}

/// Notifier để quản lý temporary captured image
class TemporaryCapturedImageNotifier extends Notifier<TemporaryCapturedImage?> {
  @override
  TemporaryCapturedImage? build() => null;

  void setImage(TemporaryCapturedImage? image) {
    state = image;
  }

  void clear() {
    state = null;
  }
}

/// Provider để lưu temporary captured image (local file/bytes) cho swipe screen
final temporaryCapturedImageProvider =
    NotifierProvider<TemporaryCapturedImageNotifier, TemporaryCapturedImage?>(
      TemporaryCapturedImageNotifier.new,
    );
