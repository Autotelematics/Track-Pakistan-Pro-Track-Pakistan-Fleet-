# Dashboard UI Guide

Use this as the visual baseline for all new UI updates.

## Design Direction
- Soft surfaces and gentle contrast.
- Rounded corners (no sharp-heavy UI).
- Balanced spacing that scales well on tall devices.
- Consistent icon/text rhythm (no detached labels).

## Core Rules
- Prefer shared tokens from `lib/app/theme/app_ui_tokens.dart`.
- Use adaptive sizing with min/max clamps instead of raw `% height` everywhere.
- Keep card shapes consistent:
  - small radius: `12`
  - medium radius: `16`
  - large radius: `24`
- Use soft shadow depth, not harsh black shadows.
- Respect dark mode contrast while preserving softness.

## Practical Defaults
- Card radius: `AppUiTokens.radiusLg`
- Elevated card/section look: `AppUiTokens.softCardDecoration(...)`
- Height-based UI sizing: `AppUiTokens.adaptiveHeight(...)`
- Width spacing/sizing: `AppUiTokens.adaptiveWidth(...)`

## Rollout Plan
1. Apply tokens to shared widgets and navigation first.
2. Update feature screens incrementally (map, alerts, settings, auth).
3. Keep one visual language: same spacing, corner system, and shadows.
