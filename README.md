# complaint_resolution_app

A new Flutter project.

## Authentication Overview

This application includes a secure authentication feature built with a
layered architecture (clean architecture) and the following security
measures:

1. **Token-based sessions** – the backend returns a JWT token after a
   successful login/registration. The token is stored using
   `flutter_secure_storage` and added to every HTTP request via an
   interceptor in `ApiClient`.
2. **Client-side validation** – login/registration forms validate the
   email format and enforce a minimum password length (6 characters)
   before submitting credentials to the server.
3. **Session expiration checking** – the token payload is decoded on the
   client and its `exp` claim is verified; expired tokens are considered
   invalid and the user is prompted to log in again.
4. **Logout support** – a `LogoutUseCase` clears stored session data
   (currently wired to business logic; UI logout button is pending).
5. **Secure storage abstraction** – `SecureStorageService` wraps
   `flutter_secure_storage` to isolate platform details and make tests
   easier.
6. **Error feedback** – authentication failures produce user-visible
   snackbars with non-sensitive messages (for example, "Invalid
   credentials"), avoiding exposure of raw errors.

### Key components

- `AuthCubit` – handles UI state transitions, exposes `login`/`register`
  methods and reports `AuthLoading`, `AuthAuthenticated`, and
  `AuthError` states.
- `AuthRepositoryImpl` – interacts with `AuthRemoteDataSource` and
  `SessionRepository` to perform network calls and persist tokens.
- `SessionRepositoryImpl` – implements token storage and validation logic.
- `ApiClient` – attaches the token header automatically to `dio` requests.

## User Instructions for Secure Login

1. Launch the app; the `LoginPage` is presented by default.
2. Enter a **valid email address** (e.g. `user@example.com`) and a
   password with at least 6 characters.
3. Tap **Login**. If the credentials are correct, a "Login successful"
   message appears and you are navigated to the home screen. If there
   is an error (invalid credentials, network issue, etc.), an error
   snackbar appears with appropriate guidance.
4. To register a new account, tap "Don’t have an account? Register" and
   fill out the registration form with the same validation rules.
5. After logging in, the session token will be stored securely and used
   for subsequent API calls. If the token expires or is invalid, the
   user will need to log in again.
6. Currently there is no visible logout button; use the provided
   `LogoutUseCase` in the presentation layer to implement one.

## Development Notes

- Tests covering authentication flow exist under `test/auth` and verify
  repository, use-case, and UI behaviour including secure storage and
  header injection.
- Dependencies include `flutter_bloc`, `dio`, and `flutter_secure_storage`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
