import 'package:complaint_resolution_app/features/auth/domain/usecases/get_token_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/save_token_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/is_session_valid_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockSessionRepository session;
  late MockAuthRepository authRepo;
  late SaveTokenUseCase saveUse;
  late GetTokenUseCase getUse;
  late LogoutUseCase logoutUse;
  late IsSessionValidUseCase validUse;

  setUp(() {
    session = MockSessionRepository();
    authRepo = MockAuthRepository();
    saveUse = SaveTokenUseCase(session);
    getUse = GetTokenUseCase(session);
    logoutUse = LogoutUseCase(authRepo);
    validUse = IsSessionValidUseCase(session);
  });

  test('save and get token', () async {
    when(() => session.saveToken(any())).thenAnswer((_) async => {});
    when(() => session.getToken()).thenAnswer((_) async => 'tok');
    when(() => session.hasValidSession()).thenAnswer((_) async => true);

    await saveUse('tok');
    expect(await getUse(), 'tok');
    expect(await validUse(), isTrue);
    
    verify(() => session.saveToken('tok')).called(1);
  });

  test('logout calls repository logout', () async {
    when(() => authRepo.logout()).thenAnswer((_) async => {});
    
    await logoutUse();
    
    verify(() => authRepo.logout()).called(1);
  });
}
