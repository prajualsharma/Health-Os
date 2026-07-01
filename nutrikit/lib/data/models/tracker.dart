/// Snapshot for a single tracker row on the home screen.
class TrackerSnapshot {
  const TrackerSnapshot({
    required this.id,
    required this.title,
    required this.subtitle,
    this.action = TrackerAction.add,
  });

  final String id;
  final String title;
  final String subtitle;
  final TrackerAction action;

  factory TrackerSnapshot.fromJson(Map<String, dynamic> json) {
    return TrackerSnapshot(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      action: TrackerActionX.fromKey(json['action'] as String?),
    );
  }
}

enum TrackerAction { add, navigate, none }

extension TrackerActionX on TrackerAction {
  static TrackerAction fromKey(String? key) => switch (key) {
        'navigate' => TrackerAction.navigate,
        'none' => TrackerAction.none,
        _ => TrackerAction.add,
      };
}

enum TrackerKind {
  nutrition,
  weight,
  workout,
  steps,
  sleep,
  water,
}

extension TrackerKindX on TrackerKind {
  String get apiPath => switch (this) {
        TrackerKind.nutrition => '/v1/trackers/nutrition',
        TrackerKind.weight => '/v1/trackers/weight',
        TrackerKind.workout => '/v1/trackers/workout',
        TrackerKind.steps => '/v1/trackers/steps',
        TrackerKind.sleep => '/v1/trackers/sleep',
        TrackerKind.water => '/v1/trackers/water',
      };
}
