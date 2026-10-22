import 'package:flutter_test/flutter_test.dart';
import 'package:cube_timer/features/timer/controllers/timer_controller.dart';

void main() {
  group('TimerController Stackmat Tests', () {
    late TimerController controller;

    setUp(() {
      controller = TimerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is idle and elapsed time is 0', () {
      expect(controller.phase, TimerPhase.idle);
      expect(controller.elapsedMilliseconds, 0);
      expect(controller.isRunning, false);
    });

    test('Single finger down does not start arming', () {
      controller.onPointerDown(1);
      expect(controller.phase, TimerPhase.idle);
    });

    test('Two fingers down transitions to holding phase', () {
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      expect(controller.phase, TimerPhase.holding);
    });

    test('Releasing fingers before 300ms cancels arming and returns to idle', () {
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      expect(controller.phase, TimerPhase.holding);

      // Premature release
      controller.onPointerUp(1);
      expect(controller.phase, TimerPhase.idle);
    });

    test('Holding two fingers >= 300ms enters ready phase', () async {
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      expect(controller.phase, TimerPhase.holding);

      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);
    });

    test('Releasing both fingers in ready phase starts timer', () async {
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);

      controller.onPointerUp(1);
      controller.onPointerUp(2);
      expect(controller.phase, TimerPhase.running);
      expect(controller.isRunning, true);
    });

    test('Lifting one finger and keeping one down cancels the start', () async {
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);

      // Remove finger 1, but keep finger 2 down
      controller.onPointerUp(1);
      // Wait for the release window timeout (>100ms)
      await Future.delayed(const Duration(milliseconds: 150));

      // Timer should be canceled and back to idle
      expect(controller.phase, TimerPhase.idle);
      expect(controller.isRunning, false);

      // Eventually lifting finger 2 does NOT start the timer
      controller.onPointerUp(2);
      expect(controller.phase, TimerPhase.idle);
      expect(controller.isRunning, false);
    });

    test('Single pointer touch while running stops timer', () async {
      int recordedTime = -1;
      controller.onSolveCompleted = (timeMs) {
        recordedTime = timeMs;
      };

      // Arm and start
      controller.onPointerDown(1);
      controller.onPointerDown(2);
      await Future.delayed(const Duration(milliseconds: 350));
      controller.onPointerUp(1);
      controller.onPointerUp(2);
      expect(controller.phase, TimerPhase.running);

      await Future.delayed(const Duration(milliseconds: 50));

      // Single touch anywhere on screen stops timer
      controller.onPointerDown(99);
      expect(controller.phase, TimerPhase.stopped);
      expect(recordedTime, greaterThanOrEqualTo(0));
    });

    test('Pressing Z key alone activates left pad without arming', () {
      controller.onLeftHandKeyDown();
      expect(controller.isLeftPadActive, true);
      expect(controller.isRightPadActive, false);
      expect(controller.phase, TimerPhase.idle);

      controller.onLeftHandKeyUp();
      expect(controller.isLeftPadActive, false);
      expect(controller.phase, TimerPhase.idle);
    });

    test('Pressing M key alone activates right pad without arming', () {
      controller.onRightHandKeyDown();
      expect(controller.isRightPadActive, true);
      expect(controller.isLeftPadActive, false);
      expect(controller.phase, TimerPhase.idle);

      controller.onRightHandKeyUp();
      expect(controller.isRightPadActive, false);
      expect(controller.phase, TimerPhase.idle);
    });

    test('Pressing both Z and M keys enters holding phase', () {
      controller.onLeftHandKeyDown();
      controller.onRightHandKeyDown();
      expect(controller.isLeftPadActive, true);
      expect(controller.isRightPadActive, true);
      expect(controller.phase, TimerPhase.holding);

      // Premature release of Z cancels arming
      controller.onLeftHandKeyUp();
      expect(controller.phase, TimerPhase.idle);
      expect(controller.isLeftPadActive, false);
      expect(controller.isRightPadActive, true);
    });

    test('Holding Z and M >= 300ms enters ready and releasing both starts timer', () async {
      controller.onLeftHandKeyDown();
      controller.onRightHandKeyDown();
      expect(controller.phase, TimerPhase.holding);

      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);

      controller.onLeftHandKeyUp();
      controller.onRightHandKeyUp();
      expect(controller.phase, TimerPhase.running);
      expect(controller.isRunning, true);

      // Slapping any key while running stops the timer
      controller.onLeftHandKeyDown();
      expect(controller.phase, TimerPhase.stopped);
    });

    test('Lifting Z key while keeping M key held down cancels ready start', () async {
      controller.onLeftHandKeyDown();
      controller.onRightHandKeyDown();
      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);

      // Release Z but keep M down
      controller.onLeftHandKeyUp();
      await Future.delayed(const Duration(milliseconds: 150));

      expect(controller.phase, TimerPhase.idle);
      expect(controller.isRunning, false);

      // Eventually lifting M does not start timer
      controller.onRightHandKeyUp();
      expect(controller.phase, TimerPhase.idle);
      expect(controller.isRunning, false);
    });

    test('Holding Spacebar arms both pads and releasing starts timer', () async {
      controller.onSpaceKeyDown();
      expect(controller.isLeftPadActive, true);
      expect(controller.isRightPadActive, true);
      expect(controller.phase, TimerPhase.holding);

      await Future.delayed(const Duration(milliseconds: 350));
      expect(controller.phase, TimerPhase.ready);

      controller.onSpaceKeyUp();
      expect(controller.phase, TimerPhase.running);
      expect(controller.isRunning, true);
    });
  });
}
