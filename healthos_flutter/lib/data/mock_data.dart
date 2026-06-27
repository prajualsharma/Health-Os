import 'models.dart';

final mockGyms = <Gym>[
  const Gym(
    id: 'gym-1',
    name: 'HealthOS Fitness — Koramangala',
    city: 'Bengaluru',
    address: '80 Feet Rd, Koramangala 4th Block',
    phone: '+91 98450 11223',
    memberCount: 412,
    staffCount: 9,
    monthlyRevenue: 612000,
    todayAttendance: 148,
  ),
  const Gym(
    id: 'gym-2',
    name: 'HealthOS Fitness — Indiranagar',
    city: 'Bengaluru',
    address: '100 Feet Rd, Indiranagar',
    phone: '+91 98450 44556',
    memberCount: 298,
    staffCount: 7,
    monthlyRevenue: 448000,
    todayAttendance: 96,
  ),
  const Gym(
    id: 'gym-3',
    name: 'HealthOS Fitness — HSR Layout',
    city: 'Bengaluru',
    address: '27th Main, HSR Sector 1',
    phone: '+91 98450 77889',
    memberCount: 186,
    staffCount: 5,
    monthlyRevenue: 274000,
    todayAttendance: 61,
  ),
];

const _firstNames = [
  'Aarav', 'Vivaan', 'Aditya', 'Arjun', 'Sai', 'Reyansh', 'Krishna', 'Ishaan',
  'Ananya', 'Diya', 'Aadhya', 'Saanvi', 'Myra', 'Aanya', 'Pari', 'Anika',
  'Rahul', 'Sneha', 'Kavya', 'Rohit', 'Neha', 'Amit', 'Pooja', 'Karan', 'Meera',
];
const _lastNames = [
  'Sharma', 'Verma', 'Reddy', 'Nair', 'Patel', 'Gupta', 'Iyer', 'Khan',
  'Singh', 'Das', 'Mehta', 'Joshi', 'Kulkarni', 'Rao', 'Choudhary',
];

final mockPlans = <MembershipPlan>[
  const MembershipPlan(
    id: 'plan-1',
    name: 'Monthly Basic',
    durationMonths: 1,
    price: 1499,
    features: ['Gym floor access', 'Locker', '1 trainer intro session'],
    activeMembers: 214,
  ),
  const MembershipPlan(
    id: 'plan-2',
    name: 'Quarterly Plus',
    durationMonths: 3,
    price: 3999,
    features: ['Gym + cardio zone', 'Locker', 'Diet consult', '2 PT sessions'],
    activeMembers: 318,
  ),
  const MembershipPlan(
    id: 'plan-3',
    name: 'Half-Yearly Pro',
    durationMonths: 6,
    price: 6999,
    features: ['All access', 'Group classes', 'Monthly body scan', '4 PT sessions'],
    activeMembers: 196,
  ),
  const MembershipPlan(
    id: 'plan-4',
    name: 'Annual Elite',
    durationMonths: 12,
    price: 11999,
    features: ['All access', 'Unlimited classes', 'Personal diet plan', '12 PT sessions', 'Guest passes'],
    activeMembers: 168,
  ),
];

final mockMembers = List<Member>.generate(54, (i) {
  final name = '${_firstNames[i % _firstNames.length]} ${_lastNames[(i * 3) % _lastNames.length]}';
  final gymId = mockGyms[i % 3].id;
  final plan = mockPlans[i % 4];
  final joined = DateTime(2025, 1 + (i % 12), 1 + (i % 27));
  final expires = DateTime(2026, 5 + (i % 4), 1 + ((i * 2) % 27));
  final status = switch (i % 9) {
    0 || 1 => MemberStatus.expiring,
    2 => MemberStatus.expired,
    3 => MemberStatus.frozen,
    _ => MemberStatus.active,
  };
  return Member(
    id: 'M${1000 + i}',
    name: name,
    phone: '+91 9${(7000000000 + i * 1237) % 1000000000}'.padRight(13, '0'),
    email: '${name.toLowerCase().replaceAll(' ', '.')}@example.com',
    gymId: gymId,
    planName: plan.name,
    status: status,
    joinedOn: joined,
    expiresOn: expires,
    pendingAmount: i % 7 == 0 ? 1499 : 0,
  );
});

