package com.healthos.usermgmt.adapters.inbound.rest.internal;

import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.application.AuthService;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/tokens")
@RequiredArgsConstructor
public class InternalTokensController {
  private final UserRepository userRepository;
  private final AuthService authService;

  @PostMapping("/refresh")
  public void storeRefresh(@RequestBody StoreRefreshTokenRequest req) {
    var user = userRepository.findById(req.getUserId()).orElseThrow(() -> new IllegalArgumentException("User not found"));
    authService.storeRefreshToken(user, req.getRefreshToken(), Instant.now());
  }

  @Data
  public static class StoreRefreshTokenRequest {
    @NotNull private UUID userId;
    @NotBlank private String refreshToken;
    private Instant expiresAt;
  }
}

