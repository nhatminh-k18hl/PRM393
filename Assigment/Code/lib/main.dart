import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/origami_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force strict orientation lock (landscapeLeft & landscapeRight)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => OrigamiProvider()),
      ],
      child: const Origami3DApp(),
    ),
  );
}

class Origami3DApp extends StatelessWidget {
  const Origami3DApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settings, child) {
        final isLightTheme = settings.activeTheme == AppTheme.LIGHT_CLASSIC ||
            settings.activeTheme == AppTheme.SEPIA_WARM;
        
        return MaterialApp(
          title: 'Origami 3D Master',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: settings.primaryColor,
            scaffoldBackgroundColor: settings.backgroundColor,
            fontFamily: settings.currentFont,
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.primaryColor,
              primary: settings.primaryColor,
              background: settings.backgroundColor,
              brightness: isLightTheme ? Brightness.light : Brightness.dark,
            ),
            textTheme: Theme.of(context).textTheme.apply(
              fontFamily: settings.currentFont,
              bodyColor: settings.textColor,
              displayColor: settings.textColor,
            ),
          ),
          home: const SplashScreen(),
          builder: (context, widget) {
            if (widget == null) return const SizedBox.shrink();
            return LayoutScalingWrapper(
              scale: settings.globalScale,
              child: widget,
            );
          },
        );
      },
    );
  }
}

class LayoutScalingWrapper extends StatelessWidget {
  final double scale;
  final Widget child;

  const LayoutScalingWrapper({
    Key? key,
    required this.scale,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scale == 1.0) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final double scaledWidth = width / scale;
        final double scaledHeight = height / scale;

        return FractionallySizedBox(
          widthFactor: 1.0 / scale,
          heightFactor: 1.0 / scale,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: scaledWidth,
              height: scaledHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
