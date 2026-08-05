# Azam Mobile Flutter (Android)

هذا تطبيق Flutter (Android) متكامل مع نظام عزام عبر API ويدعم RTL والعربية.

## المتطلبات
- Flutter 3.3+ و Android SDK

## الإعداد السريع
1. عدّل إعدادات الخادم في التطبيق من شاشة "إعداد الاتصال" (BASE_URL و X-Azam-Token).
2. من مشروع Flutter:
```bash
flutter pub get
flutter run -d <android_device>
```
أو لبناء APK:
```bash
flutter build apk --release
```
ستجده في `build/app/outputs/flutter-apk/app-release.apk`.

## الربط مع النظام
- GET: `/api/changes.php` (since, tables, limit)
- POST: `/api/apply_changes.php` (JSON upserts)

## القادم
- إضافة SQLite محلي، شاشات العملاء/الفواتير، مزامنة Pull/Push كاملة، وتبادل Zip.
