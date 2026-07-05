import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/time_event.dart';
import '../theme/app_spacing.dart';
import 'empty_state.dart';

class TimeEventTimeline extends StatelessWidget {
  const TimeEventTimeline({super.key, required this.events});

  final List<TimeEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const EmptyState(
          title: 'No events',
          message: 'This day has no time tracking events yet.');
    }
    final format = DateFormat.Hm();
    return ShadCard(
      title: const Text('Timeline'),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          children: [
            for (final event in events)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(format.format(event.time),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      margin:
                          const EdgeInsets.only(top: 5, right: AppSpacing.md),
                      decoration: const BoxDecoration(
                          color: Color(0xff2563eb), shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.action.toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(event.note,
                              style: const TextStyle(color: Color(0xff667085))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
