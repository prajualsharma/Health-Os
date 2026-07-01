package com.healthos.usermgmt.staff.domain;

import com.healthos.usermgmt.domain.AuthMethodType;
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
@Table(schema = "staff", name = "auth_methods")
public class StaffAuthMethod {
  @Id private UUID id;

  @ManyToOne(fetch = FetchType.LAZY, optional = false)
  @JoinColumn(name = "account_id", nullable = false)
  private StaffAccount account;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, length = 16)
  private AuthMethodType method;

  @Column(nullable = false, length = 255)
  private String identifier;

  @Column(nullable = false)
  private boolean verified;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();
}
