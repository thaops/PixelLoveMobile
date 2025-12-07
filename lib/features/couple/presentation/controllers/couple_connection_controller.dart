import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/core/services/socket_service.dart';
import 'package:pixel_love/features/couple/domain/entities/couple_code.dart';
import 'package:pixel_love/features/couple/domain/entities/partner_preview.dart';
import 'package:pixel_love/features/couple/domain/usecases/create_code_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/pair_couple_usecase.dart';
import 'package:pixel_love/features/couple/domain/usecases/preview_code_usecase.dart';
import 'package:pixel_love/routes/app_routes.dart';

class CoupleConnectionController extends GetxController {
  final CreateCodeUseCase _createCodeUseCase;
  final PreviewCodeUseCase _previewCodeUseCase;
  final PairCoupleUseCase _pairCoupleUseCase;
  final SocketService _socketService;

  CoupleConnectionController(
    this._createCodeUseCase,
    this._previewCodeUseCase,
    this._pairCoupleUseCase,
    this._socketService,
  );

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _coupleCode = Rxn<CoupleCode>();
  final _inputCode = ''.obs;
  final _partnerPreview = Rxn<PartnerPreview>();
  final _canConnect = false.obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  CoupleCode? get coupleCode => _coupleCode.value;
  String get inputCode => _inputCode.value;
  PartnerPreview? get partnerPreview => _partnerPreview.value;
  bool get canConnect => _canConnect.value;

  @override
  void onInit() {
    super.onInit();
    _createCode();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    // Listen couplePaired event (cả User A và User B đều nhận)
    _socketService.onCouplePaired = (data) {
      print('💑 Couple paired event received: $data');
      _handleCouplePaired(data);
    };

    // Listen coupleRoomUpdated event
    _socketService.onCoupleRoomUpdated = (data) {
      print('🏠 Couple room updated: $data');
      // Có thể update UI nếu cần
    };

    // Listen coupleBrokenUp event
    _socketService.onCoupleBrokenUp = (data) {
      print('💔 Couple broken up: $data');
      Get.snackbar(
        'Thông báo',
        'Kết nối đã bị hủy',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Navigate về couple connection screen
      Get.offAllNamed(AppRoutes.coupleConnection);
    };
  }

  void _handleCouplePaired(Map<String, dynamic> data) {
    final partner = data['partner'] as Map<String, dynamic>?;

    if (partner != null) {
      final partnerName = partner['nickname'] ?? partner['displayName'] ?? 'Đối phương';

      // Hiển thị notification
      Get.snackbar(
        'Kết nối thành công! 💑',
        'Bạn đã kết nối với $partnerName',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
      );

      // Navigate đến home screen sau 1 giây
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAllNamed(AppRoutes.home);
      });
    }
  }

  void setInputCode(String value) {
    _inputCode.value = value;
    _canConnect.value = value.trim().length >= 6;
    if (value.trim().length >= 6) {
      _previewCode(value.trim());
    } else {
      _partnerPreview.value = null;
    }
  }

  Future<void> _createCode() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _createCodeUseCase.call();

      result.when(
        success: (code) {
          _coupleCode.value = code;
          print('✅ Code created: ${code.code}');
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar('Lỗi', error.message, snackPosition: SnackPosition.BOTTOM);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Lỗi tạo mã: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _previewCode(String code) async {
    try {
      final result = await _previewCodeUseCase.call(code);

      result.when(
        success: (preview) {
          _partnerPreview.value = preview;
          _canConnect.value = preview.canPair;
          print('✅ Preview: codeValid=${preview.codeValid}, canPair=${preview.canPair}');
        },
        error: (error) {
          _partnerPreview.value = null;
          _canConnect.value = false;
          print('❌ Preview error: ${error.message}');
        },
      );
    } catch (e) {
      print('❌ Preview exception: $e');
    }
  }

  Future<void> copyCode() async {
    if (_coupleCode.value == null) return;
    // TODO: Implement clipboard copy
    Get.snackbar('Đã copy', 'Mã ghép đã được sao chép', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> shareCode() async {
    if (_coupleCode.value == null) return;
    // TODO: Implement share functionality
    Get.snackbar('Chia sẻ', 'Chức năng chia sẻ đang phát triển', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> connect() async {
    if (!_canConnect.value || _inputCode.value.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập mã hợp lệ', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _pairCoupleUseCase.call(_inputCode.value.trim());

      result.when(
        success: (response) {
          print('✅ Pair success: ${response.message}');
          
          // ⚠️ LƯU Ý: Socket event 'couplePaired' sẽ được emit tự động từ backend
          // Không cần navigate ở đây, vì socket listener sẽ xử lý trong _handleCouplePaired()
          // Nếu socket không hoạt động, có thể navigate fallback sau 2 giây
          Future.delayed(const Duration(seconds: 2), () {
            if (Get.currentRoute == AppRoutes.coupleConnection) {
              // Nếu vẫn ở màn hình này, có thể socket chưa nhận event
              // Navigate fallback
              Get.offAllNamed(AppRoutes.home);
            }
          });
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar('Lỗi', error.message, snackPosition: SnackPosition.BOTTOM);
        },
      );
    } catch (e) {
      _errorMessage.value = 'Lỗi kết nối: $e';
      Get.snackbar('Lỗi', _errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isLoading.value = false;
    }
  }

  void scanQR() {
    // TODO: Implement QR scanner
    Get.snackbar('QR Scanner', 'Chức năng quét QR đang phát triển', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onClose() {
    // Clear socket listeners khi controller bị dispose
    _socketService.onCouplePaired = null;
    _socketService.onCoupleRoomUpdated = null;
    _socketService.onCoupleBrokenUp = null;
    super.onClose();
  }
}

