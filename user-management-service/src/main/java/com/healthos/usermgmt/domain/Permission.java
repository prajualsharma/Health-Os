package com.healthos.usermgmt.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "permissions")
public class Permission {
  @Id
  private UUID id;

  @Column(nullable = false, unique = true, length = 128)
  private String name;

  @Column(length = 255)
  private String description;

  @Column(name = "created_at", nullable = false)
  private Instant createdAt = Instant.now();

  @ManyToMany(mappedBy = "permissions")
  private Set<Role> roles;
}

