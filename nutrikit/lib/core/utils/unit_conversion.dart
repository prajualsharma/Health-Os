/// Converts height to centimeters for API storage.
int heightToCm({
  required String unit,
  int? cm,
  int? feet,
  int? inches,
}) {
  if (unit == 'cm') return cm ?? 0;
  final totalInches = (feet ?? 0) * 12 + (inches ?? 0);
  return (totalInches * 2.54).round();
}

/// Converts weight to kilograms for API storage.
double weightToKg({required String unit, required double value}) {
  if (unit == 'kg') return value;
  return value * 0.453592;
}

double kgToLb(double kg) => kg / 0.453592;

(int min, int max) healthyWeightRangeKg(int heightCm) {
  if (heightCm <= 0) return (0, 0);
  final heightM = heightCm / 100.0;
  final min = (18.5 * heightM * heightM).round();
  final max = (24.9 * heightM * heightM).round();
  return (min, max);
}
