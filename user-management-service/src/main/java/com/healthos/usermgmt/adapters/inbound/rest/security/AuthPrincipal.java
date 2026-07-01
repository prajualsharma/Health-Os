package com.healthos.usermgmt.adapters.inbound.rest.security;

import com.healthos.usermgmt.domain.ActiveScope;
import com.healthos.usermgmt.domain.MembershipClaim;
import com.healthos.usermgmt.shared.domain.AccountType;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public record AuthPrincipal(
    UUID userId,
    String email,
    Set<String> roles,
    List<MembershipClaim> memberships,
    ActiveScope activeScope,
    AccountType accountType) {

  public AuthPrincipal(UUID userId, String email, Set<String> roles) {
    this(userId, email, roles, List.of(), null, AccountType.CONSUMER);
  }

  public boolean isStaff() {
    return accountType == AccountType.STAFF;
  }

  public boolean isConsumer() {
    return accountType == AccountType.CONSUMER;
  }
}
