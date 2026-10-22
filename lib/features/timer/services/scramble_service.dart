import 'dart:math';

/// Service generating WCA-style scrambles for various puzzle types.
class ScrambleService {
  final Random _random = Random();

  /// Generates a randomized scramble for the provided profile ID.
  String generateScramble(String profileId) {
    switch (profileId) {
      case '2x2':
        return _scramble2x2();
      case '3x3':
        return _scramble3x3();
      case '4x4':
        return _scramble4x4();
      case '5x5':
        return _scramble5x5();
      case 'pyraminx':
        return _scramblePyraminx();
      default:
        return _scramble3x3();
    }
  }

  String _scramble2x2() {
    const faces = ['R', 'U', 'F'];
    const modifiers = ['', "'", '2'];
    return _generateMoves(faces, modifiers, length: 10);
  }

  String _scramble3x3() {
    const faces = ['R', 'L', 'U', 'D', 'F', 'B'];
    const modifiers = ['', "'", '2'];
    return _generateMoves(faces, modifiers, length: 21);
  }

  String _scramble4x4() {
    const faces = ['R', 'L', 'U', 'D', 'F', 'B', 'Rw', 'Uw', 'Fw'];
    const modifiers = ['', "'", '2'];
    return _generateMoves(faces, modifiers, length: 36);
  }

  String _scramble5x5() {
    const faces = ['R', 'L', 'U', 'D', 'F', 'B', 'Rw', 'Lw', 'Uw', 'Dw', 'Fw', 'Bw'];
    const modifiers = ['', "'", '2'];
    return _generateMoves(faces, modifiers, length: 50);
  }

  String _scramblePyraminx() {
    const mainMoves = ['U', 'L', 'R', 'B'];
    const modifiers = ['', "'"];
    final main = _generateMoves(mainMoves, modifiers, length: 11);

    // Add tips
    const tips = ['u', 'l', 'r', 'b'];
    final List<String> activeTips = [];
    for (final tip in tips) {
      if (_random.nextBool()) {
        final mod = modifiers[_random.nextInt(modifiers.length)];
        activeTips.add('$tip$mod');
      }
    }
    return activeTips.isEmpty ? main : '$main ${activeTips.join(" ")}';
  }

  String _generateMoves(List<String> faces, List<String> modifiers, {required int length}) {
    final List<String> moves = [];
    String lastFace = '';
    String secondLastFace = '';

    while (moves.length < length) {
      final face = faces[_random.nextInt(faces.length)];
      if (face == lastFace || (face == secondLastFace && _isOpposite(face, lastFace))) {
        continue;
      }
      final mod = modifiers[_random.nextInt(modifiers.length)];
      moves.add('$face$mod');
      secondLastFace = lastFace;
      lastFace = face;
    }
    return moves.join(' ');
  }

  bool _isOpposite(String a, String b) {
    if ((a == 'R' && b == 'L') || (a == 'L' && b == 'R')) return true;
    if ((a == 'U' && b == 'D') || (a == 'D' && b == 'U')) return true;
    if ((a == 'F' && b == 'B') || (a == 'B' && b == 'F')) return true;
    return false;
  }
}
