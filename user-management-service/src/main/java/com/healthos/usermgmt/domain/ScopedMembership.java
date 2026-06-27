package com.healthos.usermgmt.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "scoped_memberships")
public class ScopedMembership {
  @Id
  private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Enumerated(EnumType.STRING)
  @Column(name = "portal_type", nullable = false, length = 32)
  private PortalType portalType;

  @Enumerated(EnumType.STRING)
  @Column(name = "scope_type", nullable = false, length = 32)
  private ScopeType scopeType;

  @Column(name = "scope_id", nullable = false)
  private UUID scopeId;

  @Column(name = "role_name", nullable = false, length = 64)
  private String roleName;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 32)
  private MembershipStatus status = MembershipStatus.ACTIVE;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();
}
