import '../models/auth.dart';
import '../models/dashboard.dart';
import '../models/dish.dart';
import '../models/gym.dart';
import '../models/meal.dart';
import '../models/meal_plan.dart';
import '../models/meal_system.dart';
import '../models/order.dart';
import '../models/progress.dart';
import '../models/recipe.dart';
import '../models/subscription_plan.dart';
import '../models/tracker.dart';
import '../models/user_profile.dart';

/// In-app mock data so the app runs standalone without a live backend.
class MockData {
  MockData._();

  static const List<Ingredient> _grilledChicken = [
    Ingredient(name: 'Grilled chicken breast', weight: '180g'),
    Ingredient(name: 'Brown rice', weight: '120g'),
    Ingredient(name: 'Steamed broccoli', weight: '80g'),
    Ingredient(name: 'Olive oil', weight: '10g'),
    Ingredient(name: 'Mixed greens', weight: '30g'),
  ];

  static const List<Ingredient> _oatsBowl = [
    Ingredient(name: 'Rolled oats', weight: '60g'),
    Ingredient(name: 'Greek yogurt', weight: '120g'),
    Ingredient(name: 'Blueberries', weight: '40g'),
    Ingredient(name: 'Almonds', weight: '15g'),
    Ingredient(name: 'Honey', weight: '8g'),
  ];

  static List<Meal> meals = [
    Meal(
      id: 'm1',
      slot: 'Breakfast',
      name: 'Protein Oats Bowl',
      emoji: '🥣',
      subtitle: 'Oats · Greek yogurt · berries',
      calories: 380,
      protein: 28,
      carbs: 48,
      fat: 10,
      portion: '290g',
      isVeg: true,
      done: true,
      price: 149,
      ingredients: _oatsBowl,
    ),
    Meal(
      id: 'm2',
      slot: 'Lunch',
      name: 'Grilled Chicken Rice',
      emoji: '🍗',
      subtitle: 'Chicken · brown rice · broccoli',
      calories: 520,
      protein: 45,
      carbs: 55,
      fat: 14,
      portion: '420g',
      isVeg: false,
      done: true,
      price: 249,
      ingredients: _grilledChicken,
    ),
    Meal(
      id: 'm3',
      slot: 'Snack',
      name: 'Paneer Tikka Box',
      emoji: '🧆',
      subtitle: 'Paneer · peppers · mint dip',
      calories: 260,
      protein: 18,
      carbs: 14,
      fat: 14,
      portion: '180g',
      isVeg: true,
      done: false,
      price: 179,
      ingredients: const [
        Ingredient(name: 'Paneer', weight: '120g'),
        Ingredient(name: 'Bell peppers', weight: '50g'),
        Ingredient(name: 'Mint yogurt dip', weight: '30g'),
      ],
    ),
    Meal(
      id: 'm4',
      slot: 'Dinner',
      name: 'Salmon & Quinoa',
      emoji: '🐟',
      subtitle: 'Salmon · quinoa · asparagus',
      calories: 480,
      protein: 38,
      carbs: 40,
      fat: 18,
      portion: '380g',
      isVeg: false,
      done: false,
      price: 329,
      ingredients: const [
        Ingredient(name: 'Salmon fillet', weight: '160g'),
        Ingredient(name: 'Quinoa', weight: '110g'),
        Ingredient(name: 'Asparagus', weight: '70g'),
        Ingredient(name: 'Lemon butter', weight: '12g'),
      ],
    ),
  ];

