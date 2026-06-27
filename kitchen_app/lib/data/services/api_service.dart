import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../models/auth.dart';
import '../models/models.dart';
import 'mock_data.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

typedef UnauthorizedHandler = void Function();

/// Typed client for `/auth/**` and `/kitchen/**`, mock-first so the app runs
/// with no backend when [AppConstants.useMock] is true.
class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.deleteAll();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._internal();

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UnauthorizedHandler? onUnauthorized;

  bool get _mock => AppConstants.useMock;
  bool get _mockAuth => AppConstants.mockAuth;

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<void> clearToken() => _storage.deleteAll();

  Future<T> _guarded<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? 'Network error';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server. Check your connection.';
    }
    return ApiException(message, statusCode: code);
  }

  Future<void> _mockDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 450));

  // ---------------------------------------------------------------- Auth
  Future<PhoneInitiateResult> initiatePhone(String phone) async {
    if (_mockAuth) {
      await _mockDelay();
      return const PhoneInitiateResult(exists: true, otpSent: true, devMode: true);
    }
    return _guarded(() async {
      final res = await _dio.post('/auth/phone/initiate', data: {'phone': phone});
      return PhoneInitiateResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<PhoneVerifyResult> verifyPhone(String phone, String otp) async {
    if (_mockAuth) {
      await _mockDelay();
      return const PhoneVerifyResult(
        newUser: false,
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
      );
    }
    return _guarded(() async {
      final res =
          await _dio.post('/auth/phone/verify', data: {'phone': phone, 'otp': otp});
      return PhoneVerifyResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ------------------------------------------------------------- Kitchens
  Future<List<Kitchen>> listKitchens({String? orgId}) async {
    if (_mock) {
      await _mockDelay();
      return MockData.kitchens();
    }
    return _guarded(() async {
      final res = await _dio.get('/kitchen/kitchens',
          queryParameters: {if (orgId != null) 'orgId': orgId});
      return (res.data as List<dynamic>)
          .map((e) => Kitchen.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Kitchen> createKitchen({
    required String name,
    String? address,
    String? city,
    String? orgId,
  }) async {
    if (_mock) {
      await _mockDelay();
      return Kitchen(
        id: 'k-${DateTime.now().millisecondsSinceEpoch}',
        orgId: orgId ?? MockData.orgId,
        name: name,
        address: address,
        city: city,
      );
    }
    return _guarded(() async {
      final res = await _dio.post('/kitchen/kitchens', data: {
        'name': name,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (orgId != null) 'orgId': orgId,
      });
      return Kitchen.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ----------------------------------------------------------------- Menu
  Future<List<MenuItem>> getMenu(String kitchenId) async {
    if (_mock) {
      await _mockDelay();
      return MockData.menu(kitchenId);
    }
    return _guarded(() async {
      final res = await _dio.get('/kitchen/kitchens/$kitchenId/menu');
      return (res.data as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<MenuItem> createMenuItem(
    String kitchenId, {
    required String name,
    String? description,
    required MealCategory category,
    required int priceCents,
    required bool veg,
  }) async {
    if (_mock) {
      await _mockDelay();
      return MenuItem(
        id: 'm-${DateTime.now().millisecondsSinceEpoch}',
        kitchenId: kitchenId,
        name: name,
        description: description,
        category: category,
        priceCents: priceCents,
        veg: veg,
      );
    }
    return _guarded(() async {
      final res = await _dio.post('/kitchen/kitchens/$kitchenId/menu', data: {
        'name': name,
        if (description != null) 'description': description,
        'category': category.api,
        'priceCents': priceCents,
        'veg': veg,
        'available': true,
      });
      return MenuItem.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<MenuItem> updateMenuItem(
    MenuItem item, {
    bool? available,
    int? priceCents,
  }) async {
    if (_mock) {
      await _mockDelay();
      return item.copyWith(available: available, priceCents: priceCents);
    }
    return _guarded(() async {
      final res = await _dio.patch('/kitchen/menu/${item.id}', data: {
        if (available != null) 'available': available,
        if (priceCents != null) 'priceCents': priceCents,
      });
      return MenuItem.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // --------------------------------------------------------------- Orders
  Future<List<FoodOrder>> getOrders(String kitchenId,
      {bool activeOnly = false}) async {
    if (_mock) {
      await _mockDelay();
      return MockData.orders(kitchenId);
    }
    return _guarded(() async {
      final res = await _dio.get('/kitchen/kitchens/$kitchenId/orders',
          queryParameters: {'activeOnly': activeOnly});
      return (res.data as List<dynamic>)
          .map((e) => FoodOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<FoodOrder> updateOrderStatus(FoodOrder order, OrderStatus status) async {
    if (_mock) {
      await _mockDelay();
      order.status = status;
      return order;
    }
    return _guarded(() async {
      final res = await _dio
          .patch('/kitchen/orders/${order.id}/status', data: {'status': status.api});
      return FoodOrder.fromJson(res.data as Map<String, dynamic>);
    });
  }
}
