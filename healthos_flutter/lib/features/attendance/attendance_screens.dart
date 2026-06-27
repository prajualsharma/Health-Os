import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const AttendanceScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 4, vsync: this, initialIndex: widget.initialTab.clamp(0, 3));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              const PageHeader(
                  title: 'Attendance',
                  subtitle: 'Daily check-ins, QR attendance and reports'),
              TabBar(controller: _tab, isScrollable: true, tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Check-In / Out'),
                Tab(text: 'QR Attendance'),
                Tab(text: 'Reports'),
              ]),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tab, children: const [
            _TodayTab(),
            _CheckInTab(),
            _QrTab(),
            _ReportsTab(),
          ]),
        ),
      ],
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;
    final records = isOwner
        ? mockAttendanceToday
        : mockAttendanceToday
            .where((a) => a.gymId == session.activeGymId)
            .toList();
    final inGym = records.where((a) => a.checkOut == null).length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(children: [
          Expanded(
            child: KpiCard(
                title: 'Check-ins today',
                value: '${records.length}',
                icon: Icons.login,
                color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: KpiCard(
                title: 'Currently in gym',
                value: '$inGym',
                icon: Icons.directions_run,
                color: AppColors.primary),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            for (final a in records)
              ListTile(
                leading: Icon(
                  a.checkOut == null ? Icons.directions_run : Icons.check_circle,
                  color: a.checkOut == null
                      ? AppColors.primary
                      : AppColors.secondary,
                ),
                title: Text(a.memberName),
                subtitle: Text(gymById(a.gymId).name),
                trailing: Text(
                  a.checkOut == null
                      ? 'In since ${timeFmt.format(a.checkIn)}'
                      : '${timeFmt.format(a.checkIn)} – ${timeFmt.format(a.checkOut!)}',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}

class _CheckInTab extends StatefulWidget {
  const _CheckInTab();

  @override
  State<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends State<_CheckInTab> {
  final _controller = TextEditingController();
  Member? _found;

  void _search() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      _found = mockMembers.where((m) {
        return m.id.toLowerCase() == q ||
            m.phone.replaceAll(' ', '').contains(q) ||
            m.name.toLowerCase().contains(q);
      }).firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Member check-in / check-out',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Member ID, phone, or name',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _search, child: const Text('Find member')),
                  if (_found != null) ...[
                    const SizedBox(height: 20),
                    ListTile(
                      tileColor: AppColors.primary.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      leading: CircleAvatar(child: Text(_found!.name[0])),
                      title: Text(_found!.name),
                      subtitle: Text('${_found!.id} · ${_found!.planName}'),
                      trailing: memberStatusChip(_found!.status),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              showComingSoon(context, 'Check-in'),
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Check-In'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              showComingSoon(context, 'Check-out'),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Check-Out'),
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QrTab extends StatelessWidget {
  const _QrTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Gym QR code',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Members scan this at the entrance to check in.',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.qr_code_2,
                        size: 180, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => showComingSoon(context, 'QR download'),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            showComingSoon(context, 'QR scanner (camera)'),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Open Scanner'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionCard(
          title: 'Weekly attendance',
          child: SimpleBarChart(points: mockAttendanceSeries),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Peak hours',
          child: SimpleBarChart(
            color: AppColors.primary,
            points: const [
              MonthPoint('6a', 42),
              MonthPoint('8a', 78),
              MonthPoint('10a', 35),
              MonthPoint('12p', 22),
              MonthPoint('4p', 48),
              MonthPoint('6p', 96),
              MonthPoint('8p', 71),
            ],
          ),
        ),
      ],
    );
  }
}
