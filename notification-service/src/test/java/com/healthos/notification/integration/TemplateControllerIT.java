package com.healthos.notification.integration;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.healthos.notification.support.JwtTestUtil;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest(
    properties =
        "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration")
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers(disabledWithoutDocker = true)
class TemplateControllerIT {

  @Container
  static MongoDBContainer mongo = new MongoDBContainer("mongo:7");

  @DynamicPropertySource
  static void mongoProps(DynamicPropertyRegistry registry) {
    registry.add("spring.data.mongodb.uri", mongo::getReplicaSetUrl);
  }

  @Autowired private MockMvc mockMvc;

  @Test
  void createsAndListsTemplate() throws Exception {
    String token =
        JwtTestUtil.token(
            UUID.randomUUID().toString(), "admin@healthos.com", Set.of("NOTIFICATION_ADMIN"));

    mockMvc
        .perform(
            post("/templates")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {
                      "tenantId": "gym001",
                      "topic": "MEMBERSHIP_EXPIRED",
                      "channel": "EMAIL",
                      "subject": "Hi {{firstName}}",
                      "body": "Expires {{expiryDate}}",
                      "active": true
                    }
                    """))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.topic").value("MEMBERSHIP_EXPIRED"));

    mockMvc
        .perform(get("/templates").header("Authorization", "Bearer " + token))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].channel").value("EMAIL"));
  }
}
