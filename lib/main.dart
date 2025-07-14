import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/todo_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 알림 서비스 초기화
  await NotificationService().initialize();

  // 앱 시작 시 배지 및 알림 초기화
  await NotificationService().clearAllNotificationsAndBadge();

  //화면 세로 고정
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());

  // FlutterNativeSplash.remove(); // 여기서 제거하지 않고 AppInitializer에서 제거
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아올 때 배지 초기화
    if (state == AppLifecycleState.resumed) {
      _clearBadgeOnAppResume();
    }
  }

  Future<void> _clearBadgeOnAppResume() async {
    try {
      await NotificationService().clearAllNotificationsAndBadge();
      debugPrint('앱 포그라운드 진입 - 배지 초기화 완료');
    } catch (e) {
      debugPrint('앱 포그라운드 진입 - 배지 초기화 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: MaterialApp.router(
        title: '하루살이',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko', 'KR')],
        // 새로운 테마 시스템 적용
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // 시스템 설정에 따라 자동 전환
        routerConfig: appRouter,
        builder: (context, child) {
          // 앱 전체를 AppInitializer로 감싸서 TodoProvider 초기화 보장
          return AppInitializer(child: child ?? const SizedBox());
        },
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeProviders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 초기화 완료 후 스플래시 제거
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FlutterNativeSplash.remove();
        });

        // 초기화 완료 후 실제 앱 화면 표시
        return child;
      },
    );
  }

  /// 모든 Provider들을 초기화
  Future<void> _initializeProviders(BuildContext context) async {
    try {
      // 1. SettingsProvider 초기화 (설정 먼저 로드)
      await context.read<SettingsProvider>().initialize();

      // 2. TodoProvider 초기화 (할 일 관리)
      await context.read<TodoProvider>().initialize(context);

      if (kDebugMode) {
        print('모든 Provider 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Provider 초기화 중 오류: $e');
      }
    }
  }
}
