package com.healthos.usermgmt.application;

import com.healthos.usermgmt.adapters.outbound.persistence.RoleRepository;
import com.healthos.usermgmt.consumer.adapters.outbound.persistence.ConsumerAccountRepository;
import com.healthos.usermgmt.consumer.domain.ConsumerAccount;
import com.healthos.usermgmt.domain.Role;
import com.healthos.usermgmt.domain.UserStatus;
import com.healthos.usermgmt.shared.domain.AccountType;
import com.healthos.usermgmt.staff.adapters.outbound.persistence.StaffAccountRepository;
import com.healthos.usermgmt.staff.domain.StaffAccount;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AccountAdminService {
  private final ConsumerAccountRepository consumerAccountRepository;
  private final StaffAccountRepository staffAccountRepository;
  private final RoleRepository roleRepository;

  public List<AdminAccountView> listAccounts() {
    var accounts = new ArrayList<AdminAccountView>();
    consumerAccountRepository.findAll().stream().map(this::toView).forEach(accounts::add);
    staffAccountRepository.findAll().stream().map(this::toView).forEach(accounts::add);
    accounts.sort(Comparator.comparing(AdminAccountView::createdAt).reversed());
    return accounts;
  }

  public AdminAccountView getAccount(UUID id) {
    return consumerAccountRepository
        .findById(id)
        .map(this::toView)
        .orElseGet(
            () ->
                staffAccountRepository
                    .findById(id)
                    .map(this::toView)
                    .orElseThrow(() -> new IllegalArgumentException("Account not found")));
  }

  @Transactional
  public AdminAccountView updateStatus(UUID id, UserStatus status) {
    var consumer = consumerAccountRepository.findById(id);
    if (consumer.isPresent()) {
      var account = consumer.get();
      account.setStatus(status);
      account.setUpdatedAt(Instant.now());
      return toView(consumerAccountRepository.save(account));
    }
    var staff =
        staffAccountRepository
            .findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Account not found"));
    staff.setStatus(status);
    staff.setUpdatedAt(Instant.now());
    return toView(staffAccountRepository.save(staff));
  }

  @Transactional
  public AdminAccountView setStaffRoles(UUID id, List<String> roleNames) {
    var staff =
        staffAccountRepository
            .findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Staff account not found"));
    var roles = new HashSet<Role>();
    for (var name : roleNames) {
      roles.add(
          roleRepository
              .findByName(name)
              .orElseThrow(() -> new IllegalArgumentException("Role not found: " + name)));
    }
    staff.setRoles(roles);
    staff.setUpdatedAt(Instant.now());
    return toView(staffAccountRepository.save(staff));
  }

  private AdminAccountView toView(ConsumerAccount account) {
    return new AdminAccountView(
        account.getId(),
        AccountType.CONSUMER,
        account.getFirstName(),
        account.getLastName(),
        account.getEmail(),
        account.getPhone(),
        account.getStatus(),
        account.getCreatedAt(),
        account.getUpdatedAt(),
        Set.of());
  }

  private AdminAccountView toView(StaffAccount account) {
    var roles =
        account.getRoles() == null
            ? Set.<String>of()
            : account.getRoles().stream().map(Role::getName).collect(Collectors.toUnmodifiableSet());
    return new AdminAccountView(
        account.getId(),
        AccountType.STAFF,
        account.getFirstName(),
        account.getLastName(),
        account.getEmail(),
        account.getPhone(),
        account.getStatus(),
        account.getCreatedAt(),
        account.getUpdatedAt(),
        roles);
  }

  public record AdminAccountView(
      UUID id,
      AccountType accountType,
      String firstName,
      String lastName,
      String email,
      String phone,
      UserStatus status,
      Instant createdAt,
      Instant updatedAt,
      Set<String> roles) {}
}
