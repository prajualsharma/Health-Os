package com.healthos.usermgmt.shared.exception;

/** JWT is valid but the referenced user no longer exists (stale session). */
public class StaleSessionException extends RuntimeException {
  public StaleSessionException(String message) {
    super(message);
  }
}
