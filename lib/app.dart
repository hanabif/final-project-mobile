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
import 'features/auth/presentation/cubit/password_reset/password_reset_cubit.dart';

class ComplaintResolutionApp extends StatelessWidget {
  const ComplaintResolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<ComplaintCubit>()),
        BlocProvider(create: (_) => sl<PasswordResetCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CityVoice',
        theme: AppTheme.lightTheme,
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorKey: navigatorKey,
        initialRoute: RouteNames.login,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
