package com.healthos.usermgmt.adapters.inbound.rest.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
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
    log.error("Data store unavailable on {}", req.getRequestURI(), e);
    return error(
        HttpStatus.SERVICE_UNAVAILABLE,
        "SERVICE_UNAVAILABLE",
        "Database or cache temporarily unavailable",
        req);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiError> server(Exception e, HttpServletRequest req) {
    log.error("Unhandled error on {}", req.getRequestURI(), e);
    return error(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", "Unexpected error", req);
  }

  private static ResponseEntity<ApiError> error(
      HttpStatus status, String code, String message, HttpServletRequest req) {
    return ResponseEntity.status(status)
        .body(
            ApiError.builder()
                .traceId(UUID.randomUUID().toString())
                .timestamp(Instant.now())
                .status(status.value())
                .errorCode(code)
                .message(message)
                .path(req.getRequestURI())
                .build());
  }
}
