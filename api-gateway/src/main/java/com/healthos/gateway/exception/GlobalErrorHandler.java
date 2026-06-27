package com.healthos.gateway.exception;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.reactive.error.ErrorWebExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Configuration
@RequiredArgsConstructor
public class GlobalErrorHandler {
  private final ObjectMapper objectMapper;

  @Bean
  @Order(-2)
  public ErrorWebExceptionHandler errorWebExceptionHandler() {
    return (ServerWebExchange exchange, Throwable ex) -> {
      if (exchange.getResponse().isCommitted()) {
        return Mono.error(ex);
      }

      var status = HttpStatus.INTERNAL_SERVER_ERROR;
      var message = "Unexpected error";
      if (ex instanceof IllegalArgumentException) {
        status = HttpStatus.BAD_REQUEST;
        message = ex.getMessage();
      }

      exchange.getResponse().setStatusCode(status);
      exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);

      var err =
          ApiError.builder()
              .traceId(UUID.randomUUID().toString())
              .timestamp(Instant.now())
              .status(status.value())
              .errorCode(status == HttpStatus.BAD_REQUEST ? "BAD_REQUEST" : "INTERNAL_ERROR")
              .message(message)
              .path(exchange.getRequest().getURI().getPath())
              .build();

      byte[] bytes;
      try {
        bytes = objectMapper.writeValueAsBytes(err);
      } catch (JsonProcessingException e) {
        bytes = ("{\"error\":\"" + message + "\"}").getBytes(StandardCharsets.UTF_8);
      }
      var buffer = exchange.getResponse().bufferFactory().wrap(bytes);
      return exchange.getResponse().writeWith(Mono.just(buffer));
    };
  }
}

