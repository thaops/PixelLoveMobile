class CreateNoteRequest {
  final String content;

  CreateNoteRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

