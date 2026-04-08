<?php
// ==================== 1. НАСТРОЙКИ ====================
$serviceAccountPath = __DIR__ . '/service-account.json';

if (!file_exists($serviceAccountPath)) {
    die("Не найден файл service-account.json рядом со скриптом!\n");
}

$sa = json_decode(file_get_contents($serviceAccountPath), true);
$projectId = $sa['project_id'];

// ==================== 2. ПОЛУЧАЕМ ACCESS TOKEN ====================
function base64url_encode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

$now = time();
$header = ['alg' => 'RS256', 'typ' => 'JWT'];
$claims = [
    'iss'   => $sa['client_email'],
    'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
    'aud'   => 'https://oauth2.googleapis.com/token',
    'iat'   => $now,
    'exp'   => $now + 3600
];

$jwtHeader = base64url_encode(json_encode($header));
$jwtClaims = base64url_encode(json_encode($claims));
$unsignedJwt = $jwtHeader . '.' . $jwtClaims;

$privateKey = $sa['private_key'];
openssl_sign($unsignedJwt, $signature, $privateKey, OPENSSL_ALGO_SHA256);
$signedJwt = $unsignedJwt . '.' . base64url_encode($signature);

$ch = curl_init('https://oauth2.googleapis.com/token');
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion'  => $signedJwt
    ]),
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded']
]);
$response = curl_exec($ch);
curl_close($ch);

$tokenResponse = json_decode($response, true);
if (empty($tokenResponse['access_token'])) {
    die("Не удалось получить access_token:\n$response\n");
}
$accessToken = $tokenResponse['access_token'];

echo "Access token получен успешно!\n\n";

// ==================== 3. ФОРМИРУЕМ УВЕДОМЛЕНИЕ ====================
date_default_timezone_set('Europe/Moscow');
$moscowTime = date('d.m.Y H:i');

$message = [
    'message' => [
        // !!! Для топика iOS должен быть подписан !!!
        'topic' => 'all',

        // Универсальный notification (для Android и iOS)
        'notification' => [
            'title' => 'FCM Demo Push',
            'body'  => "Время отправки: {$moscowTime}",
            "image" => "https://picsum.photos/800/400" // картинка для Android + iOS


        ],

        // Данные для Flutter
        'data' => [
            'type'    => 'demo',
            'sent_at' => $moscowTime
        ],

        // ANDROID-НАСТРОЙКИ
        'android' => [
            'priority' => 'high',
            'ttl'      => '3600s',
            'notification' => [
                'channel_id'  => 'default_channel',
                'icon'        => 'ic_stat_rocket',
                'color'       => '#00C853',
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
            ]
        ],

        // iOS (APNs) — ОБЯЗАТЕЛЬНО
        'apns' => [
            'headers' => [
                'apns-priority'  => '10',     // мгновенно
                'apns-push-type' => 'alert'   // обязательно для iOS 13+
            ],
            'payload' => [
                'aps' => [
                    'alert' => [
                        'title' => 'FCM Demo Push (iOS)',
                        'body'  => "Время отправки: {$moscowTime}"
                    ],
                    'sound' => 'default'
                ]
            ]
        ]
    ]
];

// ==================== 4. ОТПРАВЛЯЕМ ====================
$fcmUrl = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

$ch = curl_init($fcmUrl);
curl_setopt_array($ch, [
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => json_encode($message, JSON_UNESCAPED_UNICODE),
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => [
        "Authorization: Bearer {$accessToken}",
        "Content-Type: application/json; charset=utf-8"
    ]
]);

$res = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP {$httpCode}\n\n";
echo "Ответ Firebase:\n{$res}\n\n";

if ($httpCode == 200) {
    echo "Уведомление успешно отправлено! Проверь устройство.\n";
} else {
    echo "Ошибка — проверь JSON или конфигурацию APNs.\n";
}
