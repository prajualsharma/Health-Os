package com.healthos.usermgmt.adapters.inbound.rest.exception;

import com.healthos.usermgmt.shared.exception.StaleSessionException;
import jakarta.persistence.PersistenceException;
import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.hibernate.LazyInitializationException;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(StaleSessionException.class)
  public ResponseEntity<ApiError> staleSession(StaleSessionException e, HttpServletRequest req) {
    return error(HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", e.getMessage(), req);
  }

  @ExceptionHandler(IllegalArgumentException.class)
  public ResponseEntity<ApiError> badRequest(IllegalArgumentException e, HttpServletRequest req) {
    return error(HttpStatus.BAD_REQUEST, "BAD_REQUEST", e.getMessage(), req);
  }

  @ExceptionHandler(IllegalStateException.class)
  public ResponseEntity<ApiError> conflict(IllegalStateException e, HttpServletRequest req) {
    return error(HttpStatus.CONFLICT, "CONFLICT", e.getMessage(), req);
  }

  @ExceptionHandler(SecurityException.class)
  public ResponseEntity<ApiError> forbidden(SecurityException e, HttpServletRequest req) {
    return error(HttpStatus.FORBIDDEN, "FORBIDDEN", e.getMessage(), req);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiError> validation(MethodArgumentNotValidException e, HttpServletRequest req) {
    return error(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", "Validation failed", req);
  }

  @ExceptionHandler(DataIntegrityViolationException.class)
  public ResponseEntity<ApiError> dataConflict(DataIntegrityViolationException e, HttpServletRequest req) {
    log.warn("Data integrity violation on {}: {}", req.getRequestURI(), e.getMessage());
    return error(
        HttpStatus.CONFLICT,
        "CONFLICT",
        "Phone or email already registered",
        req);
  }

  @ExceptionHandler({RedisConnectionFailureException.class, DataAccessException.class})
  public ResponseEntity<ApiError> dataStoreUnavailable(DataAccessException e, HttpServletRequest req) {
    return error(
        HttpStatus.SERVICE_UNAVAILABLE,
        "SERVICE_UNAVAILABLE",
        "Database or cache temporarily unavailable",
        req,
        e);
  }

  @ExceptionHandler({LazyInitializationException.class, PersistenceException.class})
  public ResponseEntity<ApiError> persistenceFailure(PersistenceException e, HttpServletRequest req) {
    return error(
        HttpStatus.SERVICE_UNAVAILABLE,
        "SERVICE_UNAVAILABLE",
        "Database or cache temporarily unavailable",
        req,
        e);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiError> server(Exception e, HttpServletRequest req) {
    return error(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", "Unexpected error", req, e);
  }

  private static ResponseEntity<ApiError> error(
      HttpStatus status, String code, String message, HttpServletRequest req) {
    return error(status, code, message, req, null);
  }

  private static ResponseEntity<ApiError> error(
      HttpStatus status, String code, String message, HttpServletRequest req, Exception cause) {
    var traceId = UUID.randomUUID().toString();
    if (cause != null) {
      log.error("Request failed [{}] {} {}: {}", traceId, status.value(), req.getRequestURI(), message, cause);
    }
    return ResponseEntity.status(status)
        .body(
            ApiError.builder()
                .traceId(traceId)
                .timestamp(Instant.now())
                .status(status.value())
                .errorCode(code)
                .message(message)
                .path(req.getRequestURI())
                .build());
  }
}
