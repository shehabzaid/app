# بناء تطبيق صحتي بلس لنظام iOS

## المتطلبات الأساسية

لبناء تطبيق iOS، ستحتاج إلى:

1. جهاز Mac يعمل بنظام macOS
2. Xcode مثبت (أحدث إصدار مفضل)
3. حساب Apple Developer (مدفوع - $99 سنويًا)
4. Flutter SDK مثبت على جهاز Mac

## خطوات البناء

### 1. نقل المشروع إلى جهاز Mac

قم بنقل مجلد المشروع بالكامل إلى جهاز Mac الخاص بك.

### 2. تثبيت التبعيات

افتح Terminal على جهاز Mac وانتقل إلى مجلد المشروع، ثم قم بتنفيذ:

```bash
flutter pub get
```

### 3. فتح المشروع في Xcode

```bash
cd ios
open Runner.xcworkspace
```

### 4. تكوين إعدادات التوقيع

1. في Xcode، حدد مشروع "Runner" من شريط التنقل
2. انتقل إلى علامة التبويب "Signing & Capabilities"
3. قم بتسجيل الدخول بحساب Apple Developer الخاص بك
4. حدد فريق التطوير الخاص بك
5. قم بتحديث "Bundle Identifier" إذا لزم الأمر (يجب أن يكون فريدًا)

### 5. تحديث ملف ExportOptions.plist

قم بتحديث ملف `ExportOptions.plist` بمعرف الفريق الخاص بك وملف التوقيع المناسب.

### 6. بناء التطبيق للاختبار

يمكنك بناء التطبيق للاختبار على جهازك باستخدام:

```bash
flutter build ios --debug
```

ثم قم بتشغيله على جهاز متصل أو محاكي من خلال Xcode.

### 7. بناء ملف IPA للتوزيع

#### للاختبار (TestFlight)

```bash
flutter build ipa --export-options-plist=ExportOptions.plist
```

#### للنشر على App Store

1. قم بتعديل ملف `ExportOptions.plist` وتغيير `method` إلى `app-store`
2. ثم قم بتنفيذ:

```bash
flutter build ipa --export-options-plist=ExportOptions.plist
```

### 8. رفع التطبيق إلى App Store Connect

استخدم Xcode أو أداة Application Loader لرفع ملف IPA إلى App Store Connect:

```bash
xcrun altool --upload-app --file build/ios/ipa/صحتي_بلس.ipa --username your_apple_id@example.com --password your_app_specific_password
```

## ملاحظات هامة

- يجب أن يكون لديك حساب Apple Developer مدفوع لتوزيع التطبيق على App Store
- تأكد من إكمال جميع متطلبات App Store قبل الإرسال (سياسة الخصوصية، وصف التطبيق، لقطات الشاشة، إلخ)
- قد تحتاج إلى إضافة أذونات إضافية في ملف Info.plist حسب ميزات التطبيق

## استكشاف الأخطاء وإصلاحها

إذا واجهت مشاكل في التوقيع أو البناء:

1. تأكد من تحديث Xcode إلى أحدث إصدار
2. تحقق من صلاحية شهادة التطوير الخاصة بك
3. تأكد من أن ملف التوقيع المؤقت صالح ومرتبط بمعرف الحزمة الخاص بك
4. قم بتنظيف المشروع وإعادة البناء:

```bash
flutter clean
flutter pub get
flutter build ios
```
