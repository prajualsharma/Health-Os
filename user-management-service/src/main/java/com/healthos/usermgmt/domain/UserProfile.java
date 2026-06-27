package com.healthos.usermgmt.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "user_profiles")
public class UserProfile {
  @Id
  @Column(name = "user_id")
  private UUID userId;

  @OneToOne(optional = false)
  @jakarta.persistence.MapsId
  @jakarta.persistence.JoinColumn(name = "user_id")
  private User user;

  @Column(name = "height_cm")
  private Integer height;

  @Column(name = "weight_kg")
  private Integer weight;

  @Column(length = 16)
  private String gender;

  @Column(name = "date_of_birth")
  private LocalDate dateOfBirth;

  @Column(length = 128)
  private String goal;

  @Column(name = "target_weight_kg")
  private Integer targetWeight;

  @Column(name = "activity_level", length = 32)
  private String activityLevel;

  @Column(name = "diet_type", length = 32)
  private String dietType;

  @Column(name = "allergies", columnDefinition = "text")
  private String allergies;

  @Column(name = "calorie_target")
  private Integer calorieTarget;

  @Column(name = "protein_target_g")
  private Integer proteinTarget;

  @Column(name = "carb_target_g")
  private Integer carbTarget;

  @Column(name = "fat_target_g")
  private Integer fatTarget;

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();
}

