package com.healthos.usermgmt.adapters.inbound.rest.internal;

import com.healthos.usermgmt.application.AuthService;
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
  private final AuthService authService;

  /**
   * Resolves an OAuth identity to an existing account (link-only). Never creates a new account:
   * signup is phone-first. Returns {@code NO_ACCOUNT} when there is no match.
   */
  @PostMapping("/oauth/resolve")
  public AuthService.OAuthResolveResult resolveOAuth(@RequestBody ResolveOAuthRequest req) {
    return authService.resolveOAuth(req.getMethod(), req.getSubject(), req.getEmail());
  }

  @Data
  public static class ResolveOAuthRequest {
    @NotNull private AuthMethodType method;
    @NotBlank private String subject;
    @Email private String email;
  }
}

