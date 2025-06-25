# 🌱 HaruTodo

> **오늘 하루에만 집중하는 할 일 관리 앱**

![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

HaruTodo는 **1-3-5 법칙**을 기반으로 한 하루 집중형 할 일 관리 앱입니다. 내일이나 모레의 계획으로 인한 부담감을 없애고, 오늘 하루에만 온전히 집중할 수 있도록 도와줍니다.

## ✨ 주요 특징

### 🎯 1-3-5 법칙
- **1개**: 가장 중요하고 큰 일 (빨간색)
- **3개**: 중간 사이즈의 일들 (주황색)
- **5개**: 작은 일들/내일 해도 되는 일 (초록색)

### 🎨 직관적인 디자인
- Material Design 3 기반의 깔끔한 인터페이스
- 우선순위별 색상 구분 (좌측 색상 띠)
- 부드러운 애니메이션과 피드백

### 🏆 성취감 극대화
- 완료 시마다 따뜻한 격려 메시지
- 캘린더를 통한 완료 기록 시각화
- Undo 기능으로 실수 방지

### 📱 사용자 친화적 UX
- 인라인 할 일 추가/수정
- 스와이프로 간편 삭제
- 하루 시작 시간 맞춤 설정

## 📸 스크린샷

*스크린샷은 추후 추가 예정*

## 🛠 기술 스택

### Frontend
- **Flutter** 3.8.1+
- **Dart** 3.0+
- **Material Design 3**

### 상태 관리
- **Provider** 6.1.2

### 데이터베이스
- **sqflite** 2.4.1 (로컬 SQLite)

### 주요 패키지
- `table_calendar` 3.1.2 - 캘린더 위젯
- `flutter_staggered_animations` 1.1.1 - 리스트 애니메이션
- `lottie` 3.1.2 - 로티 애니메이션
- `intl` 0.19.0 - 국제화 및 날짜 포맷팅
- `path_provider` 2.1.1 - 파일 시스템 접근

## 🏗 프로젝트 구조

```
lib/
├── models/          # 데이터 모델
│   └── todo.dart
├── providers/       # 상태 관리 (Provider)
│   └── todo_provider.dart
├── screens/         # 화면 컴포넌트
│   ├── home_screen.dart
│   ├── calendar_screen.dart
│   └── settings_screen.dart
├── widgets/         # 재사용 가능한 위젯
│   ├── todo_card.dart
│   ├── inline_add_todo.dart
│   ├── completion_snackbar.dart
│   ├── progress_indicator.dart
│   └── empty_state.dart
├── services/        # 비즈니스 로직
│   └── database_service.dart
├── utils/           # 유틸리티
│   ├── colors.dart
│   ├── constants.dart
│   └── date_utils.dart
└── main.dart        # 앱 진입점
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK 3.0 이상
- Android Studio / VS Code
- Android SDK (Android 개발 시)
- Xcode (iOS 개발 시)

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone https://github.com/your-username/harutodo.git
   cd harutodo
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```

#### iOS (macOS에서만)
```bash
flutter build ios --release
```

## 🎮 사용법

### 기본 사용 흐름

1. **할 일 추가**
   - 메인 화면에서 + 버튼 클릭
   - 할 일 제목 입력
   - 색상 동그라미 클릭으로 우선순위 설정 (빨강→주황→초록)

2. **할 일 완료**
   - 체크박스 클릭으로 완료 처리
   - 격려 메시지와 함께 Undo 옵션 제공 (5초간)

3. **할 일 수정**
   - 할 일 카드 클릭으로 인라인 편집 모드 진입
   - 제목 및 우선순위 수정 가능

4. **할 일 삭제**
   - 할 일 카드를 왼쪽으로 스와이프
   - 확인 다이얼로그 후 삭제

5. **완료 기록 확인**
   - 캘린더 탭에서 과거 완료 기록 확인
   - 날짜별 우선순위 점으로 완료 현황 표시

### 설정

- **하루 시작 시간**: 개인 라이프스타일에 맞게 하루 시작 시간 설정
- **자동 정리**: 설정된 시간에 미완료 할 일 자동 삭제

## 🎯 핵심 철학

### 하루 집중
- 오늘 하루에만 집중하여 부담감 제거
- 미완료 할 일은 다음 날 자동 삭제
- 장기 계획으로 인한 스트레스 방지

### 적절한 할 일 양
- 1-3-5 법칙으로 과도한 할 일 방지
- 우선순위별 개수 제한으로 현실적인 계획 수립
- 완료 가능한 양의 할 일만 추가 가능

### 성취감 극대화
- 완료할 때마다 따뜻한 피드백
- 시각적 진행률 표시
- 캘린더를 통한 성취 기록 확인

## 🔧 개발자 정보

### 디버깅
```bash
# 디버그 모드로 실행
flutter run --debug

# 성능 프로파일링
flutter run --profile
```

### 테스트
```bash
# 단위 테스트 실행
flutter test

# 위젯 테스트 실행
flutter test test/widget_test.dart
```

### 코드 분석
```bash
# 코드 분석 실행
flutter analyze
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 🚀 로드맵

### v1.0 (현재)
- [x] 기본 할 일 CRUD 기능
- [x] 1-3-5 법칙 구현
- [x] 캘린더 완료 기록
- [x] 하루 전환 로직
- [x] Material Design 3 UI

### v1.1 (계획)
- [ ] 홈 화면 위젯
- [ ] 알림 기능
- [ ] 다양한 테마

### v2.0 (장기 계획)
- [ ] 클라우드 동기화
- [ ] 통계 및 분석
- [ ] 다국어 지원

## 📞 문의

프로젝트에 대한 질문이나 제안사항이 있으시면 언제든 연락주세요!

- 이메일: jtothemoon@naver.com
- 이슈: [GitHub Issues](https://github.com/jtothemoon/haru_todo/issues)

---

**"오늘 하루, 그것만으로도 충분합니다."** 🌱
