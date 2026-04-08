# Vitrina Plus

Flutter WebView приложение с интеграцией Firebase Cloud Messaging для платформы Vitrina Plus.

## Особенности

- 🌐 WebView с поддержкой JavaScript bridge
- 🔔 Push-уведомления через Firebase Cloud Messaging
- 📱 Поддержка iOS и Android
- 🔗 Обработка внешних ссылок (tel:, mailto:, внешние URL)
- 🎨 Кастомный splash screen
- 🔐 Управление разрешениями (камера, микрофон, геолокация)

## Структура проекта

```
lib/
├── core/
│   ├── config/          # Конфигурация (Firebase)
│   ├── constants/       # Константы приложения
│   ├── services/        # Бизнес-логика (Firebase, Permissions, WebView Bridge)
│   └── utils/           # Утилиты (ScrollBehavior)
├── screens/             # UI экраны
│   ├── splash_screen.dart
│   └── webview_screen.dart
├── firebase_options.dart
└── main.dart
```

## Требования

- Flutter SDK: >=2.15.1 <3.0.0
- Dart SDK: >=2.15.1 <3.0.0
- iOS: 12.0+
- Android: API 21+ (Android 5.0)

## Установка

1. Клонируйте репозиторий
2. Установите зависимости:
```bash
flutter pub get
```

3. Настройте Firebase:
   - Добавьте `google-services.json` в `android/app/`
   - Добавьте `GoogleService-Info.plist` в `ios/Runner/`

4. Запустите приложение:
```bash
flutter run
```

## Конфигурация

### Firebase Cloud Messaging

Приложение автоматически:
- Запрашивает разрешения на уведомления
- Получает FCM токен
- Подписывается на топик "all"
- Обрабатывает уведомления в foreground, background и terminated состояниях

### WebView Bridge

JavaScript bridge позволяет веб-сайту получать FCM токен:

```javascript
// На веб-сайте
const token = window.AndroidBridge.getFCMToken();

// Или через callback
window.onFCMTokenReceived = function(token) {
  console.log('FCM Token:', token);
};
```

## Основные компоненты

### Services

- **FirebaseMessagingService**: Управление push-уведомлениями
- **PermissionService**: Запрос разрешений
- **WebViewBridgeService**: Коммуникация между Flutter и JavaScript

### Screens

- **SplashScreen**: Экран загрузки (6 секунд)
- **WebViewScreen**: Основной экран с WebView

## Разработка

### Добавление новых констант

Редактируйте `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String newConstant = 'value';
}
```

### Добавление новых сервисов

1. Создайте файл в `lib/core/services/`
2. Реализуйте singleton паттерн
3. Добавьте документацию

### Тестирование

```bash
# Запуск тестов
flutter test

# Анализ кода
flutter analyze

# Форматирование
flutter format lib/
```

## Сборка

### Android

```bash
flutter build apk --release
# или
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Зависимости

- `firebase_core`: ^4.2.0
- `firebase_messaging`: ^16.0.3
- `flutter_local_notifications`: ^19.5.0
- `flutter_inappwebview`: ^6.0.0
- `permission_handler`: ^11.3.1
- `url_launcher`: ^6.3.2
- `app_tracking_transparency`: ^2.0.6+1

## Лицензия

Proprietary - Все права защищены

## Поддержка

Для вопросов и поддержки обращайтесь к команде разработки Vitrina Plus.
# malina_app
# malina_app
