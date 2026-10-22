# Contributing to Tempest ⏱️

Thank you for your interest in contributing to **Tempest**! We welcome contributions from developers, designers, and speedcubers of all skill levels.

## Code Guidelines

- **File Length**: All files must strictly remain under **400 lines of code**. Keep classes modular and focused.
- **Architecture**: Follow feature-driven architecture with clean separation between UI (`widgets`), state management (`controllers`), models (`models`), and domain logic.
- **Verification**: Run static analysis and tests before submitting any PR:
  ```bash
  flutter analyze
  flutter test
  ```

## Development Workflow

1. Fork the repository and create your feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
2. Commit your changes with clear, descriptive commit messages:
   ```bash
   git commit -m "feat: add inspection time voice countdown"
   ```
3. Push to your branch:
   ```bash
   git push origin feature/amazing-feature
   ```
4. Open a Pull Request on GitHub.

## Reporting Issues

- Use the provided [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) or [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md).
- Provide clear steps to reproduce and device details for any bugs.
