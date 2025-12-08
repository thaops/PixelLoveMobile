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
    _socketService.onCouplePaired = (data) {
      _handleCouplePaired(data);
    };

    _socketService.onCoupleRoomUpdated = (data) {
      // Có thể update UI nếu cần
    };

    _socketService.onCoupleBrokenUp = (data) {
      Get.offAllNamed(AppRoutes.coupleConnection);
    };
  }

  void _handleCouplePaired(Map<String, dynamic> data) {
    final partner = data['partner'] as Map<String, dynamic>?;

    if (partner != null) {
    
        Get.offAllNamed(AppRoutes.home);
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
        },
        error: (error) {
          _errorMessage.value = error.message;
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
        },
        error: (error) {
          _partnerPreview.value = null;
          _canConnect.value = false;
        },
      );
    } catch (e) {
        print('❌ Preview exception: $e');
    }
  }

  Future<void> copyCode() async {
    if (_coupleCode.value == null) return;

  }

  Future<void> shareCode() async {
    if (_coupleCode.value == null) return;
   
  }

  Future<void> connect() async {
    if (!_canConnect.value || _inputCode.value.trim().isEmpty) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _pairCoupleUseCase.call(_inputCode.value.trim());

      result.when(
        success: (response) {
   
          Future.delayed(const Duration(seconds: 2), () {
            if (Get.currentRoute == AppRoutes.coupleConnection) {
              Get.offAllNamed(AppRoutes.home);
            }
          });
        },
        error: (error) {
          _errorMessage.value = error.message;
        },
      );
    } catch (e) {
      _errorMessage.value = 'Lỗi kết nối: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void scanQR() {

  }

  @override
  void onClose() {
    _socketService.onCouplePaired = null;
    _socketService.onCoupleRoomUpdated = null;
    _socketService.onCoupleBrokenUp = null;
    super.onClose();
  }
}

