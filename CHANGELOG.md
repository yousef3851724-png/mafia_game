# Changelog

## 1.0.0+2 — Release Candidate

### Gameplay
- Finalized the main Home → Scenario → Game flow.
- Kept role assignment genuinely randomized; adjacent Mafia seats are valid random outcomes.
- Added/validated seeded distribution tests for role-to-seat randomization.
- Preserved 20-player table geometry without seat overlap.

### Quality
- Flutter analyze passes in CI.
- Flutter tests pass in CI, including role-count, randomization, seat-layout, and player metadata coverage.
- Release APK build is validated by CI before artifact upload.

### Branding / Android
- Release build number bumped to `1.0.0+2`.
- Android launcher branding is prepared for the release candidate.

### Known release note
- The current CI release signing configuration uses the Android debug signing key. The APK is suitable for testing/distribution outside Google Play, but a production Play Store release must be signed with the project's upload/release keystore before publishing.
