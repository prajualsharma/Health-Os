package com.healthos.usermgmt.consumer.adapters.inbound.rest;

import com.healthos.usermgmt.consumer.application.OnboardingProgressService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth/nutrikit/onboarding")
@RequiredArgsConstructor
public class NutrikitOnboardingController {
  private final OnboardingProgressService progressService;

  @PutMapping("/progress")
  public ProgressResponse updateProgress(@Valid @RequestBody UpdateProgressRequest req) {
    var session =
        progressService.updateProgress(
            req.getRegistrationToken(), req.getStep(), req.getFirstName(), req.getEmail());
    var view = progressService.getProgress(req.getRegistrationToken());
    var res = new ProgressResponse();
    res.setCurrentStep(view.currentStep());
    res.setRoutePath(view.routePath());
    res.setStepLabel(view.stepLabel());
    res.setPhone(session.getPhone());
    return res;
  }

  @GetMapping("/progress")
  public ProgressResponse getProgress(@RequestParam @NotBlank String registrationToken) {
    var view = progressService.getProgress(registrationToken);
    var res = new ProgressResponse();
    res.setCurrentStep(view.currentStep());
    res.setRoutePath(view.routePath());
    res.setStepLabel(view.stepLabel());
    return res;
  }

  @Data
  public static class UpdateProgressRequest {
    @NotBlank private String registrationToken;
    @NotBlank private String step;
    private String firstName;
    private String email;
  }

  @Data
  public static class ProgressResponse {
    private String currentStep;
    private String routePath;
    private String stepLabel;
    private String phone;
  }
}
