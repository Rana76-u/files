import 'package:files/Screens/Hidden/Hidden%20Home/hidden_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'Bloc/Calculator Logics/cubits/history/history_cubit.dart';
import 'Bloc/Calculator Logics/cubits/theme/theme_cubit.dart';
import 'Themes/app_theme.dart';
import 'Widgets/app_router.dart';
import 'components/custom_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryCubit>(
          create: (context) => HistoryCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.select((ThemeCubit cubit) => cubit.state);

          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            //title: Config.appName,
            onGenerateRoute: AppRouter().onGenerateRoute,
            builder: (context, child) => ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: child ?? Container(),
            ),
          );
        },
      ),
    );
  }
}

/*return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const HiddenHome(),
          );*/