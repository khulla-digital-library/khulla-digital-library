import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/theme/cubit/theme_cubit.dart';

/// Root [BlocProvider]s for the widget tree.
///
/// App-wide cubits are resolved from the service locator here and nowhere
/// else — a widget deeper in the tree reads them with `context.read`, never
/// with `getIt`, so it stays testable by wrapping it in a provider.
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
    ],
    child: child,
  );
}
