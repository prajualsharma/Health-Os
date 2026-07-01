package com.healthos.usermgmt.adapters.inbound.rest.internal;

import com.healthos.usermgmt.consumer.application.ConsumerAuthService;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/tokens")
@RequiredArgsConstructor
public class InternalTokensController {
  private final ConsumerAuthService consumerAuthService;

  @PostMapping("/refresh")
  public void storeRefresh(@RequestBody StoreRefreshTokenRequest req) {
    consumerAuthService.storeRefreshToken(req.getUserId(), req.getRefreshToken());
  }

  @Data
  public static class StoreRefreshTokenRequest {
    @NotNull private UUID userId;
    @NotBlank private String refreshToken;
  }
}
