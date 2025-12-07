import 'package:get/get.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;
  final StorageService _storageService;

  SocketService(this._storageService);

  final _isConnected = false.obs;
  final _messages = <Map<String, dynamic>>[].obs;
  final _petData = Rxn<Map<String, dynamic>>();
  final _roomData = Rxn<Map<String, dynamic>>();

  bool get isConnected => _isConnected.value;
  List<Map<String, dynamic>> get messages => _messages;
  Map<String, dynamic>? get petData => _petData.value;
  Map<String, dynamic>? get roomData => _roomData.value;

  void connect(String coupleRoomId) {
    if (_socket != null && _socket!.connected) {
      disconnect(); // Disconnect old connection first
    }

    final token = _storageService.getToken();
    if (token == null) {
      print('❌ No token found, cannot connect to socket');
      return;
    }

    print('🔌 Connecting to socket with coupleRoomId: $coupleRoomId');

    // Connect with query parameters: token and coupleRoomId
    _socket = IO.io(
      Env.apiBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({
            'token': token,
            'coupleRoomId': coupleRoomId,
          })
          .build(),
    );

    _socket!.connect();

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _isConnected.value = true;
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected.value = false;
    });

    _socket!.on('connect_error', (error) {
      print('❌ Socket connection error: $error');
      _isConnected.value = false;
    });

    _socket!.on('error', (error) {
      print('❌ Socket error: $error');
    });

    // Backend events to listen
    _socket!.on('roomUpdated', (data) {
      print('🔄 Room updated: $data');
      _roomData.value = data as Map<String, dynamic>?;
      Get.snackbar(
        'Room Updated',
        'Love score or room data changed!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    });

    _socket!.on('petUpdated', (data) {
      print('🐾 Pet updated: $data');
      _petData.value = data as Map<String, dynamic>?;
    });

    _socket!.on('messageReceived', (data) {
      print('💬 Message received: $data');
      _messages.add(data as Map<String, dynamic>);
    });
  }

  void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected.value = false;
      _messages.clear();
      _petData.value = null;
      _roomData.value = null;
    }
  }

  void sendMessage(String message) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('sendMessage', {'message': message});
      print('💬 Message sent: $message');
    } else {
      print('❌ Socket not connected, cannot send message');
      Get.snackbar(
        'Connection Error',
        'Not connected to couple space',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}

