package com.healthos.kitchen.domain;

import java.util.Set;

public enum OrderStatus {
  NEW,
  ACCEPTED,
  PREPARING,
  READY,
  PICKED_UP,
  CANCELLED;

  /** Allowed forward transitions for the kitchen order board. */
  public boolean canTransitionTo(OrderStatus next) {
    return switch (this) {
      case NEW -> Set.of(ACCEPTED, CANCELLED).contains(next);
      case ACCEPTED -> Set.of(PREPARING, CANCELLED).contains(next);
      case PREPARING -> Set.of(READY, CANCELLED).contains(next);
      case READY -> Set.of(PICKED_UP).contains(next);
      case PICKED_UP, CANCELLED -> false;
    };
  }
}
