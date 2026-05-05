import 'package:complaint_resolution_app/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/is_session_valid_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSession implements SessionRepository {
  String? token;
  @override
  Future<void> clearSession() async {
    token = null;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Future<bool> hasValidSession() async => token != null;

  @override
  Future<void> saveToken(String token) async {
    this.token = token;
  }
}

void main() {
  late FakeSession session;
  late SaveTokenUseCase saveUse;
  late GetTokenUseCase getUse;
  late LogoutUseCase logoutUse;
  late IsSessionValidUseCase validUse;

  setUp(() {
    session = FakeSession();
    saveUse = SaveTokenUseCase(session);
    getUse = GetTokenUseCase(session);
    logoutUse = LogoutUseCase(session);
    validUse = IsSessionValidUseCase(session);
  });

  test('save and get token', () async {
    await saveUse('tok');
    expect(await getUse(), 'tok');
    expect(await validUse(), isTrue);
  });

  test('logout clears token', () async {
    await saveUse('tok');
    await logoutUse();
    expect(await getUse(), isNull);
    expect(await validUse(), isFalse);
  });
}
