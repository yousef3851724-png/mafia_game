# Changelog

## 1.0.0+3 — Release

### Gameplay
- Finalized the Home → Scenario → Game flow.
- Role assignment remains genuinely randomized; adjacent Mafia seats are valid random outcomes and are not a deterministic pattern.
- Validated role distribution, game phases, voting, victory conditions, and 20-player table layout.
- Preserved Leader and Radical Staff table labels.

### Quality
- CI analysis and tests are green on the release baseline.
- Release APK generation and provenance attestation remain part of CI.
- Production release workflow now verifies the APK cryptographic signature before publishing.

### Android / Branding
- Version bumped to `1.0.0+3`.
- Android launcher branding uses the Mafia Radical release icon.
- Production signing is supported through a private GitHub Actions keystore; no signing material is stored in the repository.

### Release note
- The ordinary CI build remains suitable for automated validation/testing and may use the existing debug-signing fallback.
- Google Play / production distribution must use `.github/workflows/release.yml` with the four documented GitHub repository secrets and the project's production keystore.
