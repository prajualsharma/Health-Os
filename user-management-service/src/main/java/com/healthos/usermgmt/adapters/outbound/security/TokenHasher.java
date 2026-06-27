package com.healthos.usermgmt.adapters.outbound.security;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import org.springframework.stereotype.Component;

@Component
public class TokenHasher {
  public String sha256Hex(String value) {
    try {
      var digest = MessageDigest.getInstance("SHA-256");
      var bytes = digest.digest(value.getBytes(StandardCharsets.UTF_8));
      var sb = new StringBuilder(bytes.length * 2);
      for (byte b : bytes) {
        sb.append(String.format("%02x", b));
      }
      return sb.toString();
    } catch (NoSuchAlgorithmException e) {
      throw new IllegalStateException("SHA-256 not available", e);
    }
  }
}

