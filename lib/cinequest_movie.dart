import 'package:cinequest/src/common/bloc/app/app_bloc.dart';
import 'package:cinequest/src/common/bloc/connectivity/connectivity_bloc.dart';
import 'package:cinequest/src/core/di/injection_container.import.dart';
import 'package:cinequest/src/core/extensions/context_extension.dart';
import 'package:cinequest/src/core/routes/route_pages.dart';
import 'package:cinequest/src/core/themes/app_themes.dart';
import 'package:cinequest/src/core/utils/ui_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'cinequest_movie.mixin.dart';

/// App
class CineQuestMovie extends StatefulWidget {
  /// Constructor
  const CineQuestMovie({super.key});

  @override
  State<CineQuestMovie> createState() => _CineQuestMovieState();
}

class _CineQuestMovieState extends State<CineQuestMovie>
    with CineQuestMovieMixin {
  final router = RouterPages.router;

  @override
  Widget build(BuildContext context) {
    UiUtil.initialize(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityBloc(connectivityService: sl()),
        ),
        BlocProvider(
          create: (context) => AppBloc(
            firebaseAuth: sl(),
            getProfileUserUseCase: sl(),
            userRepository: sl(),
            getStorageService: sl(),
          )..add(const AppEvent.started()),
        ),
      ],
      child: MaterialApp.router(
        theme: AppThemes.darkTheme,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        builder: (context, child) {
          return Scaffold(
            body: MultiBlocListener(
              listeners: [
                BlocListener<ConnectivityBloc, ConnectivityState>(
                  listener: _listenerConnectivity,
                ),
                BlocListener<AppBloc, AppState>(
                  listener: _listenerApp,
                ),
              ],
              child: BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  return child!;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
