import 'package:intl/intl.dart';

/// Các hàm format thời gian phục vụ màn album
class PetAlbumFormatters {
  const PetAlbumFormatters._();

  /// Format dạng tương đối (ví dụ: Hôm qua, 2 ngày trước, 12/12/2024)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Vừa xong';
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Header mốc thời gian theo ngày
  static String header(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hôm nay';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Hôm qua';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Giờ:phút
  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  /// Ngày ngắn gọn cho bubble
  static String shortDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return '';
    if (dateOnly == today.subtract(const Duration(days: 1))) return '';
    return DateFormat('dd/MM').format(date);
  }
}

