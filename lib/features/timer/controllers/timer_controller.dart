import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';

/// Defines the operational phase of the speedcubing timer.
enum TimerPhase {
  idle,
  holding, // 2 pointers or Z+M keys down, waiting for arming threshold (<300ms)
  ready,   // 2 hands held >= 300ms, ready to start upon release
  running, // Timer actively counting milliseconds
  stopped, // Timer stopped by touch or key, result displayed
}

typedef OnSolveCompleted = void Function(int durationMs);

/// High-precision multi-pointer & keyboard Stackmat timer controller.
class TimerController extends ChangeNotifier {
  TimerPhase _phase = TimerPhase.idle;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  Timer? _armingTimer;
  Timer? _releaseWindowTimer;
  bool _isCanceled = false;

  final Set<int> _activePointerIds = {};
  bool _isLeftKeyDown = false;
  bool _isRightKeyDown = false;
  bool _isSpaceKeyDown = false;

  int _elapsedMilliseconds = 0;
  OnSolveCompleted? onSolveCompleted;

  TimerPhase get phase => _phase;
  int get elapsedMilliseconds => _elapsedMilliseconds;
  bool get isRunning => _phase == TimerPhase.running;
  bool get isReady => _phase == TimerPhase.ready;
  bool get isHolding => _phase == TimerPhase.holding;

  /// Whether the left hand pad is currently pressed (via touch, Z key, or Space).
  bool get isLeftPadActive =>
      _isLeftKeyDown || _isSpaceKeyDown || _activePointerIds.isNotEmpty;

  /// Whether the right hand pad is currently pressed (via touch, M key, or Space).
  bool get isRightPadActive =>
      _isRightKeyDown || _isSpaceKeyDown || _activePointerIds.length >= 2;

  bool get isLeftKeyDown => _isLeftKeyDown;
  bool get isRightKeyDown => _isRightKeyDown;
  bool get isSpaceKeyDown => _isSpaceKeyDown;

  bool get _areBothHandsDown {
    if (_isSpaceKeyDown) return true;
    if (_isLeftKeyDown && _isRightKeyDown) return true;
    if (_activePointerIds.length >= 2) return true;
    if (_activePointerIds.isNotEmpty && (_isLeftKeyDown || _isRightKeyDown)) {
      return true;
    }
    return false;
  }

  bool get _isAnyHandDown {
    return _isSpaceKeyDown ||
        _isLeftKeyDown ||
        _isRightKeyDown ||
        _activePointerIds.isNotEmpty;
  }

  /// Checks whether an editable text field (e.g. inside a modal/dialog) has focus.
  bool isTextInputFocused() {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null || primaryFocus.context == null) return false;

    final ctx = primaryFocus.context!;
    if (ctx.widget is EditableText) return true;
    if (ctx.findRenderObject() is RenderEditable) return true;
    if (ctx.findAncestorStateOfType<EditableTextState>() != null) return true;
    if (ctx.findAncestorWidgetOfExactType<EditableText>() != null) return true;

