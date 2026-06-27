import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                PageHeader(
                    title: 'Reports',
                    subtitle: 'Business analytics across revenue, members and attendance'),
                TabBar(isScrollable: true, tabs: [
                  Tab(text: 'Revenue'),
                  Tab(text: 'Membership'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Growth'),
                ]),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(children: [
              ListView(padding: const EdgeInsets.all(24), children: [
                SectionCard(
                  title: 'Revenue by month',
                  child: RevenueLineChart(points: mockRevenueSeries),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Revenue by gym (this month)',
                  child: SimpleBarChart(
                    color: AppColors.primary,
                    points: [
                      for (final g in mockGyms)
                        MonthPoint(g.name.split('— ').last, g.monthlyRevenue / 1000),
                    ],
                  ),
                ),
              ]),
              ListView(padding: const EdgeInsets.all(24), children: [
                SectionCard(
                  title: 'Members by plan',
                  child: SimpleBarChart(
                    points: [
                      for (final p in mockPlans)
                        MonthPoint(p.name.split(' ').first, p.activeMembers.toDouble()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Member status breakdown',
                  child: Column(children: [
                    for (final status in MemberStatus.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: memberStatusChip(status),
                        title: Text(
                            '${mockMembers.where((m) => m.status == status).length} members'),
                      ),
                  ]),
                ),
              ]),
              ListView(padding: const EdgeInsets.all(24), children: [
                SectionCard(
                  title: 'Attendance by weekday',
                  child: SimpleBarChart(points: mockAttendanceSeries),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Attendance by gym (today)',
                  child: SimpleBarChart(
                    color: AppColors.warning,
                    points: [
                      for (final g in mockGyms)
                        MonthPoint(
                            g.name.split('— ').last, g.todayAttendance.toDouble()),
                    ],
                  ),
                ),
              ]),
              ListView(padding: const EdgeInsets.all(24), children: [
                SectionCard(
                  title: 'Member growth (6 months)',
                  child: RevenueLineChart(
                      points: mockMemberGrowth, color: AppColors.secondary),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Growth summary',
                  child: Column(children: const [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.trending_up, color: AppColors.secondary),
                      title: Text('+154 net members in 6 months'),
                      subtitle: Text('20.8% growth rate'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.currency_rupee, color: AppColors.primary),
                      title: Text('+36% revenue growth'),
                      subtitle: Text('Driven by Annual Elite plan uptake'),
                    ),
                  ]),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
