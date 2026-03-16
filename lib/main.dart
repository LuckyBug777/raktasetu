import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/presentation/bloc/auth_bloc.dart';
import 'package:raktasetu/presentation/bloc/donor_search_bloc.dart';
import 'package:raktasetu/presentation/pages/donor_search_page.dart';
import 'package:raktasetu/presentation/pages/login_page.dart';
import 'package:raktasetu/presentation/pages/splash_page.dart';

void main() {
  // Setup Service Locator (Dependency Injection)
  setupServiceLocator();

  runApp(const RaktaSetuApp());
}

class RaktaSetuApp extends StatelessWidget {
  const RaktaSetuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => getIt<DonorSearchBloc>()),
      ],
      child: MaterialApp(
        title: 'RaktaSetu - Blood Donation',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => BlocProvider(
            create: (context) => getIt<DonorSearchBloc>(),
            child: const DonorSearchPage(),
          ),
        },
      ),
    );
  }
}
