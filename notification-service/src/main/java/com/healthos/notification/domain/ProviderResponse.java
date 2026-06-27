package com.healthos.notification.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProviderResponse {
  private boolean success;
  private String requestPayload;
  private String responsePayload;
  private String errorMessage;
}
