import 'package:get/get.dart';
import 'package:pixel_love/core/env/env.dart';
import 'package:pixel_love/core/services/storage_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends GetxService {
  IO.Socket? _socket;
  IO.Socket? _eventsSocket; // Socket cho events namespace
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

  // Callbacks cho couple events
  void Function(Map<String, dynamic>)? onCouplePaired;
  void Function(Map<String, dynamic>)? onCoupleRoomUpdated;
  void Function(Map<String, dynamic>)? onCoupleBrokenUp;
  void Function(Map<String, dynamic>)? onServerConnected;

  // Connect socket với namespace /events để listen couple events
  Future<void> connectEvents() async {
    if (_eventsSocket != null && _eventsSocket!.connected) {
      print('✅ Events socket already connected');
      return;
    }

    final token = _storageService.getToken();
    if (token == null) {
      print('❌ No token found, cannot connect to events socket');
      return;
    }

    try {
      // Extract base URL without /api suffix for socket
      final baseUrl = Env.apiBaseUrl.replaceAll('/api', '');
      final socketUrl = '$baseUrl/events';

      print('🔌 Connecting to events socket: $socketUrl');

      _eventsSocket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _setupEventsListeners();
    } catch (e) {
      print('❌ Error connecting events socket: $e');
    }
  }

  void _setupEventsListeners() {
    _eventsSocket!.onConnect((_) {
      print('✅ Events socket connected: ${_eventsSocket!.id}');
    });

    _eventsSocket!.onDisconnect((_) {
      print('❌ Events socket disconnected');
    });

    _eventsSocket!.onConnectError((error) {
      print('❌ Events socket connection error: $error');
    });

    _eventsSocket!.onError((error) {
      print('❌ Events socket error: $error');
    });

    // Server connected event
    _eventsSocket!.on('connected', (data) {
      print('📱 Connected event: $data');
      onServerConnected?.call(data as Map<String, dynamic>);
    });

    // Couple paired event (khi User B nhập code thành công)
    _eventsSocket!.on('couplePaired', (data) {
      print('💑 Couple paired event: $data');
      onCouplePaired?.call(data as Map<String, dynamic>);
    });

    // Couple room updated event
    _eventsSocket!.on('coupleRoomUpdated', (data) {
      print('🏠 Couple room updated: $data');
      onCoupleRoomUpdated?.call(data as Map<String, dynamic>);
    });

    // Couple broken up event
    _eventsSocket!.on('coupleBrokenUp', (data) {
      print('💔 Couple broken up: $data');
      onCoupleBrokenUp?.call(data as Map<String, dynamic>);
    });
  }

  // Connect socket với coupleRoomId (cho couple space)
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
          .setQuery({'token': token, 'coupleRoomId': coupleRoomId})
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

  void disconnectEvents() {
    if (_eventsSocket != null) {
      print('🔌 Disconnecting events socket...');
      _eventsSocket!.disconnect();
      _eventsSocket!.dispose();
      _eventsSocket = null;
      // Clear callbacks
      onCouplePaired = null;
      onCoupleRoomUpdated = null;
      onCoupleBrokenUp = null;
      onServerConnected = null;
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
    disconnectEvents();
    super.onClose();
  }
}