    bool hasEditableChild = false;
    ctx.visitChildElements((element) {
      if (element.widget is EditableText) {
        hasEditableChild = true;
      }
    });
    return hasEditableChild;
  }

  /// Releases all active keyboard and pointer states.
  void releaseAllKeys() {
    final hadActive = _isLeftKeyDown ||
        _isRightKeyDown ||
        _isSpaceKeyDown ||
        _activePointerIds.isNotEmpty;
    _isLeftKeyDown = false;
    _isRightKeyDown = false;
    _isSpaceKeyDown = false;
    _activePointerIds.clear();
    _isCanceled = false;

    if (_phase == TimerPhase.holding) {
      _cancelArming();
    } else if (_phase == TimerPhase.ready) {
      _phase = TimerPhase.idle;
      notifyListeners();
    } else if (hadActive) {
      notifyListeners();
    }
  }

  /// Handles hardware keyboard events for Z (left), M (right), Space, and stop keys.
  bool handleKeyEvent(KeyEvent event) {
    // If a text input field currently has focus, never intercept keys!
    if (isTextInputFocused()) {
      return false;
    }

    final isZ = event.logicalKey == LogicalKeyboardKey.keyZ ||
        event.physicalKey == PhysicalKeyboardKey.keyZ;
    final isM = event.logicalKey == LogicalKeyboardKey.keyM ||
        event.physicalKey == PhysicalKeyboardKey.keyM;
    final isSpace = event.logicalKey == LogicalKeyboardKey.space;

    if (event is KeyDownEvent) {
      if (isZ) {
        onLeftHandKeyDown();
        return true;
      }
      if (isM) {
        onRightHandKeyDown();
        return true;
      }
      if (isSpace) {
        onSpaceKeyDown();
        return true;
      }

      // When running, pressing ANY key stops the timer immediately!
      if (_phase == TimerPhase.running) {
        _stopTimer();
        return true;
      }

      // When stopped, pressing ANY key resets back to idle
      if (_phase == TimerPhase.stopped) {
        resetToIdle();
        return true;
      }
    } else if (event is KeyUpEvent) {
      if (isZ) {
        onLeftHandKeyUp();
        return true;
      }
      if (isM) {
        onRightHandKeyUp();
        return true;
      }
      if (isSpace) {
        onSpaceKeyUp();
        return true;
      }
    } else if (event is KeyRepeatEvent) {
      if (_phase == TimerPhase.running) {
        _stopTimer();
        return true;
      }
    }

    return false;
  }

  /// Left Hand key (Z) down
  void onLeftHandKeyDown() {
    if (_isLeftKeyDown) return;
    _isLeftKeyDown = true;
    _handleHandsChanged();
  }

  /// Left Hand key (Z) up
  void onLeftHandKeyUp() {
    if (!_isLeftKeyDown) return;
    _isLeftKeyDown = false;
    _handleHandsChanged();
    _checkCanceledReset();
  }

  /// Right Hand key (M) down
  void onRightHandKeyDown() {
    if (_isRightKeyDown) return;
    _isRightKeyDown = true;
    _handleHandsChanged();
  }

  /// Right Hand key (M) up
  void onRightHandKeyUp() {
    if (!_isRightKeyDown) return;
    _isRightKeyDown = false;
    _handleHandsChanged();
    _checkCanceledReset();
  }

  /// Spacebar down (simulates both hands)
  void onSpaceKeyDown() {
    if (_isSpaceKeyDown) return;
    _isSpaceKeyDown = true;
    _handleHandsChanged();
  }

  /// Spacebar up
  void onSpaceKeyUp() {
    if (!_isSpaceKeyDown) return;
    _isSpaceKeyDown = false;
    _handleHandsChanged();
    _checkCanceledReset();
  }

  /// Handles incoming pointer down events (touch or mouse).
  void onPointerDown(int pointerId, [PointerDeviceKind kind = PointerDeviceKind.touch]) {
    if (_phase == TimerPhase.running) {
      _stopTimer();
      return;
    }

    if (_phase == TimerPhase.stopped) {
      resetToIdle();
      return;
    }

    // Mouse and trackpad clicks are pointing devices and do not count as physical Stackmat hands!
    // (Physical hands on desktop/web are emulated via Z and M keys).
    if (kind == PointerDeviceKind.mouse || kind == PointerDeviceKind.trackpad) {
      return;
    }

    _activePointerIds.add(pointerId);
    _handleHandsChanged();
  }

  /// Handles pointer up or cancel events.
  void onPointerUp(int pointerId) {
    _activePointerIds.remove(pointerId);
    _handleHandsChanged();
    _checkCanceledReset();
  }

  void _checkCanceledReset() {
    if (!_isAnyHandDown) {
      _isCanceled = false;
    }
  }

  void _handleHandsChanged() {
    if (_phase == TimerPhase.running) {
      _stopTimer();
      return;
    }

    if (_phase == TimerPhase.stopped) {
      resetToIdle();
      return;
    }

    if (_phase == TimerPhase.idle) {
      if (_areBothHandsDown && !_isCanceled) {
        _startArming();
      } else {
        notifyListeners();
      }
      return;
    }

    if (_phase == TimerPhase.holding) {
      if (!_areBothHandsDown) {
        _cancelArming();
      } else {
        notifyListeners();
      }
      return;
    }

    if (_phase == TimerPhase.ready) {
      if (!_isAnyHandDown) {
        // Both hands lifted simultaneously -> START TIMER!
        _releaseWindowTimer?.cancel();
        if (!_isCanceled) {
          _startTimer();
        } else {
          _isCanceled = false;
        }
      } else if (!_areBothHandsDown) {
        // One hand released while keeping the other down -> Intentional cancel!
        _releaseWindowTimer?.cancel();
        _releaseWindowTimer = Timer(const Duration(milliseconds: 100), () {
          if (_phase == TimerPhase.ready && _isAnyHandDown) {
            _cancelStart();
          }
        });
      }
    }
  }

  void _startArming() {
    _phase = TimerPhase.holding;
    notifyListeners();

    _armingTimer?.cancel();
    _armingTimer = Timer(const Duration(milliseconds: AppConstants.armingHoldDurationMs), () {
      if (_phase == TimerPhase.holding && _areBothHandsDown) {
        _phase = TimerPhase.ready;
        _isCanceled = false;
        notifyListeners();
      }
    });
  }

  void _cancelArming() {
    _armingTimer?.cancel();
    _phase = TimerPhase.idle;
    notifyListeners();
  }

  /// Cancels a ready start when one hand is lifted while keeping the other down.
  void _cancelStart() {
    _releaseWindowTimer?.cancel();
    _phase = TimerPhase.idle;
    _isCanceled = true;
    notifyListeners();
  }

  void _startTimer() {
    _phase = TimerPhase.running;
    _stopwatch.reset();
    _stopwatch.start();
    _elapsedMilliseconds = 0;
    notifyListeners();

    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: AppConstants.timerUpdateIntervalMs),
      (_) {
        if (_phase == TimerPhase.running) {
          _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
          notifyListeners();
        }
      },
    );
  }

  void _stopTimer() {
    _ticker?.cancel();
    _stopwatch.stop();
    _elapsedMilliseconds = _stopwatch.elapsedMilliseconds;
    _phase = TimerPhase.stopped;
    _activePointerIds.clear();
    _isLeftKeyDown = false;
    _isRightKeyDown = false;
    _isSpaceKeyDown = false;
    notifyListeners();

    onSolveCompleted?.call(_elapsedMilliseconds);
  }

  void resetToIdle() {
    _ticker?.cancel();
    _armingTimer?.cancel();
    _releaseWindowTimer?.cancel();
    _phase = TimerPhase.idle;
    _isCanceled = false;
    _elapsedMilliseconds = 0;
    _activePointerIds.clear();
    _isLeftKeyDown = false;
    _isRightKeyDown = false;
    _isSpaceKeyDown = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _armingTimer?.cancel();
    _releaseWindowTimer?.cancel();
    super.dispose();
  }
}
