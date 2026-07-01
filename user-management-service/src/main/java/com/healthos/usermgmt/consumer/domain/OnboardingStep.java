package com.healthos.usermgmt.consumer.domain;

import java.util.Locale;
import java.util.Map;

public enum OnboardingStep {
  NAME("name", "Add your name"),
  GOALS("goals", "Choose your goals"),
  SEX("sex", "Select gender"),
  AGE("age", "Enter your age"),
  HEIGHT("height", "Enter your height"),
  WEIGHT("weight", "Enter your weight"),
  TARGET_WEIGHT("target-weight", "Set your target weight"),
  PACE("pace", "Choose your goal pace"),
  MEDICAL("medical", "Add medical conditions"),
  CITY("city", "Enter your city"),
  ACTIVITY("activity", "Select activity level"),
  DIET("diet", "Choose your diet"),
  EMAIL("email", "Add your email");

  private static final Map<String, OnboardingStep> BY_KEY =
      Map.ofEntries(
          Map.entry("name", NAME),
          Map.entry("goals", GOALS),
          Map.entry("sex", SEX),
          Map.entry("age", AGE),
          Map.entry("height", HEIGHT),
          Map.entry("weight", WEIGHT),
          Map.entry("target-weight", TARGET_WEIGHT),
          Map.entry("pace", PACE),
          Map.entry("medical", MEDICAL),
          Map.entry("city", CITY),
          Map.entry("activity", ACTIVITY),
          Map.entry("diet", DIET),
          Map.entry("email", EMAIL));

  private final String key;
  private final String label;

  OnboardingStep(String key, String label) {
    this.key = key;
    this.label = label;
  }

  public String key() {
    return key;
  }

  public String label() {
    return label;
  }

  public String routePath() {
    return "/onboarding/" + key;
  }

  public static OnboardingStep fromKey(String raw) {
    if (raw == null || raw.isBlank()) {
      throw new IllegalArgumentException("Onboarding step is required");
    }
    var normalized = raw.trim().toLowerCase(Locale.ROOT);
    if (normalized.startsWith("/onboarding/")) {
      normalized = normalized.substring("/onboarding/".length());
    }
    var step = BY_KEY.get(normalized);
    if (step == null) {
      throw new IllegalArgumentException("Unknown onboarding step: " + raw);
    }
    return step;
  }
}
