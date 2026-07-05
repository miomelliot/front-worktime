import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/work_status.dart';
import '../theme/app_spacing.dart';
import 'status_badge.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({
    super.key,
    required this.status,
    required this.elapsed,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final WorkStatus status;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Current session',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _format(elapsed),
            style: const TextStyle(
                fontSize: 52, height: 1, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Tracked today',
              style: TextStyle(color: Color(0xff667085))),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ShadButton(
                enabled: status == WorkStatus.notStarted ||
                    status == WorkStatus.stopped,
                onPressed: onStart,
                child: const Text('Start'),
              ),
              ShadButton.outline(
                enabled: status == WorkStatus.working,
                onPressed: onPause,
                child: const Text('Pause'),
              ),
              ShadButton.outline(
                enabled: status == WorkStatus.paused,
                onPressed: onResume,
                child: const Text('Resume'),
              ),
              ShadButton.destructive(
                enabled:
                    status == WorkStatus.working || status == WorkStatus.paused,
                onPressed: onStop,
                child: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _format(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
