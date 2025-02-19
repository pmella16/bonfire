import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding random movement like enemy walking through the scene
mixin AutomaticRandomMovement on Movement {
  Vector2 _targetRandomMovement = Vector2.zero();
  // ignore: constant_identifier_names
  static const _KEY_INTERVAL_KEEP_STOPPED = 'INTERVAL_RANDOM_MOVEMENT';

  /// Method that bo used in [update] method.
  void runRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double speed = 20,
    int maxDistance = 50,
    int minDistance = 0,
    int timeKeepStopped = 2000,
    bool useAngle = false,

    /// milliseconds
  }) {
    if (runOnlyVisibleInCamera && !isVisible) return;
    if (_targetRandomMovement == Vector2.zero()) {
      if (checkInterval(_KEY_INTERVAL_KEEP_STOPPED, timeKeepStopped, dt)) {
        int randomX = Random().nextInt(maxDistance);
        randomX = randomX < minDistance ? minDistance : randomX;
        int randomY = Random().nextInt(maxDistance);
        randomY = randomY < minDistance ? minDistance : randomY;
        int randomNegativeX = Random().nextBool() ? -1 : 1;
        int randomNegativeY = Random().nextBool() ? -1 : 1;
        final rect = rectConsideringCollision;
        double margin = max(rect.width, rect.height) / 2;
        _targetRandomMovement = rect.center.toVector2().translate(
              (randomX.toDouble() + margin) * randomNegativeX,
              (randomY.toDouble() + margin) * randomNegativeY,
            );
        if (useAngle) {
          angle = BonfireUtil.angleBetweenPoints(
              rectConsideringCollision.center.toVector2(),
              _targetRandomMovement);
        }
      }
    } else {
      bool canMoveX = (_targetRandomMovement.x - x).abs() > speed;
      bool canMoveY = (_targetRandomMovement.y - y).abs() > speed;

      bool canMoveLeft = false;
      bool canMoveRight = false;
      bool canMoveUp = false;
      bool canMoveDown = false;
      if (canMoveX) {
        if (_targetRandomMovement.x > x) {
          canMoveRight = true;
        } else {
          canMoveLeft = true;
        }
      }
      if (canMoveY) {
        if (_targetRandomMovement.y > y) {
          canMoveDown = true;
        } else {
          canMoveUp = true;
        }
      }
      bool onMove = false;
      if (useAngle) {
        if (canMoveX && canMoveY) {
          onMove = moveFromAngle(speed, angle);
        }
      } else {
        if (canMoveLeft && canMoveUp) {
          onMove = moveUpLeft(speed, speed);
        } else if (canMoveLeft && canMoveDown) {
          onMove = moveDownLeft(speed, speed);
        } else if (canMoveRight && canMoveUp) {
          onMove = moveUpRight(speed, speed);
        } else if (canMoveRight && canMoveDown) {
          onMove = moveDownRight(speed, speed);
        } else if (canMoveRight) {
          onMove = moveRight(speed);
        } else if (canMoveLeft) {
          onMove = moveLeft(speed);
        } else if (canMoveUp) {
          onMove = moveUp(speed);
        } else if (canMoveDown) {
          onMove = moveDown(speed);
        }
      }

      if (!onMove) {
        _cleanTargetMovementRandom();
      }
    }
  }

  void _cleanTargetMovementRandom() {
    _targetRandomMovement = Vector2.zero();
    idle();
  }
}
