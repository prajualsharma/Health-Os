package com.healthos.usermgmt.integration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerAccountRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers(disabledWithoutDocker = true)
class PhoneRegistrationIT {

  @Container
  static PostgreSQLContainer<?> postgres =
      new PostgreSQLContainer<>(DockerImageName.parse("postgres:16"));

  @Container
  static GenericContainer<?> redis =
      new GenericContainer<>(DockerImageName.parse("redis:7-alpine")).withExposedPorts(6379);

  @DynamicPropertySource
  static void props(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
    registry.add("spring.data.redis.host", redis::getHost);
    registry.add("spring.data.redis.port", () -> redis.getMappedPort(6379));
  }

  @Autowired private MockMvc mockMvc;
  @Autowired private ObjectMapper objectMapper;
  @Autowired private ConsumerAccountRepository consumerAccountRepository;

  @Test
  void phoneRegistrationFlow_createsUserAndProfile() throws Exception {
    var phone = "+919876543210";

    mockMvc
        .perform(
            post("/auth/nutrikit/phone/initiate")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\"}"))
        .andExpect(status().isOk());

    var verifyRes =
        mockMvc
            .perform(
                post("/auth/nutrikit/phone/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("{\"phone\":\"" + phone + "\",\"otp\":\"123456\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.newUser").value(true))
            .andExpect(jsonPath("$.registrationToken").isNotEmpty())
            .andReturn();

    var verifyJson = objectMapper.readTree(verifyRes.getResponse().getContentAsString());
    var registrationToken = verifyJson.get("registrationToken").asText();

    var registerRes =
        mockMvc
            .perform(
                post("/auth/nutrikit/register-phone")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(
                        """
                    {
                      "phone":"%s",
                      "registrationToken":"%s",
                      "name":"ayushi naidu",
                      "goal":"build_muscle",
                      "goals":["build_muscle","diet_plan"],
                      "gender":"Female",
                      "age":26,
                      "height":173,
                      "weight":65,
                      "targetWeight":70,
                      "activity":"moderately_active",
                      "diet":"No Pref",
                      "allergies":[],
                      "medicalConditions":["None"],
                      "city":"Bengaluru",
                      "goalPace":"moderate",
                      "heightUnit":"cm",
                      "weightUnit":"kg",
                      "email":"test.user@example.com"
                    }
                    """
                            .formatted(phone, registrationToken)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.accessToken").isNotEmpty())
            .andExpect(jsonPath("$.userId").isNotEmpty())
            .andExpect(jsonPath("$.targets.calories").isNumber())
            .andExpect(jsonPath("$.targets.timelineWeeks").isNumber())
            .andReturn();

    var registerJson = objectMapper.readTree(registerRes.getResponse().getContentAsString());
    var accessToken = registerJson.get("accessToken").asText();

    mockMvc
        .perform(get("/me/profile").header("Authorization", "Bearer " + accessToken))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.name").value("Ayushi Naidu"))
        .andExpect(jsonPath("$.email").value("test.user@example.com"))
        .andExpect(jsonPath("$.calorieTarget").isNumber())
        .andExpect(jsonPath("$.proteinTarget").isNumber());

    var user = consumerAccountRepository.findByPhone(phone);
    assertThat(user).isPresent();
    assertThat(user.get().getFirstName()).isEqualTo("Ayushi");
    assertThat(user.get().getLastName()).isEqualTo("Naidu");

    mockMvc
        .perform(
            post("/auth/phone/verify")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\",\"otp\":\"123456\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.newUser").value(false))
        .andExpect(jsonPath("$.accessToken").isNotEmpty());
  }
}
