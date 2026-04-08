# Руководство по миграции

Этот документ описывает изменения в структуре проекта после рефакторинга.

## Изменения в импортах

### Было:
```dart
import 'package:website/splash_screen.dart';
import 'package:website/webview_page.dart';
import 'package:website/firebase_messaging_service.dart';
import 'package:website/connection.dart';
```

### Стало:
```dart
import 'package:website/screens/splash_screen.dart';
import 'package:website/screens/webview_screen.dart';
import 'package:website/core/services/firebase_messaging_service.dart';
import 'package:website/core/constants/app_constants.dart';
```

## Изменения в именах классов

| Было | Стало |
|------|-------|
| `WebviewPage` | `WebViewScreen` |
| `SplashScreen` | `SplashScreen` (без изменений) |
| `FirebaseMessagingService()` | `FirebaseMessagingService.instance` |

## Удаленные файлы

- ❌ `lib/animation_page.dart` - закомментированный код
- ❌ `lib/connection.dart` - неиспользуемый код connectivity
- ❌ Старые версии файлов в корне `lib/`

## Новые файлы

- ✅ `lib/core/config/firebase_config.dart` - конфигурация Firebase
- ✅ `lib/core/constants/app_constants.dart` - все константы
- ✅ `lib/core/services/permission_service.dart` - управление разрешениями
- ✅ `lib/core/services/webview_bridge_service.dart` - JavaScript bridge
- ✅ `lib/core/utils/scroll_behavior.dart` - кастомное поведение скролла

## Изменения в API

### Firebase Messaging Service

**Было:**
```dart
final service = FirebaseMessagingService();
await service.initialize();
```

**Стало:**
```dart
await FirebaseMessagingService.instance.initialize();
```

### Константы

**Было:**
```dart
const Duration(seconds: 6)
'https://vitrina.plus/'
'high_importance_channel'
```

**Стало:**
```dart
AppConstants.splashDuration
AppConstants.baseUrl
AppConstants.notificationChannelId
```

### WebView Controller

**Было:**
```dart
InAppWebViewController? webViewController; // Глобальная переменная
```

**Стало:**
```dart
class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController; // Приватное поле класса
}
```

## Миграция существующего кода

### Шаг 1: Обновите импорты

Замените все старые импорты на новые согласно таблице выше.

### Шаг 2: Обновите использование сервисов

```dart
// Было
final service = FirebaseMessagingService();
await service.subscribeToTopic("all");

// Стало
await FirebaseMessagingService.instance.subscribeToTopic(AppConstants.fcmTopic);
```

### Шаг 3: Замените магические значения на константы

```dart
// Было
Timer(const Duration(seconds: 6), () => ...);

// Стало
Timer(AppConstants.splashDuration, () => ...);
```

### Шаг 4: Обновите навигацию

```dart
// Было
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const WebviewPage(),
));

// Стало
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const WebViewScreen(),
));
```

## Проверка после миграции

1. Запустите анализ кода:
```bash
flutter analyze
```

2. Проверьте, что нет ошибок импорта:
```bash
flutter pub get
```

3. Запустите приложение:
```bash
flutter run
```

4. Проверьте функциональность:
   - ✅ Splash screen отображается 6 секунд
   - ✅ WebView загружается корректно
   - ✅ Push-уведомления работают
   - ✅ JavaScript bridge функционирует
   - ✅ Внешние ссылки открываются правильно

## Обратная совместимость

⚠️ **Внимание**: Этот рефакторинг НЕ обратно совместим. После миграции необходимо обновить весь код, использующий старые импорты и API.

## Поддержка

Если у вас возникли проблемы с миграцией, проверьте:
1. Все импорты обновлены
2. Используются новые имена классов
3. Константы импортированы из `AppConstants`
4. Сервисы используются через `.instance`

## Преимущества новой структуры

- 📁 Четкая организация кода
- 🔍 Легче найти нужный файл
- 🧪 Проще писать тесты
- 📈 Лучше масштабируется
- 🛠️ Удобнее поддерживать
