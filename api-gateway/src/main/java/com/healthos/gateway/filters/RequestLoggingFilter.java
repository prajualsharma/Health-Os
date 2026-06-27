package com.healthos.gateway.filters;

import java.time.Duration;
import java.time.Instant;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
@Slf4j
public class RequestLoggingFilter implements GlobalFilter, Ordered {
  @Override
  public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
    var start = Instant.now();
    var request = exchange.getRequest();
    var id = exchange.getRequest().getId();
    return chain
        .filter(exchange)
        .doFinally(
            signal -> {
              var status =
                  exchange.getResponse().getStatusCode() != null
                      ? exchange.getResponse().getStatusCode().value()
                      : 0;
              var ms = Duration.between(start, Instant.now()).toMillis();
              log.info(
                  "req_id={} method={} path={} status={} latency_ms={}",
                  id,
                  request.getMethod(),
                  request.getURI().getPath(),
                  status,
                  ms);
            });
  }

  @Override
  public int getOrder() {
    return -100;
  }
}

