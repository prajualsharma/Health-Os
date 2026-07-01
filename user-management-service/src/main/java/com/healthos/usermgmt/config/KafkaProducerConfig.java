package com.healthos.usermgmt.config;

import com.healthos.usermgmt.adapters.outbound.notification.NotificationKafkaProperties;
import java.util.HashMap;
import java.util.Map;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
@EnableConfigurationProperties(NotificationKafkaProperties.class)
public class KafkaProducerConfig {

  @Bean
  @ConditionalOnProperty(prefix = "healthos.kafka", name = "enabled", havingValue = "true")
  ProducerFactory<String, String> notificationProducerFactory(NotificationKafkaProperties props) {
    Map<String, Object> config = new HashMap<>();
    config.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, props.getBootstrapServers());
    config.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    config.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
    config.put(ProducerConfig.ACKS_CONFIG, "all");
    return new DefaultKafkaProducerFactory<>(config);
  }

  @Bean
  @ConditionalOnProperty(prefix = "healthos.kafka", name = "enabled", havingValue = "true")
  KafkaTemplate<String, String> notificationKafkaTemplate(ProducerFactory<String, String> factory) {
    return new KafkaTemplate<>(factory);
  }
}
