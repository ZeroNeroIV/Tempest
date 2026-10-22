# Changelog

All notable changes to **Tempest** are documented in this file.

## [1.0.1] - 2026-10-22

### Fixed
- **Modal & Dialog Key Routing**: Resolved an issue where pressing `Z`, `M`, or `Space` while renaming users or editing profiles intercepted keys into the timer instead of typing into the text field. Keys now pass through cleanly whenever any modal, dialog, popup, or drawer is active or when an input has focus.
- **Mouse Click Disambiguation**: Fixed mouse clicks erroneously registering as physical Left Hand (`Z`) touch events on desktop and web. Only genuine touch/stylus pointers activate touchscreen Stackmat pads, while desktop mice are treated purely as navigation pointers.

### Added
- **Scramble Refresh Shortcut (`[R]`)**: Added `[R]` keyboard shortcut to regenerate and cycle to the next scramble instantly.
- **GitHub Pages Automated Deployment**: Automated web app compilation (`flutter build web --base-href /Tempest/`) and real-time deployment to GitHub Pages on every push.

---

## [1.0.0] - 2026-10-22

### Initial Release
- **Precision Stackmat Timing**: Two-hand multi-touch and keyboard Stackmat controls (`Z` for Left Hand, `M` for Right Hand, `Space` for quick arm/stop).
- **Smart Arming & Anti-Cheat**: 300ms hold-to-ready state with color indicators and intentional single-hand lift cancel protection.
- **Distraction-Free Fullscreen Mode**: High-contrast minimal layout with `[F]` and `[Esc]` toggles.
- **Dual Stateful Leaderboards**: Global per-event rankings with podium badges and local user solve histories.
- **Multi-User & Multi-Profile Support**: Switch between cubists and puzzle categories (3x3, 2x2, 4x4, 5x5, Pyraminx, and custom) with one tap.
- **Celebration Particle Engine**: Personal best confetti explosions and global record trophy cascades.
- **Multi-Platform CI/CD**: Automated builds for Android (APK), iOS (IPA), Linux (AppImage), Windows (EXE & MSI), and Web.
