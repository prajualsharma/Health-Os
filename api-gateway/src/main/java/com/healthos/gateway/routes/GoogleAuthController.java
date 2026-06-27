package com.healthos.gateway.routes;

import com.healthos.gateway.config.GatewayProperties;
import com.healthos.gateway.security.JwtIssuer;
import java.time.Instant;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class GoogleAuthController {
  private final GatewayProperties props;
  private final JwtIssuer jwtIssuer;
  private final WebClient.Builder webClientBuilder;

  @PostMapping(
      value = {"/google", "/oauth/google"},
      consumes = MediaType.APPLICATION_JSON_VALUE)
  public Mono<ResponseEntity<Object>> google(@RequestBody GoogleTokenRequest req) {
    if (req == null || req.getIdToken() == null || req.getIdToken().isBlank()) {
      return Mono.error(new IllegalArgumentException("idToken is required"));
    }

    var tokenInfoClient = webClientBuilder.build();
    var userMgmtClient =
        webClientBuilder.baseUrl(props.getDownstream().getUserManagement().getBaseUrl()).build();

    return tokenInfoClient
        .get()
        .uri(
            uriBuilder ->
                uriBuilder
                    .scheme("https")
                    .host("oauth2.googleapis.com")
                    .path("/tokeninfo")
                    .queryParam("id_token", req.getIdToken())
                    .build())
        .retrieve()
        .bodyToMono(GoogleTokenInfo.class)
        .flatMap(
            info -> {
              if (info == null || info.getSub() == null || info.getSub().isBlank()) {
                return Mono.error(new IllegalArgumentException("Invalid Google token"));
              }
              var expectedAud = props.getSecurity().getGoogle().getClientId();
              if (expectedAud != null && !expectedAud.isBlank() && !expectedAud.equals(info.getAud())) {
                return Mono.error(new IllegalArgumentException("Google token aud mismatch"));
              }

              var resolveReq = new ResolveOAuthRequest();
              resolveReq.setMethod("GOOGLE");
              resolveReq.setSubject(info.getSub());
              resolveReq.setEmail(info.getEmail());

              return userMgmtClient
                  .post()
                  .uri("/internal/auth/oauth/resolve")
                  .contentType(MediaType.APPLICATION_JSON)
                  .bodyValue(resolveReq)
                  .retrieve()
                  .bodyToMono(OAuthResolveResult.class);
            })
        .flatMap(
            resolved -> {
              if ("NO_ACCOUNT".equals(resolved.getStatus())) {
                return Mono.just(
                    ResponseEntity.status(HttpStatus.CONFLICT)
                        .body(
                            Map.of(
                                "code", "no_account",
                                "message", "Sign up with your phone number first")));
              }

              var now = Instant.now();
              var roles =
                  resolved.getRoles() == null ? Set.<String>of() : Set.copyOf(resolved.getRoles());
              var access =
                  jwtIssuer.issueAccessToken(
                      resolved.getUserId().toString(), resolved.getEmail(), roles, now);
              var refresh = UUID.randomUUID() + "." + UUID.randomUUID();

              var store = new StoreRefreshTokenRequest();
              store.setUserId(resolved.getUserId());
              store.setRefreshToken(refresh);

              return userMgmtClient
                  .post()
                  .uri("/internal/tokens/refresh")
                  .contentType(MediaType.APPLICATION_JSON)
                  .bodyValue(store)
                  .retrieve()
                  .bodyToMono(Void.class)
                  .then(
                      Mono.fromSupplier(
                          () -> {
                            var res = new TokenResponse();
                            res.setAccessToken(access);
                            res.setRefreshToken(refresh);
                            res.setTokenType("Bearer");
                            return ResponseEntity.ok((Object) res);
                          }));
            });
  }

  @Data
  public static class GoogleTokenRequest {
    private String idToken;
  }

  @Data
  public static class TokenResponse {
    private String tokenType;
    private String accessToken;
    private String refreshToken;
  }

  @Data
  public static class GoogleTokenInfo {
    private String aud;
    private String sub;
    private String email;
    private String given_name;
    private String family_name;
  }

  @Data
  public static class ResolveOAuthRequest {
    private String method;
    private String subject;
    private String email;
  }

  @Data
  public static class OAuthResolveResult {
    private String status;
    private UUID userId;
    private String email;
    private java.util.List<String> roles;
  }

  @Data
  public static class StoreRefreshTokenRequest {
    private UUID userId;
    private String refreshToken;
  }
}
