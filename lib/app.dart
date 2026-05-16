import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/utils/scaffold_messenger_key.dart';
import 'core/utils/navigator_key.dart';
import 'features/complaint/presentation/cubits/complaint_cubit.dart';
import 'features/complaint/presentation/cubits/home/home_cubit.dart';
import 'features/notification/presentation/cubit/notification_cubit.dart';
import 'features/auth/presentation/cubit/password_reset/password_reset_cubit.dart';
import 'features/settings/presentation/cubits/settings_cubit.dart';
import 'features/settings/presentation/cubits/settings_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

class ComplaintResolutionApp extends StatelessWidget {
  const ComplaintResolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<ComplaintCubit>()),
        BlocProvider(create: (_) => sl<NotificationCubit>()),
        BlocProvider(create: (_) => sl<PasswordResetCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()..loadSettings()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          ThemeMode mode = ThemeMode.system;
          Locale appLocale = const Locale('en');
          if (state is SettingsLoaded) {
            switch (state.settings.themeMode.toLowerCase()) {
              case 'light':
                mode = ThemeMode.light;
                break;
              case 'dark':
                mode = ThemeMode.dark;
                break;
              default:
                mode = ThemeMode.system;
            }

            switch (state.settings.language.toLowerCase()) {
              case 'am':
              case 'amharic':
                appLocale = const Locale('am');
                break;
              case 'en':
              case 'english':
              default:
                appLocale = const Locale('en');
            }
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CityVoice',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            locale: appLocale,
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorKey: navigatorKey,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,

             // localization delegates
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            
            // supported locale
            supportedLocales: const [
              Locale('en'),
              Locale('am'),
            ],
          );
        },
      ),
    );
  }
}
