enum SegmentType { opening, work, transition, rest }

class Segment {
  final SegmentType type;
  final String label;
  final int durationSec;
  final String? audioKey;

  /// The step driving this segment (work segments only).
  final FlowStep? step;

  /// The step that follows this transition (transition segments only).
  final FlowStep? nextStep;

  const Segment({
    required this.type,
    required this.label,
    required this.durationSec,
    this.audioKey,
    this.step,
    this.nextStep,
  });

  @override
  String toString() => '$type "$label" ${durationSec}s';
}

class FlowStep {
  final String name;
  final String moveVoiceKey;
  final String detail;
  final String breathProfile; // "dynamic" or "hold"
  final String stepImageAsset;
  final int workSec;
  final int transitionSec;

  const FlowStep({
    required this.name,
    required this.moveVoiceKey,
    required this.detail,
    required this.breathProfile,
    required this.stepImageAsset,
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
        nextStep: steps.isNotEmpty ? steps.first : null,
      ));
    }

    // 3 rounds of (A work, A transition, B work, B transition, C work, C transition)
    for (var round = 0; round < 3; round++) {
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];

        // Work segment — carries the step for image + voice.
        segments.add(Segment(
          type: SegmentType.work,
          label: step.name,
          durationSec: step.workSec,
          audioKey: step.moveVoiceKey,
          step: step,
        ));

        // Determine the next step after this transition.
        final isLastStepOfLastRound =
            round == 2 && i == steps.length - 1;
        final FlowStep? next = isLastStepOfLastRound
            ? null
            : steps[(i + 1) % steps.length];
        final nextAudioKey = isLastStepOfLastRound
            ? 'transition_to_rest'
            : 'transition_to_${next!.moveVoiceKey}';

        // Transition segment — carries nextStep so UI can preview it.
        segments.add(Segment(
          type: SegmentType.transition,
          label: 'Transition',
          durationSec: step.transitionSec,
          audioKey: nextAudioKey,
          nextStep: next,
        ));
      }
    }

    // Final rest — no voice, no step.
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
