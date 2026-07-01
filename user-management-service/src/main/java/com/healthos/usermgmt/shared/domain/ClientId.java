package com.healthos.usermgmt.shared.domain;

public enum ClientId {
  NUTRIKIT("nutrikit"),
  KITCHEN("kitchen"),
  GYM("gym");

  private final String value;

  ClientId(String value) {
    this.value = value;
  }

  public String value() {
    return value;
  }

  public AccountType accountType() {
    return this == NUTRIKIT ? AccountType.CONSUMER : AccountType.STAFF;
  }

  public static ClientId from(String raw) {
    if (raw == null || raw.isBlank()) {
      return NUTRIKIT;
    }
    var normalized = raw.trim().toLowerCase();
    for (var id : values()) {
      if (id.value.equals(normalized)) {
        return id;
      }
    }
    throw new IllegalArgumentException("Unknown clientId: " + raw);
  }
}
