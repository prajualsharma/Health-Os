package com.healthos.notification.application;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Map;
import org.junit.jupiter.api.Test;

class HandlebarsTemplateRendererTest {

  private final HandlebarsTemplateRenderer renderer = new HandlebarsTemplateRenderer();

  @Test
  void rendersVariables() {
    String result =
        renderer.render(
            "Hello {{firstName}}, expires {{expiryDate}} at {{gymName}}",
            Map.of("firstName", "John", "expiryDate", "2026-06-15", "gymName", "FitGym"));
    assertThat(result).isEqualTo("Hello John, expires 2026-06-15 at FitGym");
  }
}
