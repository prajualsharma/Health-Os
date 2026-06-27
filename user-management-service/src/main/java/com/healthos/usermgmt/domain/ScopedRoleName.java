package com.healthos.usermgmt.domain;

import java.util.Set;

/**
 * Well-known scoped role names. These are seed/reference constants only - role names are
 * DB-driven (validated against the {@code roles} catalog), so new roles can be created at runtime
 * without changing this class.
 */
public final class ScopedRoleName {
  // Gym portal
  public static final String GYM_OWNER = "GYM_OWNER";
  public static final String GYM_MANAGER = "GYM_MANAGER";
  public static final String TRAINER = "TRAINER";
  public static final String STAFF = "STAFF";
  public static final String MEMBER = "MEMBER";

  // Kitchen portal
  public static final String CORPORATE = "CORPORATE";
  public static final String KITCHEN_STAFF = "KITCHEN_STAFF";

  private static final Set<String> SEEDED =
      Set.of(GYM_OWNER, GYM_MANAGER, TRAINER, STAFF, MEMBER, CORPORATE, KITCHEN_STAFF);

  private ScopedRoleName() {}

  /**
   * Whether the name is one of the built-in seeded roles. Validation of arbitrary, dynamically
   * created roles is done against the DB {@code roles} catalog in the service layer, not here.
   */
  public static boolean isSeeded(String roleName) {
    return roleName != null && SEEDED.contains(roleName);
  }

  public static Set<String> seeded() {
    return SEEDED;
  }
}
