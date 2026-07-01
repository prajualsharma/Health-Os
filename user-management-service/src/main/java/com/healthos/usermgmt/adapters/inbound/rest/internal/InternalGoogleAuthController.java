package com.healthos.usermgmt.adapters.inbound.rest.internal;

import com.healthos.usermgmt.application.AuthContracts.OAuthResolveResult;
import com.healthos.usermgmt.consumer.application.ConsumerAuthService;
import com.healthos.usermgmt.domain.AuthMethodType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/internal/auth")
@RequiredArgsConstructor
public class InternalGoogleAuthController {
  private final ConsumerAuthService consumerAuthService;

  @PostMapping("/oauth/resolve")
  public OAuthResolveResult resolveOAuth(@RequestBody ResolveOAuthRequest req) {
    return consumerAuthService.resolveOAuth(req.getMethod(), req.getSubject(), req.getEmail());
  }

  @Data
  public static class ResolveOAuthRequest {
    @NotNull private AuthMethodType method;
    @NotBlank private String subject;
    @Email private String email;
  }
}
