import '../models/flow_models.dart';

const kPresets = <FlowPreset>[
  // ─────────────────────────────────────────────
  // 1. Ground to Rise
  // ─────────────────────────────────────────────
  FlowPreset(
    id: 'ground_to_rise',
    title: 'Ground to Rise',
    tagline: 'Root down, then rise',
    description:
        'A standing sequence that builds from the ground up. '
        'Settle in, then let movement carry you.',
    heroImageAsset: 'assets/posters/ground_to_rise.png',
    benefits: [
      'Releases tension across the shoulders and upper back',
      'Warms the hip joints with gentle, circular movement',
      'Improves standing balance and ankle stability',
      'Encourages full, unhurried breathing',
      'A calm way to start or reset your day',
    ],
    openingSec: 10,
    steps: [
      FlowStep(
        name: 'Cloud Sweep',
        audioKey: 'cloud_sweep',
        detail:
            'Stand with feet just wider than hip-width, knees soft. '
            'Let both arms float out to the sides and overhead in a wide arc, '
            'then sweep them back down. Keep the movement slow and continuous — '
            'right side leads first, then left.',
        breath: 'Inhale as arms rise, exhale as they fall.',
      ),
      FlowStep(
        name: 'Hip Rounds',
        audioKey: 'hip_rounds',
        detail:
            'Hands rest lightly on the hips. Draw slow, wide circles '
            'with the pelvis — forward, to the side, back, and around. '
            'Keep the knees soft and the upper body still. '
            'Switch direction halfway through.',
        breath: 'Breathe naturally, matching the pace of the circles.',
      ),
      FlowStep(
        name: 'Lift & Stillness',
        audioKey: 'lift_stillness',
        detail:
            'Press evenly through both feet and rise onto the balls of your feet. '
            'Hold at the top for a breath or two, finding a quiet point of balance. '
            'Lower back down with control. '
            'Let each rise feel a little steadier than the last.',
        breath: 'Inhale to lift, hold at the top, exhale to lower.',
      ),
    ],
  ),

  // ─────────────────────────────────────────────
  // 2. Spine & Strength
  // ─────────────────────────────────────────────
  FlowPreset(
    id: 'spine_and_strength',
    title: 'Spine & Strength',
    tagline: 'Mobilise and stabilise',
    description:
        'Tabletop work that wakes up the spine and builds quiet strength. '
        'Nothing forced — just steady, deliberate movement.',
    heroImageAsset: 'assets/posters/spine_strength.png',
    benefits: [
      'Mobilises the full length of the spine',
      'Builds core stability without strain',
      'Improves coordination between opposite limbs',
      'Eases lower-back stiffness',
      'Strengthens the glutes and deep stabilisers',
    ],
    openingSec: 10,
    steps: [
      FlowStep(
        name: 'Gentle Cat–Cow',
        audioKey: 'cat_cow',
        detail:
            'Start on hands and knees, wrists under shoulders, knees under hips. '
            'On the inhale, let the belly soften and the chest open. '
            'On the exhale, round the spine upward, tucking the chin gently. '
            'Move slowly — let each vertebra join the wave.',
        breath: 'Inhale to arch, exhale to round.',
      ),
      FlowStep(
        name: 'Tabletop Lift',
        audioKey: 'tabletop_lift',
        detail:
            'From the same position, extend one arm forward and the opposite leg back. '
            'Keep the hips level and the extended limbs in line with the torso. '
            'Bend the knee back to tabletop, then switch sides. '
            'Alternate steadily without rushing.',
        breath: 'Inhale to extend, exhale to return.',
      ),
      FlowStep(
        name: 'Wave Bridge',
        audioKey: 'wave_bridge',
        detail:
            'Roll onto your back, feet flat and hip-width apart. '
            'Peel the spine off the floor one segment at a time until the hips are lifted. '
            'Lower back down the same way — upper back, mid-back, low back. '
            'Keep moving without fully resting at the bottom.',
        breath: 'Inhale as you lift, exhale as you lower.',
      ),
    ],
  ),

  // ─────────────────────────────────────────────
  // 3. Length & Release
  // ─────────────────────────────────────────────
  FlowPreset(
    id: 'length_and_release',
    title: 'Length & Release',
    tagline: 'Unwind and let go',
    description:
        'Floor-based stretches to release tension. '
        'Nothing to push — just ease in and stay.',
    heroImageAsset: 'assets/posters/length_release.png',
    benefits: [
      'Releases tightness through the lower back and hips',
      'Gently opens the chest and shoulders',
      'Calms the nervous system before rest',
      'Improves spinal mobility with minimal effort',
      'A quiet way to close the day',
    ],
    openingSec: 10,
    steps: [
      FlowStep(
        name: 'Supine Twist',
        audioKey: 'supine_twist',
        detail:
            'Lie on your back with knees bent and feet flat. '
            'Let both knees fall to the left, arms resting wide. '
            'Stay for several breaths, then bring the knees back to centre '
            'and let them fall to the right. Always start left.',
        breath: 'Exhale into the twist, inhale back to centre.',
      ),
      FlowStep(
        name: 'Spine Curl',
        audioKey: 'spine_curl',
        detail:
            'Sit tall with legs extended or comfortably crossed. '
            'Slowly round forward from the top of the head, letting the spine curl '
            'segment by segment until you reach a gentle fold. '
            'Rebuild the spine on the way back up, stacking each vertebra.',
        breath: 'Exhale to fold, inhale to rebuild.',
      ),
      FlowStep(
        name: 'Child Pose',
        audioKey: 'child_pose',
        detail:
            'From kneeling, sit the hips back toward the heels and walk the hands forward. '
            'Rest the forehead on the floor or a cushion. '
            'Let the arms be soft, shoulders heavy. '
            'There is nothing to do here but breathe.',
        breath: 'Breathe slowly and let each exhale settle you deeper.',
      ),
    ],
  ),
];
