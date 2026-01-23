import 'auth_config.dart';
import 'auth_exceptions.dart';
import 'secure_storage_service.dart';

class RateLimiter {
  static Future<void> checkRateLimit() async {
    final attemptsStr = await SecureStorageService.read(
      key: AuthConfig.loginAttemptsKey,
    );
    final lastAttemptStr = await SecureStorageService.read(
      key: AuthConfig.lastAttemptKey,
    );

    final attempts = int.tryParse(attemptsStr ?? '0') ?? 0;
    final lastAttempt = lastAttemptStr != null
        ? DateTime.tryParse(lastAttemptStr)
        : null;

    if (lastAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(lastAttempt);

      if (timeSinceLastAttempt > AuthConfig.lockoutDuration) {
        await recordAttempt(reset: true);
        return;
      }

      if (attempts >= AuthConfig.maxLoginAttempts) {
        final retryAfter = lastAttempt.add(AuthConfig.lockoutDuration);
        final remainingTime = retryAfter.difference(DateTime.now());

        throw RateLimitException(
          'Too many login attempts. Please try again in ${remainingTime.inMinutes} minutes.',
          retryAfter,
        );
      }
    }
  }

  static Future<void> recordAttempt({bool reset = false}) async {
    if (reset) {
      await SecureStorageService.write(
        key: AuthConfig.loginAttemptsKey,
        value: '0',
      );
      return;
    }

    final attemptsStr = await SecureStorageService.read(
      key: AuthConfig.loginAttemptsKey,
    );
    final attempts = int.tryParse(attemptsStr ?? '0') ?? 0;

    await SecureStorageService.write(
      key: AuthConfig.loginAttemptsKey,
      value: (attempts + 1).toString(),
    );
    await SecureStorageService.write(
      key: AuthConfig.lastAttemptKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  static Future<void> resetAttempts() async {
    await SecureStorageService.write(
      key: AuthConfig.loginAttemptsKey,
      value: '0',
    );
  }
}