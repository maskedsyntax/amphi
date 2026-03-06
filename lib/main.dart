import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/themes.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Media Kit
  MediaKit.ensureInitialized();

  // Initialize Window Manager
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: "Amphi Player",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: AmphiApp(),
    ),
  );
}

class AmphiApp extends ConsumerWidget {
  const AmphiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    ThemeData theme;
    if (themeMode == AppThemeMode.neubrutalism) {
      theme = AppThemes.neubrutalism(isDarkMode);
    } else {
      theme = AppThemes.classic(isDarkMode);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amphi Player',
      theme: theme,
      home: const MainScreen(),
    );
  }
}
