package com.healthos.gateway.filters;

import com.healthos.gateway.security.JwtValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter implements GlobalFilter, Ordered {
  private final JwtValidator validator;

  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
    var path = exchange.getRequest().getURI().getPath();
    if (isPublicPath(path)) {
      return chain.filter(exchange);
    }

    var auth = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
    if (auth == null || !auth.startsWith("Bearer ")) {
      exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
      return exchange.getResponse().setComplete();
    }

    try {
      var jwt = validator.validate(auth.substring("Bearer ".length()).trim());
      var builder =
          exchange
              .getRequest()
              .mutate()
              .header("X-User-Id", jwt.userId().toString())
              .header("X-User-Email", jwt.email() == null ? "" : jwt.email())
              .header("X-User-Roles", String.join(",", jwt.roles()));

      if (jwt.membershipsJson() != null && !jwt.membershipsJson().isBlank()) {
        builder.header("X-User-Memberships", jwt.membershipsJson());
      }
      if (jwt.activeScope() != null) {
        builder
            .header("X-Portal-Type", jwt.activeScope().portal())
            .header("X-Scope-Type", jwt.activeScope().scopeType())
            .header("X-Scope-Id", jwt.activeScope().scopeId())
            .header("X-Active-Scope-Id", jwt.activeScope().scopeId());
      }

      var mutated = builder.build();
      return chain.filter(exchange.mutate().request(mutated).build());
    } catch (Exception e) {
      exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
      return exchange.getResponse().setComplete();
    }
  }

  private static boolean isPublicPath(String path) {
    return path.startsWith("/actuator")
        || path.startsWith("/swagger-ui")
        || path.startsWith("/v3/api-docs")
        || path.startsWith("/docs/")
        || path.startsWith("/auth/")
        || path.equals("/swagger-ui.html");
  }

  @Override
  public int getOrder() {
    return -50;
  }
}

