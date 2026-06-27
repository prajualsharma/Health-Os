package com.healthos.kitchen.adapters.inbound.rest;

import com.healthos.kitchen.adapters.inbound.rest.dto.KitchenDtos;
import com.healthos.kitchen.adapters.inbound.rest.security.AuthPrincipal;
import com.healthos.kitchen.application.KitchenService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/kitchen/kitchens")
@RequiredArgsConstructor
public class KitchenController {
  private final KitchenService kitchenService;

  @GetMapping
  public List<KitchenDtos.KitchenResponse> list(
      @AuthenticationPrincipal AuthPrincipal principal,
      @RequestParam(value = "orgId", required = false) UUID orgId) {
    var effectiveOrg = orgId != null ? orgId : scopeOrg(principal);
    return kitchenService.list(effectiveOrg).stream().map(KitchenDtos.KitchenResponse::from).toList();
  }

  @GetMapping("/{id}")
  public KitchenDtos.KitchenResponse get(@PathVariable UUID id) {
    return KitchenDtos.KitchenResponse.from(kitchenService.get(id));
  }

  @PostMapping
  public KitchenDtos.KitchenResponse create(
      @AuthenticationPrincipal AuthPrincipal principal,
      @Valid @RequestBody KitchenDtos.CreateKitchenRequest req) {
    var orgId = req.orgId() != null ? req.orgId() : scopeOrg(principal);
    if (orgId == null) {
      orgId = UUID.randomUUID();
    }
    var kitchen =
        kitchenService.create(orgId, req.name(), req.address(), req.city(), req.staffUserId());
    return KitchenDtos.KitchenResponse.from(kitchen);
  }

  /** Organization scope of a corporate caller, if their active scope is an organization. */
  private static UUID scopeOrg(AuthPrincipal principal) {
    if (principal != null && "ORGANIZATION".equals(principal.scopeType())) {
      return principal.activeScopeId();
    }
    return null;
  }
}
