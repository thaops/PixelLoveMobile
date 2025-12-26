/// Constants for onboarding screen data
class OnboardingData {
  static const List<String> imagePaths = [
    'assets/images/img-couple1.png',
    'assets/images/img-couple2.png',
    'assets/images/img-couple3.png',
  ];

  static const List<String> titles = [
    'Kết nối tình yêu',
    'Trò chuyện thân mật',
    'Tạo kỷ niệm đẹp',
  ];

  static const List<String> subtitles = [
    'Tìm kiếm và kết nối với người bạn đời của bạn một cách dễ dàng và an toàn',
    'Trò chuyện riêng tư, chia sẻ khoảnh khắc đáng nhớ với người thương',
    'Lưu giữ những kỷ niệm đẹp, tạo album ảnh và nhật ký tình yêu của bạn',
  ];

  static const int totalPages = 3;
  static const Duration autoScrollDuration = Duration(seconds: 3);
  static const Duration pageAnimationDuration = Duration(milliseconds: 400);
}
