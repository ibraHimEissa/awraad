import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'state/book_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.headerFooter,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AwradApp());
}

class AwradApp extends StatelessWidget {
  const AwradApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookController(StorageService())..load(),
      child: MaterialApp(
        title: 'ديوان شراب الوصل',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        // The whole app is right-to-left.
        builder: (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const SplashScreen(),
      ),
    );
  }
}
