package com.healthos.usermgmt.adapters.inbound.rest.dto;

import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import lombok.Data;

public class MeDtos {
  @Data
  public static class ProfileResponse {
    private String name;
    private String email;
    private Integer height;
    private Integer weight;
    private Integer targetWeight;
    private String gender;
    private LocalDate dateOfBirth;
    private String goal;
    private String activityLevel;
    private String dietType;
    private List<String> allergies;
    private Integer calorieTarget;
    private Integer proteinTarget;
    private Integer carbTarget;
    private Integer fatTarget;
  }

  @Data
  public static class UpdateProfileRequest {
    private Integer height;
    private Integer weight;
    @Size(max = 16) private String gender;
    private LocalDate dateOfBirth;
    @Size(max = 128) private String goal;
  }
}

