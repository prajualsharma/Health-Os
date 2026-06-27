enum MemberStatus { active, expiring, expired, frozen }

enum PaymentStatus { paid, pending, overdue }

enum StaffRole { manager, trainer, receptionist }

extension StaffRoleLabel on StaffRole {
  String get label => switch (this) {
        StaffRole.manager => 'Gym Manager',
        StaffRole.trainer => 'Trainer',
        StaffRole.receptionist => 'Receptionist',
      };
}

class Gym {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final int memberCount;
  final int staffCount;
  final double monthlyRevenue;
  final int todayAttendance;

  const Gym({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.memberCount,
    required this.staffCount,
    required this.monthlyRevenue,
    required this.todayAttendance,
  });
}

class Member {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gymId;
  final String planName;
  final MemberStatus status;
  final DateTime joinedOn;
  final DateTime expiresOn;
  final double pendingAmount;

  const Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gymId,
    required this.planName,
    required this.status,
    required this.joinedOn,
    required this.expiresOn,
    this.pendingAmount = 0,
  });
}

class StaffMember {
  final String id;
  final String name;
  final String phone;
  final String email;
  final StaffRole role;
  final String gymId;
  final DateTime joinedOn;

  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.gymId,
    required this.joinedOn,
  });
}

class MembershipPlan {
  final String id;
  final String name;
  final int durationMonths;
  final double price;
  final List<String> features;
  final int activeMembers;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.price,
    required this.features,
    required this.activeMembers,
  });
}

class Payment {
  final String id;
  final String memberName;
  final String gymId;
  final double amount;
  final PaymentStatus status;
  final DateTime date;
  final String method;
  final String planName;

  const Payment({
    required this.id,
    required this.memberName,
    required this.gymId,
    required this.amount,
    required this.status,
    required this.date,
    required this.method,
    required this.planName,
  });
}

class AttendanceRecord {
  final String memberName;
  final String gymId;
  final DateTime checkIn;
  final DateTime? checkOut;

  const AttendanceRecord({
    required this.memberName,
    required this.gymId,
    required this.checkIn,
    this.checkOut,
  });
}

class MonthPoint {
  final String month;
  final double value;
  const MonthPoint(this.month, this.value);
}
