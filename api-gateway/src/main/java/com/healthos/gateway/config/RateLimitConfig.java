package com.healthos.gateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.cloud.gateway.filter.ratelimit.RedisRateLimiter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import reactor.core.publisher.Mono;

@Configuration
public class RateLimitConfig {
  @Bean
  public RedisRateLimiter redisRateLimiter(GatewayProperties props) {
    return new RedisRateLimiter(props.getRateLimit().getReplenishRate(), props.getRateLimit().getBurstCapacity());
  }

  @Bean
  public KeyResolver ipKeyResolver() {
    return exchange ->
        Mono.justOrEmpty(exchange.getRequest().getRemoteAddress())
            .map(addr -> addr.getAddress().getHostAddress())
            .defaultIfEmpty("unknown");
  }
}

