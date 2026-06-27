package com.healthos.kitchen.adapters.outbound.usermgmt;

import com.healthos.kitchen.config.HealthOsProperties;
import java.util.Map;
import java.util.UUID;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Calls user-management's internal scoped-membership endpoint so a corporate user (or designated
 * staff user) is granted access to a newly created kitchen. Best-effort: failures are logged and
 * do not block kitchen creation, so the service stays usable when user-management is unavailable.
 */
@Slf4j
@Component
public class UserManagementClient {
  private final RestClient restClient;
  private final String baseUrl;

  public UserManagementClient(HealthOsProperties props, RestClient.Builder builder) {
    this.baseUrl = props.getDownstream().getUserManagement().getBaseUrl();
    this.restClient = builder.build();
  }

  /** Grant a KITCHEN_STAFF membership at the kitchen location (scope_id = kitchenId). */
  public void grantKitchenStaff(UUID userId, UUID kitchenId) {
    grant(userId, "LOCATION", kitchenId, "KITCHEN_STAFF");
  }

  /** Grant a CORPORATE membership at the organization scope (scope_id = orgId). */
  public void grantCorporate(UUID userId, UUID orgId) {
    grant(userId, "ORGANIZATION", orgId, "CORPORATE");
  }

  private void grant(UUID userId, String scopeType, UUID scopeId, String roleName) {
    try {
      restClient
          .post()
          .uri(baseUrl + "/internal/scoped-memberships")
          .body(
              Map.of(
                  "userId", userId.toString(),
                  "portalType", "KITCHEN",
                  "scopeType", scopeType,
                  "scopeId", scopeId.toString(),
                  "roleName", roleName))
          .retrieve()
          .toBodilessEntity();
      log.info("Granted {} to user {} at {} {}", roleName, userId, scopeType, scopeId);
    } catch (Exception e) {
      log.warn(
          "Failed to grant {} to user {} ({} {}): {}",
          roleName,
          userId,
          scopeType,
          scopeId,
          e.getMessage());
    }
  }
}
