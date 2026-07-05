import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/workday_plan.dart';
import '../theme/app_spacing.dart';

class WorkdayPlanCard extends StatelessWidget {
  const WorkdayPlanCard({super.key, required this.plan});

  final WorkdayPlan plan;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      title: const Text('Workday plan'),
      description: Text(plan.isDayOff
          ? 'No planned work today'
          : 'Expected schedule and break'),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.lg,
          children: [
            _PlanFact(label: 'Start', value: plan.plannedStart),
            _PlanFact(label: 'End', value: plan.plannedEnd),
            _PlanFact(
                label: 'Hours',
                value: '${plan.expectedHours.toStringAsFixed(1)}h'),
            _PlanFact(label: 'Break', value: '${plan.breakMinutes}m'),
          ],
        ),
      ),
    );
  }
}

class _PlanFact extends StatelessWidget {
  const _PlanFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Color(0xff667085))),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
