package com.healthos.usermgmt.adapters.inbound.rest.dto;

import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.Data;

public class MeDtos {
  @Data
  public static class ProfileResponse {
    private Integer height;
    private Integer weight;
    private String gender;
    private LocalDate dateOfBirth;
    private String goal;
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

