# تطبيق صحتي بلس (Sehaty Plus)

تطبيق صحتي بلس هو منصة متكاملة لإدارة المواعيد الطبية والسجلات الصحية، يربط بين المرضى والأطباء والمستشفيات في نظام موحد.

## المميزات الرئيسية

- **للمرضى**: حجز المواعيد، عرض السجلات الطبية، تقييم الأطباء
- **للأطباء**: إدارة المواعيد، الاطلاع على السجلات الطبية للمرضى، إضافة ملاحظات طبية
- **للمستشفيات**: إدارة الأقسام، الأطباء، والمواعيد
- **للمسؤولين**: إدارة كاملة للنظام، المستخدمين، والمنشآت الصحية

## التقنيات المستخدمة

- **Flutter**: لتطوير واجهة المستخدم
- **Supabase**: لقاعدة البيانات والمصادقة
- **PostgreSQL**: لتخزين البيانات
- **Flutter Screenutil**: للتصميم المتجاوب

## الاتصال بقاعدة البيانات

يدعم التطبيق الاتصال بقاعدة بيانات Supabase بطريقتين:

### 1. الاتصال المباشر بـ Supabase

هذه هي الطريقة الافتراضية في بيئة التطوير. يتم الاتصال مباشرة بخدمة Supabase باستخدام عنوان URL ومفتاح API.

### 2. الاتصال من خلال سيرفر MCP

في بيئات الاختبار والإنتاج، يمكن توجيه الاتصال من خلال سيرفر MCP (Management Control Panel). هذا يوفر طبقة إضافية من الأمان والتحكم.

## تكوين البيئة

يمكن تكوين البيئة التي يعمل فيها التطبيق باستخدام متغير البيئة `ENVIRONMENT`:

```bash
# لتشغيل التطبيق في بيئة التطوير (الافتراضي)
flutter run

# لتشغيل التطبيق في بيئة الاختبار
flutter run --dart-define=ENVIRONMENT=staging

# لتشغيل التطبيق في بيئة الإنتاج
flutter run --dart-define=ENVIRONMENT=production
```

## تكوين مفتاح Supabase

يمكن تكوين مفتاح Supabase باستخدام متغير البيئة `SUPABASE_KEY`:

```bash
flutter run --dart-define=SUPABASE_KEY=your_supabase_key
```

## إعداد سيرفر MCP

لإعداد سيرفر MCP للعمل كوسيط بين التطبيق وخدمة Supabase، يجب اتباع الخطوات التالية:

1. إعداد سيرفر ويب (مثل Nginx أو Apache) على سيرفر MCP.
2. تكوين الوكيل (proxy) لتوجيه الطلبات إلى خدمة Supabase.

### مثال على تكوين Nginx:

```nginx
server {
    listen 80;
    server_name mcp-server.example.com;

    location /supabase-proxy/ {
        proxy_pass https://ivxlvztnwsurquebshgh.supabase.co/;
        proxy_set_header Host ivxlvztnwsurquebshgh.supabase.co;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## تعديل إعدادات الاتصال

يمكن تعديل إعدادات الاتصال في ملف `lib/core/config/environment_config.dart` حسب الحاجة.

## التثبيت والتشغيل

1. تأكد من تثبيت Flutter SDK على جهازك
2. استنساخ المشروع:
   ```bash
   git clone https://github.com/shehabzaid/app.git
   cd app
   ```
3. تثبيت التبعيات:
   ```bash
   flutter pub get
   ```
4. تشغيل التطبيق:
   ```bash
   flutter run
   ```

## الإصدارات المتاحة

### Android
يمكنك بناء نسخة Android باستخدام:
```bash
flutter build apk --release
```
ستجد ملف APK في `build/app/outputs/flutter-apk/app-release.apk`

### iOS
لبناء نسخة iOS، راجع التعليمات في [دليل بناء iOS](ios/README_IOS_BUILD.md)

### نسخة الويب
تم بناء نسخة ويب يمكن استخدامها على أي جهاز بما في ذلك أجهزة iPhone. لمزيد من المعلومات، راجع [دليل نسخة الويب](README_WEB_VERSION.md)

## هيكل المشروع

```
lib/
├── core/                  # المكونات الأساسية للتطبيق
│   ├── config/            # ملفات الإعدادات
│   ├── navigation/        # التنقل بين الشاشات
│   ├── routes/            # تعريف المسارات
│   ├── theme/             # سمات التطبيق
│   └── widgets/           # الويدجت المشتركة
├── features/              # ميزات التطبيق
│   ├── admin/             # واجهات المسؤول
│   ├── appointments/      # إدارة المواعيد
│   ├── auth/              # المصادقة وإدارة المستخدمين
│   ├── doctors/           # واجهات الأطباء
│   ├── hospitals/         # إدارة المستشفيات
│   ├── medical_records/   # السجلات الطبية
│   ├── notifications/     # الإشعارات
│   ├── patients/          # واجهات المرضى
│   └── reviews/           # تقييمات الأطباء
└── main.dart              # نقطة بداية التطبيق
```

## المساهمة

نرحب بمساهماتكم في تطوير هذا المشروع. يرجى اتباع الخطوات التالية:

1. عمل Fork للمشروع
2. إنشاء فرع جديد للميزة: `git checkout -b feature/amazing-feature`
3. عمل Commit للتغييرات: `git commit -m 'إضافة ميزة رائعة'`
4. رفع الفرع: `git push origin feature/amazing-feature`
5. فتح طلب Pull Request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - انظر ملف [LICENSE](LICENSE) للتفاصيل.
