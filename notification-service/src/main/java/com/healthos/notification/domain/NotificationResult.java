package com.healthos.notification.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResult {
  private NotificationStatus status;
  private String provider;
  private String renderedMessage;
  private String requestPayload;
  private String responsePayload;
  private String errorMessage;
  private int retryCount;

  public static NotificationResult sent(String provider, String rendered, String req, String res) {
    return NotificationResult.builder()
        .status(NotificationStatus.SENT)
        .provider(provider)
        .renderedMessage(rendered)
        .requestPayload(req)
        .responsePayload(res)
        .build();
  }

  public static NotificationResult failed(String provider, String error, String req) {
    return NotificationResult.builder()
        .status(NotificationStatus.FAILED)
        .provider(provider)
        .errorMessage(error)
        .requestPayload(req)
        .build();
  }
}
