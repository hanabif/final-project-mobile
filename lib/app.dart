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
import '../l10n/settings_aware_app_localizations_delegate.dart';

class ComplaintResolutionApp extends StatelessWidget {
  const ComplaintResolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<ComplaintCubit>()),
        BlocProvider.value(value: sl<NotificationCubit>()),
        BlocProvider(create: (_) => sl<PasswordResetCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()..loadSettings()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          ThemeMode mode = ThemeMode.system;
          // `frameworkLocale` is used for framework delegates (Material/Cupertino).
          // `appLocaleOverride` is used to override only `AppLocalizations` so
          // we can load app strings in Oromo while keeping framework delegates
          // on a supported locale (English/Amharic).
          Locale frameworkLocale = const Locale('en');
          Locale appLocaleOverride = const Locale('en');
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
            final langVal = state.settings.language.toLowerCase();
            if (langVal.contains('am') ||
                langVal.contains('amh') ||
                langVal.contains('amharic')) {
              frameworkLocale = const Locale('am');
              appLocaleOverride = const Locale('am');
            } else if (langVal.contains('om') ||
                langVal.contains('orom') ||
                langVal.contains('afaan')) {
              // Framework delegates don't support 'om'. Use English for framework,
              // but override AppLocalizations to load Oromo translations.
              frameworkLocale = const Locale('en');
              appLocaleOverride = const Locale('om');
            } else {
              frameworkLocale = const Locale('en');
              appLocaleOverride = const Locale('en');
            }
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CityVoice',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            locale: frameworkLocale,
            scaffoldMessengerKey: scaffoldMessengerKey,
            navigatorKey: navigatorKey,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRouter.generateRoute,

            // localization delegates
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              // Use settings-aware delegate so AppLocalizations loads the
              // correct language based on persisted settings without
              // overriding framework delegates.
              SettingsAwareAppLocalizationsDelegate(),
            ],

            // supported locale (framework/localization delegates may not support 'om' yet)
            supportedLocales: const [Locale('en'), Locale('am')],
            // No special builder: the SettingsAware delegate returns the
            // appropriate `AppLocalizations` instance based on stored settings.
          );
        },
      ),
    );
  }
}
