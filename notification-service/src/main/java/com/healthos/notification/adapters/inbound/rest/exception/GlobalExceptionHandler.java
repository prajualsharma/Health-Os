package com.healthos.notification.adapters.inbound.rest.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

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

  @ExceptionHandler(AccessDeniedException.class)
  public ResponseEntity<ApiError> forbidden(AccessDeniedException e, HttpServletRequest req) {
    return error(HttpStatus.FORBIDDEN, "FORBIDDEN", "Access denied", req);
  }

  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiError> validation(
      MethodArgumentNotValidException e, HttpServletRequest req) {
    return error(HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", "Validation failed", req);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiError> server(Exception e, HttpServletRequest req) {
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