  static List<Dish> kitchenMenu = [
    const Dish(
      id: 'd1',
      name: 'Protein Oats Bowl',
      emoji: '🥣',
      category: 'Breakfast',
      calories: 380,
      protein: 28,
      isVeg: true,
      price: 149,
      portion: '290g',
      kitchenName: 'HealthOS Cloud Kitchen',
      rating: 4.8,
      deliveryEta: '25–35 min',
    ),
    const Dish(
      id: 'd2',
      name: 'Egg White Wrap',
      emoji: '🌯',
      category: 'Breakfast',
      calories: 320,
      protein: 26,
      isVeg: false,
      price: 169,
      portion: '240g',
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
    const Dish(
      id: 'd3',
      name: 'Grilled Chicken Rice',
      emoji: '🍗',
      category: 'Lunch',
      calories: 520,
      protein: 45,
      isVeg: false,
      price: 249,
      portion: '420g',
      kitchenName: 'FitFuel Kitchen',
      rating: 4.9,
    ),
    const Dish(
      id: 'd4',
      name: 'Rajma Brown Rice',
      emoji: '🍛',
      category: 'Lunch',
      calories: 460,
      protein: 22,
      isVeg: true,
      price: 199,
      portion: '380g',
      kitchenName: 'FitFuel Kitchen',
    ),
    const Dish(
      id: 'd5',
      name: 'Salmon & Quinoa',
      emoji: '🐟',
      category: 'Dinner',
      calories: 480,
      protein: 38,
      isVeg: false,
      price: 329,
      portion: '380g',
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
    const Dish(
      id: 'd6',
      name: 'Tofu Stir Fry',
      emoji: '🥘',
      category: 'Dinner',
      calories: 410,
      protein: 26,
      isVeg: true,
      price: 219,
      portion: '350g',
      kitchenName: 'FitFuel Kitchen',
    ),
    const Dish(
      id: 'd7',
      name: 'Paneer Tikka Box',
      emoji: '🧆',
      category: 'Snack',
      calories: 260,
      protein: 18,
      isVeg: true,
      price: 179,
      portion: '180g',
      isAddOn: true,
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
    const Dish(
      id: 'd8',
      name: 'Roasted Chana Mix',
      emoji: '🥜',
      category: 'Snack',
      calories: 180,
      protein: 12,
      isVeg: true,
      price: 99,
      portion: '80g',
      isAddOn: true,
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
    const Dish(
      id: 'd9',
      name: 'Cold Brew Coffee',
      emoji: '☕',
      category: 'Beverage',
      calories: 15,
      protein: 1,
      isVeg: true,
      price: 150,
      portion: '250ml',
      isAddOn: true,
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
    const Dish(
      id: 'd10',
      name: 'Sprout Chaat',
      emoji: '🥗',
      category: 'Snack',
      calories: 120,
      protein: 8,
      isVeg: true,
      price: 120,
      portion: '120g',
      isAddOn: true,
      kitchenName: 'FitFuel Kitchen',
    ),
    const Dish(
      id: 'd11',
      name: 'Green Smoothie',
      emoji: '🥤',
      category: 'Beverage',
      calories: 95,
      protein: 4,
      isVeg: true,
      price: 139,
      portion: '300ml',
      isAddOn: true,
      kitchenName: 'HealthOS Cloud Kitchen',
    ),
  ];

  static List<Dish> kitchenMenuFiltered({bool addOnsOnly = false}) {
    if (addOnsOnly) {
      return kitchenMenu
          .where((d) =>
              d.isAddOn ||
              d.category == 'Snack' ||
              d.category == 'Beverage')
          .toList();
    }
    return kitchenMenu;
  }

  static List<MealSystemPlan> mealSystemPlans() => const [
        MealSystemPlan(
          id: 'ms2',
          name: '2-Meal System',
          tagline: 'Lunch + Dinner delivered daily',
          pricePerMonth: 5999,
          systemType: MealSystemType.twoMeal,
          slots: ['Lunch', 'Dinner'],
          features: [
            'Macro-matched portions',
            '2 nearby cloud kitchens',
            'Skip or swap anytime',
          ],
        ),
        MealSystemPlan(
          id: 'ms3',
          name: '3-Meal System',
          tagline: 'Breakfast + Lunch + Dinner',
          pricePerMonth: 7999,
          systemType: MealSystemType.threeMeal,
          slots: ['Breakfast', 'Lunch', 'Dinner'],
          features: [
            'Full-day coverage',
            'Priority delivery slots',
            'Add-ons billed separately',
          ],
        ),
      ];

  static Map<String, List<Dish>> tomorrowOptions({
    required DateTime date,
    required List<String> slots,
  }) {
    final bySlot = <String, List<Dish>>{
      'Breakfast': [
        kitchenMenu[0],
        kitchenMenu[1],
        const Dish(
          id: 'tb1',
          name: 'Berry Smoothie Bowl',
          emoji: '🫐',
          category: 'Breakfast',
          calories: 340,
          protein: 22,
          isVeg: true,
          price: 159,
          portion: '280g',
          kitchenName: 'FitFuel Kitchen',
        ),
      ],
      'Lunch': [
        kitchenMenu[2],
        kitchenMenu[3],
        const Dish(
          id: 'tl1',
          name: 'Paneer Power Salad',
          emoji: '🥗',
          category: 'Lunch',
          calories: 440,
          protein: 32,
          isVeg: true,
          price: 229,
          portion: '360g',
          kitchenName: 'HealthOS Cloud Kitchen',
        ),
      ],
      'Dinner': [
        kitchenMenu[4],
        kitchenMenu[5],
        const Dish(
          id: 'td1',
          name: 'Chicken Khichdi',
          emoji: '🍲',
          category: 'Dinner',
          calories: 450,
          protein: 35,
          isVeg: false,
          price: 239,
          portion: '400g',
          kitchenName: 'FitFuel Kitchen',
        ),
      ],
    };
    return {for (final s in slots) s: bySlot[s] ?? []};
  }

  static List<Recipe> recipesForTarget({
    required int calorieTarget,
    required int proteinTarget,
  }) {
    final remaining = (calorieTarget - 1240).clamp(200, 800);
    return [
      Recipe(
        id: 'r1',
        name: 'Greek Yogurt Parfait',
        slot: 'Snack',
        emoji: '🥛',
        calories: remaining ~/ 2,
        protein: (proteinTarget - 98) ~/ 3,
        carbs: 28,
        fat: 8,
        fitsGoal: true,
        ingredients: const [
          RecipeIngredient(name: 'Greek yogurt', grams: 150),
          RecipeIngredient(name: 'Granola', grams: 40),
          RecipeIngredient(name: 'Mixed berries', grams: 60),
          RecipeIngredient(name: 'Honey', grams: 10),
        ],
        steps: const [
          'Layer yogurt, granola, and berries in a bowl.',
          'Drizzle honey on top and serve chilled.',
        ],
      ),
      Recipe(
        id: 'r2',
        name: 'Paneer Bhurji Wrap',
        slot: 'Dinner',
        emoji: '🌯',
        calories: remaining,
        protein: (proteinTarget - 98) ~/ 2,
        carbs: 42,
        fat: 14,
        fitsGoal: true,
        ingredients: const [
          RecipeIngredient(name: 'Paneer', grams: 120),
          RecipeIngredient(name: 'Whole wheat roti', grams: 60),
          RecipeIngredient(name: 'Onion', grams: 40),
          RecipeIngredient(name: 'Tomato', grams: 50),
          RecipeIngredient(name: 'Olive oil', grams: 8),
        ],
      ),
      Recipe(
        id: 'r3',
        name: 'Moong Dal Cheela',
        slot: 'Breakfast',
        emoji: '🥞',
        calories: 310,
        protein: 18,
        carbs: 38,
        fat: 9,
        fitsGoal: remaining >= 300,
        ingredients: const [
          RecipeIngredient(name: 'Moong dal batter', grams: 120),
          RecipeIngredient(name: 'Spinach', grams: 30),
          RecipeIngredient(name: 'Capsicum', grams: 40),
        ],
      ),
    ];
  }

  static List<WeeklyWorkoutPlan> weeklyWorkoutPlan(String goal) {
    final isLose = goal.toLowerCase().contains('lose');
    final isGain = goal.toLowerCase().contains('gain');
    return List.generate(4, (week) {
      final cardio = isLose ? '30 min HIIT' : '20 min steady cardio';
      final strength = isGain ? '4×12 heavy' : '3×15 moderate';
      return WeeklyWorkoutPlan(
        weekNumber: week + 1,
        title: 'Week ${week + 1} · ${isLose ? 'Fat burn' : isGain ? 'Hypertrophy' : 'Maintenance'}',
        days: [
          WorkoutDay(dayLabel: 'Mon', exercises: [
            WorkoutExercise(
              id: 'w${week}_m1',
              name: 'Treadmill intervals',
              detail: cardio,
              caloriesBurn: isLose ? 280 : 180,
            ),
            WorkoutExercise(
              id: 'w${week}_m2',
              name: 'Goblet squats',
              detail: strength,
              caloriesBurn: 120,
            ),
          ]),
          WorkoutDay(dayLabel: 'Tue', exercises: [
            WorkoutExercise(
              id: 'w${week}_t1',
              name: 'Bench press / push-ups',
              detail: strength,
              caloriesBurn: 140,
            ),
          ]),
          WorkoutDay(dayLabel: 'Wed', exercises: [
            WorkoutExercise(
              id: 'w${week}_w1',
              name: 'Rowing machine',
              detail: '20 min',
              caloriesBurn: 200,
            ),
          ]),
          WorkoutDay(dayLabel: 'Thu', exercises: [
            WorkoutExercise(
              id: 'w${week}_th1',
              name: 'Deadlifts',
              detail: strength,
              caloriesBurn: 160,
            ),
          ]),
          WorkoutDay(dayLabel: 'Fri', exercises: [
            WorkoutExercise(
              id: 'w${week}_f1',
              name: 'Cycling',
              detail: '25 min',
              caloriesBurn: 190,
            ),
          ]),
        ],
      );
    });
  }

  static const Map<String, DailyWorkoutPlan> gymDailyPlans = {
    'Mon': DailyWorkoutPlan(
      day: 'Mon',
      focus: 'Chest & Triceps',
      exercises: [
        WorkoutExercise(
          id: 'mon1',
          name: 'Cardio Warmup',
          detail: 'Treadmill - 10 min at 6 km/h',
          caloriesBurn: 80,
        ),
        WorkoutExercise(
          id: 'mon2',
          name: 'Bench Press',
          detail: '4 sets × 10 reps',
          caloriesBurn: 120,
        ),
        WorkoutExercise(
          id: 'mon3',
          name: 'Incline Dumbbell Press',
          detail: '3 sets × 12 reps',
          caloriesBurn: 90,
        ),
        WorkoutExercise(
          id: 'mon4',
          name: 'Cable Flyes',
          detail: '3 sets × 15 reps',
          caloriesBurn: 70,
        ),
        WorkoutExercise(
          id: 'mon5',
          name: 'Tricep Dips',
          detail: '3 sets × 12 reps',
          caloriesBurn: 80,
        ),
        WorkoutExercise(
          id: 'mon6',
          name: 'Cardio Cooldown',
          detail: 'Treadmill - 8 min at 6.5 km/h',
          caloriesBurn: 60,
        ),
      ],
    ),
    'Wed': DailyWorkoutPlan(
      day: 'Wed',
      focus: 'Back & Biceps',
      exercises: [
        WorkoutExercise(
          id: 'wed1',
          name: 'Cardio Warmup',
          detail: 'Cycling - 10 min at moderate pace',
          caloriesBurn: 85,
        ),
        WorkoutExercise(
          id: 'wed2',
          name: 'Pull-ups',
          detail: '4 sets × 8 reps',
          caloriesBurn: 100,
        ),
        WorkoutExercise(
          id: 'wed3',
          name: 'Barbell Rows',
          detail: '4 sets × 10 reps',
          caloriesBurn: 110,
        ),
        WorkoutExercise(
          id: 'wed4',
          name: 'Lat Pulldown',
          detail: '3 sets × 12 reps',
          caloriesBurn: 80,
        ),
        WorkoutExercise(
          id: 'wed5',
          name: 'Bicep Curls',
          detail: '3 sets × 15 reps',
          caloriesBurn: 65,
        ),
        WorkoutExercise(
          id: 'wed6',
          name: 'Cardio Finish',
          detail: 'Rowing machine - 8 min',
          caloriesBurn: 70,
        ),
      ],
    ),
    'Fri': DailyWorkoutPlan(
      day: 'Fri',
      focus: 'Legs & Shoulders',
      exercises: [
        WorkoutExercise(
          id: 'fri1',
          name: 'Cardio Warmup',
          detail: 'Jump rope - 5 min',
          caloriesBurn: 70,
        ),
        WorkoutExercise(
          id: 'fri2',
          name: 'Squats',
          detail: '4 sets × 12 reps',
          caloriesBurn: 140,
        ),
        WorkoutExercise(
          id: 'fri3',
          name: 'Leg Press',
          detail: '3 sets × 15 reps',
          caloriesBurn: 100,
        ),
        WorkoutExercise(
          id: 'fri4',
          name: 'Shoulder Press',
          detail: '4 sets × 10 reps',
          caloriesBurn: 90,
        ),
        WorkoutExercise(
          id: 'fri5',
          name: 'Lateral Raises',
          detail: '3 sets × 15 reps',
          caloriesBurn: 50,
        ),
        WorkoutExercise(
          id: 'fri6',
          name: 'HIIT Cardio',
          detail: '15 min intervals',
          caloriesBurn: 180,
        ),
      ],
    ),
  };

  static const List<PartnerGym> partnerGyms = [
    PartnerGym(
      id: 'pg1',
      name: 'FitHub Indiranagar',
      area: '100 Feet Road',
      distanceKm: 1.2,
      rating: 4.8,
      emoji: '🏋️',
      offerText: 'Free 7-day trial for NutriKit members',
      assignedTrainer: 'Rahul Sharma',
    ),
    PartnerGym(
      id: 'pg2',
      name: 'Pulse Koramangala',
      area: '5th Block',
      distanceKm: 2.6,
      rating: 4.6,
      emoji: '🤸',
      offerText: '2 PT sessions included',
      assignedTrainer: 'Ananya Iyer',
    ),
    PartnerGym(
      id: 'pg3',
      name: 'Iron Yard HSR',
      area: 'Sector 2',
      distanceKm: 3.4,
      rating: 4.7,
      emoji: '💪',
      offerText: 'NutriKit meal sync enabled',
      assignedTrainer: 'Vikram Patel',
    ),
  ];

  static DashboardData dashboard() => DashboardData(
        userName: 'Arjun Mehta',
        initials: 'AM',
        calorieTarget: 1840,
        caloriesConsumed: 1240,
        proteinConsumed: 98,
        proteinTarget: 145,
        carbsConsumed: 110,
        carbTarget: 180,
        fatConsumed: 40,
        fatTarget: 62,
        quickStats: const [
          QuickStat(emoji: '🔥', value: '7', label: 'Day streak'),
          QuickStat(emoji: '💧', value: '1.8L', label: 'Water'),
          QuickStat(emoji: '👟', value: '6,240', label: 'Steps'),
        ],
        meals: meals,
      );

  static MealPlanData mealPlan(DateTime date) => MealPlanData(
        date: date,
        totalCalories: 1540,
        totalProtein: 118,
        totalCarbs: 162,
        totalFat: 52,
        onTrack: true,
        meals: meals,
      );

  static UserProfile profile() => const UserProfile(
        name: 'Arjun Mehta',
        email: 'arjun.mehta@email.com',
        initials: 'AM',
        goal: 'Lose Weight',
        currentWeight: 76.5,
        targetWeight: 70,
        height: 178,
        calorieTarget: 1840,
        proteinTarget: 145,
        carbTarget: 180,
        fatTarget: 62,
        plan: 'NutriKit Pro',
        gymName: 'FitHub Gym',
      );

  static ProgressData progress() => const ProgressData(
        currentWeight: 76.5,
        kgLost: 3.5,
        weekStreak: 7,
        lastLoggedWeight: 76.5,
        weights: [
          WeightPoint(label: 'W1', weight: 80.0),
          WeightPoint(label: 'W2', weight: 79.2),
          WeightPoint(label: 'W3', weight: 78.6),
          WeightPoint(label: 'W4', weight: 78.0),
          WeightPoint(label: 'W5', weight: 77.4),
          WeightPoint(label: 'W6', weight: 77.0),
          WeightPoint(label: 'W7', weight: 76.5),
        ],
        adherence: [
          AdherenceDay(day: 'Mon', pct: 95),
          AdherenceDay(day: 'Tue', pct: 88),
          AdherenceDay(day: 'Wed', pct: 100),
          AdherenceDay(day: 'Thu', pct: 72),
          AdherenceDay(day: 'Fri', pct: 91),
          AdherenceDay(day: 'Sat', pct: 85),
          AdherenceDay(day: 'Sun', pct: 0),
        ],
      );

  static OnboardingResponse onboardingResult() => const OnboardingResponse(
        calorieTarget: 1840,
        proteinTarget: 145,
        carbTarget: 180,
        fatTarget: 62,
        timelineWeeks: 10,
        targetWeight: 70,
      );

  static AuthResponse auth() => const AuthResponse(
        token: 'mock_token_nutrikit_demo',
        userId: 'u_demo_1',
        name: 'Arjun Mehta',
      );

  static Order order(double total) => Order(
        id: '#NK-20240531-1847',
        total: total,
        eta: '7:30 – 8:00 PM',
        status: 'Confirmed',
      );

  static OrderStatus orderStatus(String orderId) => OrderStatus(
        orderId: orderId,
        etaMinutes: 35,
        steps: const [
          TrackingStep(label: 'Order Confirmed', time: '7:02 PM', state: 'done'),
          TrackingStep(label: 'Being Prepared', time: '7:10 PM', state: 'done'),
          TrackingStep(label: 'Quality Check', time: '7:25 PM', state: 'active'),
          TrackingStep(label: 'Out for Delivery', time: '', state: 'pending'),
          TrackingStep(label: 'Delivered', time: '', state: 'pending'),
        ],
      );

  // ---- Gym (browse + choose membership plans) ----
  static const List<GymStudio> gymStudios = [
    GymStudio(
        id: 'g1',
        name: 'FitHub Indiranagar',
        area: '100 Feet Road · 1.2 km',
        rating: 4.8,
        emoji: '🏋️'),
    GymStudio(
        id: 'g2',
        name: 'Pulse Koramangala',
        area: '5th Block · 2.6 km',
        rating: 4.6,
        emoji: '🤸'),
    GymStudio(
        id: 'g3',
        name: 'Iron Yard HSR',
        area: 'Sector 2 · 3.4 km',
        rating: 4.7,
        emoji: '💪'),
  ];

  static const List<GymPlan> gymPlans = [
    GymPlan(
      id: 'p1',
      name: 'Starter',
      tagline: 'Get moving with the essentials',
      pricePerMonth: 1499,
      period: 'month',
      emoji: '🌱',
      features: [
        'Access to gym floor',
        'Locker + towel service',
        '1 group class / week',
      ],
    ),
    GymPlan(
      id: 'p2',
      name: 'Pro',
      tagline: 'Most popular · best value',
      pricePerMonth: 2499,
      period: 'month',
      emoji: '🔥',
      popular: true,
      features: [
        'Everything in Starter',
        'Unlimited group classes',
        '2 PT sessions / month',
        'NutriKit meal plan sync',
      ],
    ),
    GymPlan(
      id: 'p3',
      name: 'Elite',
      tagline: 'Personal training, all in',
      pricePerMonth: 4999,
      period: 'month',
      emoji: '👑',
      features: [
        'Everything in Pro',
        'Unlimited personal training',
        'Body composition analysis',
        'Priority class booking',
      ],
    ),
  ];

  // ---- Trackers (one endpoint per box on home) ----
  static TrackerSnapshot tracker(TrackerKind kind) => switch (kind) {
        TrackerKind.nutrition => const TrackerSnapshot(
              id: 'nutrition',
              title: 'Track Food',
              subtitle: 'Eat 1,840 Cal',
            ),
        TrackerKind.weight => const TrackerSnapshot(
              id: 'weight',
              title: 'Weight',
              subtitle: '0 kg gained',
            ),
        TrackerKind.workout => const TrackerSnapshot(
              id: 'workout',
              title: 'Workout',
              subtitle: 'Goal: 440 cal',
            ),
        TrackerKind.steps => const TrackerSnapshot(
              id: 'steps',
              title: 'Steps',
              subtitle: 'Set Up Auto-Tracking',
              action: TrackerAction.navigate,
            ),
        TrackerKind.sleep => const TrackerSnapshot(
              id: 'sleep',
              title: 'Sleep',
              subtitle: 'Set Up Sleep Goal',
              action: TrackerAction.navigate,
            ),
        TrackerKind.water => const TrackerSnapshot(
              id: 'water',
              title: 'Water',
              subtitle: 'Goal: 8 glasses',
            ),
      };

  static List<SubscriptionPlan> subscriptionPlans() => const [
        SubscriptionPlan(
          id: 'home-pro',
          name: 'NutriKit Home',
          tagline: 'Trackers, insights & AI coaching',
          pricePerMonth: 299,
          category: PlanCategory.home,
          features: [
            'All health trackers',
            'Weekly AI insights',
            'Progress sharing',
          ],
          route: '/home/dashboard',
        ),
        SubscriptionPlan(
          id: 'meal-2',
          name: '2-Meal Plan',
          tagline: 'Lunch + Dinner delivered daily',
          pricePerMonth: 5999,
          category: PlanCategory.diet,
          highlight: true,
          features: [
            'Macro-matched meals',
            'Free delivery',
            'Skip or swap anytime',
          ],
          route: '/home/food?segment=nutriplan',
        ),
        SubscriptionPlan(
          id: 'meal-3',
          name: '3-Meal Plan',
          tagline: 'Breakfast, lunch & dinner',
          pricePerMonth: 7999,
          category: PlanCategory.diet,
          features: [
            'Full-day nutrition',
            'Chef-crafted menu',
            'NutriPlan AI sync',
          ],
          route: '/home/food?segment=nutriplan',
        ),
        SubscriptionPlan(
          id: 'couple',
          name: 'Couple Plan',
          tagline: 'One subscription, order for both',
          pricePerMonth: 9999,
          category: PlanCategory.couple,
          highlight: true,
          features: [
            'Add your partner',
            'Order meals for both',
            'Shared progress like Apple Health',
            'Single billing',
          ],
          route: '/plans/couple',
        ),
        SubscriptionPlan(
          id: 'gym-pro',
          name: 'Gym Pro',
          tagline: 'Unlimited classes + meal sync',
          pricePerMonth: 2499,
          category: PlanCategory.gym,
          features: [
            'Unlimited group classes',
            '2 PT sessions / month',
            'NutriKit meal plan sync',
          ],
          route: '/home/gym',
        ),
        SubscriptionPlan(
          id: 'gym-elite',
          name: 'Gym Elite',
          tagline: 'Personal training, all in',
          pricePerMonth: 4999,
          category: PlanCategory.gym,
          features: [
            'Unlimited personal training',
            'Body composition analysis',
            'Priority class booking',
          ],
          route: '/home/gym',
        ),
      ];
}