final mockStaff = <StaffMember>[
  StaffMember(id: 'S01', name: 'Priya Sharma', phone: '+91 98111 22334', email: 'priya@healthos.fit', role: StaffRole.manager, gymId: 'gym-1', joinedOn: DateTime(2024, 3, 12)),
  StaffMember(id: 'S02', name: 'Vikram Singh', phone: '+91 98222 33445', email: 'vikram@healthos.fit', role: StaffRole.trainer, gymId: 'gym-1', joinedOn: DateTime(2024, 6, 1)),
  StaffMember(id: 'S03', name: 'Anjali Verma', phone: '+91 98333 44556', email: 'anjali@healthos.fit', role: StaffRole.receptionist, gymId: 'gym-1', joinedOn: DateTime(2024, 8, 20)),
  StaffMember(id: 'S04', name: 'Rakesh Kumar', phone: '+91 98444 55667', email: 'rakesh@healthos.fit', role: StaffRole.trainer, gymId: 'gym-1', joinedOn: DateTime(2025, 1, 5)),
  StaffMember(id: 'S05', name: 'Deepa Nair', phone: '+91 98555 66778', email: 'deepa@healthos.fit', role: StaffRole.manager, gymId: 'gym-2', joinedOn: DateTime(2024, 4, 18)),
  StaffMember(id: 'S06', name: 'Suresh Babu', phone: '+91 98666 77889', email: 'suresh@healthos.fit', role: StaffRole.trainer, gymId: 'gym-2', joinedOn: DateTime(2024, 9, 9)),
  StaffMember(id: 'S07', name: 'Kavita Rao', phone: '+91 98777 88990', email: 'kavita@healthos.fit', role: StaffRole.receptionist, gymId: 'gym-2', joinedOn: DateTime(2025, 2, 14)),
  StaffMember(id: 'S08', name: 'Manoj Pillai', phone: '+91 98888 99001', email: 'manoj@healthos.fit', role: StaffRole.manager, gymId: 'gym-3', joinedOn: DateTime(2024, 7, 30)),
  StaffMember(id: 'S09', name: 'Ritu Jain', phone: '+91 98999 00112', email: 'ritu@healthos.fit', role: StaffRole.trainer, gymId: 'gym-3', joinedOn: DateTime(2025, 3, 3)),
  StaffMember(id: 'S10', name: 'Arun Das', phone: '+91 97000 11223', email: 'arun@healthos.fit', role: StaffRole.receptionist, gymId: 'gym-3', joinedOn: DateTime(2025, 4, 22)),
];

final mockRevenueSeries = <MonthPoint>[
  const MonthPoint('Jan', 980000),
  const MonthPoint('Feb', 1040000),
  const MonthPoint('Mar', 1125000),
  const MonthPoint('Apr', 1098000),
  const MonthPoint('May', 1230000),
  const MonthPoint('Jun', 1334000),
];

final mockAttendanceSeries = <MonthPoint>[
  const MonthPoint('Mon', 286),
  const MonthPoint('Tue', 312),
  const MonthPoint('Wed', 298),
  const MonthPoint('Thu', 305),
  const MonthPoint('Fri', 341),
  const MonthPoint('Sat', 389),
  const MonthPoint('Sun', 174),
];

final mockMemberGrowth = <MonthPoint>[
  const MonthPoint('Jan', 742),
  const MonthPoint('Feb', 768),
  const MonthPoint('Mar', 801),
  const MonthPoint('Apr', 833),
  const MonthPoint('May', 868),
  const MonthPoint('Jun', 896),
];

final mockPayments = List<Payment>.generate(40, (i) {
  final member = mockMembers[i % mockMembers.length];
  final plan = mockPlans[i % 4];
  final status = switch (i % 8) {
    0 => PaymentStatus.pending,
    1 => PaymentStatus.overdue,
    _ => PaymentStatus.paid,
  };
  return Payment(
    id: 'INV-${2600 + i}',
    memberName: member.name,
    gymId: member.gymId,
    amount: plan.price,
    status: status,
    date: DateTime(2026, 6, 1).subtract(Duration(days: i * 3)),
    method: ['UPI', 'Card', 'Cash', 'Netbanking'][i % 4],
    planName: plan.name,
  );
});

final mockAttendanceToday = List<AttendanceRecord>.generate(28, (i) {
  final member = mockMembers[(i * 2) % mockMembers.length];
  final checkIn = DateTime(2026, 6, 12, 6 + (i % 14), (i * 7) % 60);
  return AttendanceRecord(
    memberName: member.name,
    gymId: member.gymId,
    checkIn: checkIn,
    checkOut: i % 3 == 0 ? null : checkIn.add(Duration(minutes: 55 + (i % 50))),
  );
});

Gym gymById(String id) => mockGyms.firstWhere((g) => g.id == id, orElse: () => mockGyms.first);
