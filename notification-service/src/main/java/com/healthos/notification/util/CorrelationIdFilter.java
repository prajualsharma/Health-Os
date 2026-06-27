package com.healthos.notification.util;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CorrelationIdFilter extends OncePerRequestFilter {

  public static final String CORRELATION_HEADER = "X-Correlation-Id";
  public static final String TENANT_HEADER = "X-Tenant-Id";

  @Override
  protected void doFilterInternal(
      HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
      throws ServletException, IOException {
    String correlationId = request.getHeader(CORRELATION_HEADER);
    if (correlationId == null || correlationId.isBlank()) {
      correlationId = UUID.randomUUID().toString();
    }
    MDC.put("correlationId", correlationId);
    response.setHeader(CORRELATION_HEADER, correlationId);

    String tenantId = request.getHeader(TENANT_HEADER);
    if (tenantId != null && !tenantId.isBlank()) {
      MDC.put("tenantId", tenantId);
    }

    try {
      filterChain.doFilter(request, response);
    } finally {
      MDC.remove("correlationId");
      MDC.remove("tenantId");
      MDC.remove("eventId");
    }
  }
}
