# تطبيق صحتي بلس

تطبيق صحتي بلس هو تطبيق للمواعيد الطبية والسجلات الصحية.

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
