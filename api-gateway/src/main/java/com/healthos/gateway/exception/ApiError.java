package com.healthos.gateway.exception;

import java.time.Instant;
import lombok.Builder;
import lombok.Value;

@Value
@Builder
public class ApiError {
  String traceId;
  Instant timestamp;
  int status;
  String errorCode;
  String message;
  String path;
}

