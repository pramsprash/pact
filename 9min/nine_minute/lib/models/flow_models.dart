enum SegmentType { opening, work, transition, rest }

class Segment {
  final SegmentType type;
  final String label;
  final int durationSec;
  final String? audioKey;

  const Segment({
    required this.type,
    required this.label,
    required this.durationSec,
    this.audioKey,
  });

  @override
  String toString() => '$type "$label" ${durationSec}s';
}

class FlowStep {
  final String name;
  final String audioKey;
  final String detail;
  final String breath;
  final int workSec;
  final int transitionSec;

  const FlowStep({
    required this.name,
    required this.audioKey,
    required this.detail,
    required this.breath,
    this.workSec = 50,
    this.transitionSec = 10,
  });
}

class FlowPreset {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final String heroImageAsset;
  final List<String> benefits;
  final int? openingSec;
  final List<FlowStep> steps;

  const FlowPreset({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.heroImageAsset,
    required this.benefits,
    this.openingSec,
    required this.steps,
  });

  List<Segment> buildSegments() {
    final segments = <Segment>[];

    // Optional opening.
    if (openingSec != null && openingSec! > 0) {
      segments.add(Segment(
        type: SegmentType.opening,
        label: 'Get Ready',
        durationSec: openingSec!,
        audioKey: 'get_ready',
      ));
    }

    // 3 rounds of (A work, A transition, B work, B transition, C work, C transition)
    for (var round = 0; round < 3; round++) {
      for (final step in steps) {
        segments.add(Segment(
          type: SegmentType.work,
          label: step.name,
          durationSec: step.workSec,
          audioKey: step.audioKey,
        ));
        segments.add(Segment(
          type: SegmentType.transition,
          label: 'Transition',
          durationSec: step.transitionSec,
          audioKey: 'transition',
        ));
      }
    }

    // Final rest — no voice.
    segments.add(const Segment(
      type: SegmentType.rest,
      label: 'Rest',
      durationSec: 10,
    ));

    return segments;
  }

  int get totalDurationSec {
    return buildSegments().fold(0, (sum, s) => sum + s.durationSec);
  }
}
