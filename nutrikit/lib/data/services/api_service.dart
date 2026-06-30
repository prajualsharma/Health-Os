import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../models/auth.dart';
import '../models/dashboard.dart';
import '../models/dish.dart';
import '../models/gym.dart';
import '../models/meal_plan.dart';
import '../models/meal_system.dart';
import '../models/order.dart';
import '../models/progress.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import 'mock_data.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Called by the API service on 401 so navigation can react globally.
typedef UnauthorizedHandler = void Function();

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

  /// Auth can hit the live backend independently of the content endpoints.
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
      // Retry once on timeout / connection errors.
      if (_isTransient(e)) {
        try {
          return await call();
        } on DioException catch (e2) {
          throw _toApiException(e2);
        }
      }
      throw _toApiException(e);
    }
  }

  bool _isTransient(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError;

  ApiException _toApiException(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    String message = e.message ?? 'Network error';
    if (data is Map && data['message'] != null) {
      message = data['message'].toString();
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Cannot reach the server. Check your connection.';
    } else if (_isTransient(e)) {
      message = 'Request timed out. Please try again.';
    }
    return ApiException(message, statusCode: code);
  }

  Future<void> _mockDelay() =>
      Future<void>.delayed(const Duration(milliseconds: 600));

  // ---- Phone-first auth ----
  Future<PhoneInitiateResult> initiatePhone(String phone) async {
    if (_mockAuth) {
      await _mockDelay();
      return const PhoneInitiateResult(
          exists: false,
          otpSent: true,
          devMode: true,
          otpDelivered: false);
    }
    return _guarded(() async {
      final res =
          await _dio.post('/auth/phone/initiate', data: {'phone': phone});
      return PhoneInitiateResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<PhoneVerifyResult> verifyPhone(String phone, String otp) async {
    if (_mockAuth) {
      await _mockDelay();
      // In mock mode treat every verification as a new-user signup.
      return const PhoneVerifyResult(
          newUser: true, registrationToken: 'mock-registration-token');
    }
    return _guarded(() async {
      final res = await _dio
          .post('/auth/phone/verify', data: {'phone': phone, 'otp': otp});
      return PhoneVerifyResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<RegisterResult> registerPhone(
      OnboardingData data, String registrationToken) async {
    if (_mockAuth) {
      await _mockDelay();
      final m = MockData.onboardingResult();
      return RegisterResult(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        userId: 'mock-user',
        targets: m,
      );
    }
    return _guarded(() async {
      final res = await _dio.post('/auth/register-phone',
          data: data.toRegisterJson(registrationToken));
      return RegisterResult.fromJson(
        res.data as Map<String, dynamic>,
        targetWeight: data.targetWeight,
      );
    });
  }

  // ---- Dashboard / Plan ----
  Future<DashboardData> getDashboard() async {
    if (_mock) {
      await _mockDelay();
      var data = MockData.dashboard();
      if (!_mockAuth) {
        final profile = await getProfile();
        data = DashboardData(
          userName: profile.name,
          initials: profile.initials,
          calorieTarget: profile.calorieTarget,
          caloriesConsumed: data.caloriesConsumed,
          proteinConsumed: data.proteinConsumed,
          proteinTarget: profile.proteinTarget,
          carbsConsumed: data.carbsConsumed,
          carbTarget: profile.carbTarget,
          fatConsumed: data.fatConsumed,
          fatTarget: profile.fatTarget,
          quickStats: data.quickStats,
          meals: data.meals,
        );
      }
      return data;
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/dashboard');
      return DashboardData.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<MealPlanData> getMealPlan(DateTime date) async {
    if (_mock) {
      await _mockDelay();
      return MockData.mealPlan(date);
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/meal-plan',
          queryParameters: {'date': date.toIso8601String()});
      return MealPlanData.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<List<Dish>> getKitchenMenu({bool addOnsOnly = false}) async {
    if (_mock) {
      await _mockDelay();
      return MockData.kitchenMenuFiltered(addOnsOnly: addOnsOnly);
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/kitchen/menu',
          queryParameters: {if (addOnsOnly) 'addOnsOnly': true});
      return (res.data as List<dynamic>)
          .map((e) => Dish.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<MealSystemPlan>> getMealSystemPlans() async {
    if (_mock) {
      await _mockDelay();
      return MockData.mealSystemPlans();
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/meal-systems');
      return (res.data as List<dynamic>)
          .map((e) => MealSystemPlan(
                id: e['id'] as String,
                name: e['name'] as String,
                tagline: e['tagline'] as String,
                pricePerMonth: (e['pricePerMonth'] as num).toInt(),
                systemType: MealSystemTypeX.fromKey(e['systemType'] as String?),
                slots: (e['slots'] as List<dynamic>).cast<String>(),
                features: (e['features'] as List<dynamic>).cast<String>(),
              ))
          .toList();
    });
  }

  Future<Map<String, List<Dish>>> getTomorrowOptions({
    required DateTime date,
    required List<String> slots,
  }) async {
    if (_mock) {
      await _mockDelay();
      return MockData.tomorrowOptions(date: date, slots: slots);
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/meal-plan/tomorrow', queryParameters: {
        'date': date.toIso8601String(),
        'slots': slots.join(','),
      });
      final map = res.data as Map<String, dynamic>;
      return map.map((slot, list) => MapEntry(
            slot,
            (list as List<dynamic>)
                .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                .toList(),
          ));
    });
  }

  Future<List<Recipe>> getRecipesForTarget({
    required int calorieTarget,
    required int proteinTarget,
  }) async {
    if (_mock) {
      await _mockDelay();
      return MockData.recipesForTarget(
        calorieTarget: calorieTarget,
        proteinTarget: proteinTarget,
      );
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/recipes', queryParameters: {
        'calories': calorieTarget,
        'protein': proteinTarget,
      });
      return (res.data as List<dynamic>)
          .map((e) => Recipe(
                id: e['id'] as String,
                name: e['name'] as String,
                slot: e['slot'] as String,
                emoji: e['emoji'] as String? ?? '🍽️',
                calories: (e['calories'] as num).toInt(),
                protein: (e['protein'] as num).toInt(),
                carbs: (e['carbs'] as num).toInt(),
                fat: (e['fat'] as num).toInt(),
                fitsGoal: e['fitsGoal'] as bool? ?? true,
                ingredients: (e['ingredients'] as List<dynamic>)
                    .map((i) => RecipeIngredient(
                          name: i['name'] as String,
                          grams: (i['grams'] as num).toInt(),
                        ))
                    .toList(),
                steps: (e['steps'] as List<dynamic>?)?.cast<String>() ?? [],
              ))
          .toList();
    });
  }

  Future<List<WeeklyWorkoutPlan>> getWeeklyWorkoutPlan(String goal) async {
    if (_mock) {
      await _mockDelay();
      return MockData.weeklyWorkoutPlan(goal);
    }
    return _guarded(() async {
      final res =
          await _dio.get('/v1/gym/workout-plan', queryParameters: {'goal': goal});
      return (res.data as List<dynamic>)
          .map((w) => WeeklyWorkoutPlan(
                weekNumber: (w['weekNumber'] as num).toInt(),
                title: w['title'] as String,
                days: (w['days'] as List<dynamic>)
                    .map((d) => WorkoutDay(
                          dayLabel: d['dayLabel'] as String,
                          exercises: (d['exercises'] as List<dynamic>)
                              .map((e) => WorkoutExercise(
                                    id: e['id'] as String,
                                    name: e['name'] as String,
                                    detail: e['detail'] as String,
                                    caloriesBurn:
                                        (e['caloriesBurn'] as num).toInt(),
                                  ))
                              .toList(),
                        ))
                    .toList(),
              ))
          .toList();
    });
  }

  Future<List<PartnerGym>> getPartnerGyms() async {
    if (_mock) {
      await _mockDelay();
      return MockData.partnerGyms;
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/gym/partners');
      return (res.data as List<dynamic>)
          .map((e) => PartnerGym(
                id: e['id'] as String,
                name: e['name'] as String,
                area: e['area'] as String,
                distanceKm: (e['distanceKm'] as num).toDouble(),
                rating: (e['rating'] as num).toDouble(),
                emoji: e['emoji'] as String? ?? '🏋️',
                offerText: e['offerText'] as String? ?? '',
                assignedTrainer: e['assignedTrainer'] as String? ?? 'Trainer',
              ))
          .toList();
    });
  }

  // ---- Orders ----
  Future<Order> placeOrder(OrderRequest request) async {
    if (_mock) {
      await _mockDelay();
      return MockData.order(request.total);
    }
    return _guarded(() async {
      final res = await _dio.post('/v1/orders', data: request.toJson());
      return Order.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<OrderStatus> getOrderStatus(String orderId) async {
    if (_mock) {
      await _mockDelay();
      return MockData.orderStatus(orderId);
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/orders/$orderId/status');
      return OrderStatus.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ---- Progress / Profile ----
  Future<ProgressData> getProgress() async {
    if (_mock) {
      await _mockDelay();
      return MockData.progress();
    }
    return _guarded(() async {
      final res = await _dio.get('/v1/progress/me');
      return ProgressData.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<UserProfile> getProfile() async {
    if (_mockAuth) {
      await _mockDelay();
      return MockData.profile();
    }
    return _guarded(() async {
      final res = await _dio.get('/me/profile');
      return UserProfile.fromJson(res.data as Map<String, dynamic>);
    });
  }
}
