package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.adapters.outbound.persistence.UserRepository;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.User;
import com.healthos.usermgmt.domain.UserStatus;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserAdminService {
  private final UserRepository userRepository;
  private final RoleRepository roleRepository;

  public List<User> listUsers() {
    return userRepository.findAll();
  }

  public User getUser(UUID id) {
    return userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));
  }

  @Transactional
  public User updateStatus(UUID id, UserStatus status) {
    var user = getUser(id);
    user.setStatus(status);
    user.setUpdatedAt(Instant.now());
    return userRepository.save(user);
  }

  @Transactional
  public User setRoles(UUID id, List<String> roleNames) {
    var user = getUser(id);
    var roles = new HashSet<Role>();
    for (var name : roleNames) {
      roles.add(roleRepository.findByName(name).orElseThrow(() -> new IllegalArgumentException("Role not found: " + name)));
    }
    user.setRoles(roles);
    user.setUpdatedAt(Instant.now());
    return userRepository.save(user);
  }
}

