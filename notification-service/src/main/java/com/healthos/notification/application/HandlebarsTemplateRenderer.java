package com.healthos.notification.application;

import com.github.jknack.handlebars.Handlebars;
import com.github.jknack.handlebars.Template;
import java.io.IOException;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class HandlebarsTemplateRenderer {

  private final Handlebars handlebars = new Handlebars();

  public String render(String templateContent, Map<String, Object> variables) {
    if (templateContent == null) {
      return "";
    }
    try {
      Template template = handlebars.compileInline(templateContent);
      return template.apply(variables != null ? variables : Map.of());
    } catch (IOException e) {
      throw new IllegalArgumentException("Template rendering failed: " + e.getMessage(), e);
    }
  }
}
