import 'package:files/APIs/hive_api.dart';
import 'package:files/Bloc/Hidden%20Home%20Bloc/hidden_home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'Bloc/Calculator Logics/cubits/history/history_cubit.dart';
import 'Widgets/app_router.dart';
import 'components/custom_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if(Hive.isBoxOpen('userDetails')) {
    password = getFromHive('password')!;
  }
  else{
    await Hive.openBox<String>('userDetails');
    addToHive('password', '75+12');
    password = '75+12';
  }

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
        BlocProvider<HiddenHomeBloc>(
          create: (context) => HiddenHomeBloc(),
        ),
      ],
      child: Builder(
        builder: (context) {

          return GetMaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
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