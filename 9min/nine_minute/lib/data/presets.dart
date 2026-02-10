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
        moveVoiceKey: 'cloud_sweep',
        stepImageAsset: 'assets/poses/Cloud_Sweep_Centered.png',
        breathProfile: 'dynamic',
        detail:
            'Stand with feet just wider than hip-width, knees soft. '
            'Let both arms float out to the sides and overhead in a wide arc, '
            'then sweep them back down. Keep the movement slow and continuous — '
            'right side leads first, then left.',
      ),
      FlowStep(
        name: 'Hip Rounds',
        moveVoiceKey: 'hip_rounds',
        stepImageAsset: 'assets/poses/Hip_Rounds_Centered.png',
        breathProfile: 'dynamic',
        detail:
            'Hands rest lightly on the hips. Draw slow, wide circles '
            'with the pelvis — forward, to the side, back, and around. '
            'Keep the knees soft and the upper body still. '
            'Switch direction halfway through.',
      ),
      FlowStep(
        name: 'Lift & Stillness',
        moveVoiceKey: 'lift_stillness',
        stepImageAsset: 'assets/poses/Lift_Stillness_Centered.png',
        breathProfile: 'hold',
        detail:
            'Press evenly through both feet and rise onto the balls of your feet. '
            'Hold at the top for a breath or two, finding a quiet point of balance. '
            'Lower back down with control. '
            'Let each rise feel a little steadier than the last.',
      ),
    ],
  ),

  // ─────────────────────────────────────────────
  // 2. Spine and Core
  // ─────────────────────────────────────────────
  FlowPreset(
    id: 'spine_and_core',
    title: 'Spine and Core',
    tagline: 'Mobilise and stabilise',
    description:
        'Tabletop work that wakes up the spine and builds quiet strength. '
        'Nothing forced — just steady, deliberate movement.',
    heroImageAsset: 'assets/posters/spine_and_core.png',
    benefits: [
      'Mobilises the full length of the spine',
      'Builds core stability without strain',
      'Opens the side body and intercostal muscles',
      'Eases lower-back stiffness',
      'Strengthens the glutes and deep stabilisers',
    ],
    openingSec: 10,
    steps: [
      FlowStep(
        name: 'Cat–Cow',
        moveVoiceKey: 'cat_cow',
        stepImageAsset: 'assets/poses/Cat_Cow_Centered.png',
        breathProfile: 'dynamic',
        detail:
            'Start on hands and knees, wrists under shoulders, knees under hips. '
            'On the inhale, let the belly soften and the chest open. '
            'On the exhale, round the spine upward, tucking the chin gently. '
            'Move slowly — let each vertebra join the wave.',
      ),
      FlowStep(
        name: 'Side Bends',
        moveVoiceKey: 'side_bends',
        stepImageAsset: 'assets/poses/Side_Bends_Centered.png',
        breathProfile: 'dynamic',
        detail:
            'Stand or kneel tall with arms relaxed at your sides. '
            'Reach one arm overhead and lean gently to the opposite side, '
            'feeling a long stretch through the ribs and waist. '
            'Return to centre and switch sides, alternating slowly.',
      ),
      FlowStep(
        name: 'Wave Bridge',
        moveVoiceKey: 'wave_bridge',
        stepImageAsset: 'assets/poses/Wave_Bridge_Centered.png',
        breathProfile: 'dynamic',
        detail:
            'Roll onto your back, feet flat and hip-width apart. '
            'Peel the spine off the floor one segment at a time until the hips are lifted. '
            'Lower back down the same way — upper back, mid-back, low back. '
            'Keep moving without fully resting at the bottom.',
      ),
    ],
  ),

  // ─────────────────────────────────────────────
  // 3. Length and Curl
  // ─────────────────────────────────────────────
  FlowPreset(
    id: 'length_and_curl',
    title: 'Length and Curl',
    tagline: 'Unwind and let go',
    description:
        'Floor-based stretches to release tension. '
        'Nothing to push — just ease in and stay.',
    heroImageAsset: 'assets/posters/length_and_curl.png',
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
        moveVoiceKey: 'supine_twist',
        stepImageAsset: 'assets/poses/Supine_Twist_Centered.png',
        breathProfile: 'hold',
        detail:
            'Lie on your back with knees bent and feet flat. '
            'Let both knees fall to the left, arms resting wide. '
            'Stay for several breaths, then bring the knees back to centre '
            'and let them fall to the right.',
      ),
      FlowStep(
        name: 'Knee Curl',
        moveVoiceKey: 'knee_curl',
        stepImageAsset: 'assets/poses/Knee_Curl_Centered.png',
        breathProfile: 'hold',
        detail:
            'Lying on your back, draw both knees toward the chest. '
            'Wrap your arms around the shins and gently hug them in. '
            'Rock softly side to side if that feels good. '
            'Let the lower back release into the floor.',
      ),
      FlowStep(
        name: 'Child Pose',
        moveVoiceKey: 'child_pose',
        stepImageAsset: 'assets/poses/Child_Pose_Centered.png',
        breathProfile: 'hold',
        detail:
            'From kneeling, sit the hips back toward the heels and walk the hands forward. '
            'Rest the forehead on the floor or a cushion. '
            'Let the arms be soft, shoulders heavy. '
            'There is nothing to do here but breathe.',
      ),
    ],
  ),
];
