import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';

/// Create Note State
class CreateNoteState {
  final bool isLoading;
  final String? errorMessage;

  const CreateNoteState({
    this.isLoading = false,
    this.errorMessage,
  });

  CreateNoteState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreateNoteState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Create Note Notifier
class CreateNoteNotifier extends Notifier<CreateNoteState> {
  @override
  CreateNoteState build() {
    return const CreateNoteState();
  }

  Future<bool> createNote(String content) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập nội dung');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final createNoteUseCase = ref.read(createNoteUseCaseProvider);
      final result = await createNoteUseCase.call(content.trim());

      return result.when(
        success: (_) {
          state = state.copyWith(isLoading: false);
          return true;
        },
        error: (error) {
          state = state.copyWith(
            errorMessage: error.message,
            isLoading: false,
          );
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Unexpected error: $e',
        isLoading: false,
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

