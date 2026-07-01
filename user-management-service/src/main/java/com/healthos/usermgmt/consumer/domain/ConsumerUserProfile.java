package com.healthos.usermgmt.consumer.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
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
@Table(schema = "consumer", name = "user_profiles")
public class ConsumerUserProfile {
  @Id
  @Column(name = "account_id")
  private UUID accountId;

  @OneToOne(optional = false)
  @MapsId
  @JoinColumn(name = "account_id")
  private ConsumerAccount account;

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

  @Column(columnDefinition = "text")
  private String allergies;

  @Column(name = "calorie_target")
  private Integer calorieTarget;

  @Column(name = "protein_target_g")
  private Integer proteinTarget;

  @Column(name = "carb_target_g")
  private Integer carbTarget;

  @Column(name = "fat_target_g")
  private Integer fatTarget;

  @Column(columnDefinition = "text")
  private String goals;

  @Column(name = "medical_conditions", columnDefinition = "text")
  private String medicalConditions;

  @Column(length = 128)
  private String city;

  @Column(name = "goal_pace", length = 32)
  private String goalPace;

  @Column(name = "preferred_height_unit", length = 8)
  private String preferredHeightUnit = "cm";

  @Column(name = "preferred_weight_unit", length = 8)
  private String preferredWeightUnit = "kg";

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt = Instant.now();
}
