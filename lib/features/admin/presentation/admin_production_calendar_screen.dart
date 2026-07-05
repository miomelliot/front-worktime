import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/mock/mock_calendar.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';

class AdminProductionCalendarScreen extends StatelessWidget {
  const AdminProductionCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = buildMockCalendarDays(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
            title: 'Production Calendar',
            description: 'Mock year calendar for RU / Europe-Moscow.'),
        ShadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ShadBadge.secondary(child: Text('workday')),
                  ShadBadge.secondary(child: Text('weekend')),
                  ShadBadge.secondary(child: Text('holiday')),
                  ShadBadge.secondary(child: Text('shortened')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisExtent: 72,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) =>
                    CalendarDayCell(day: days[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
