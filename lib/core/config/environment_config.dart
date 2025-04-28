enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _environment = Environment.development;
  
  // تعيين البيئة الحالية
  static void setEnvironment(Environment environment) {
    _environment = environment;
  }
  
  // الحصول على البيئة الحالية
  static Environment get environment => _environment;
  
  // هل نحن في بيئة التطوير؟
  static bool get isDevelopment => _environment == Environment.development;
  
  // هل نحن في بيئة الاختبار؟
  static bool get isStaging => _environment == Environment.staging;
  
  // هل نحن في بيئة الإنتاج؟
  static bool get isProduction => _environment == Environment.production;
  
  // الحصول على عنوان URL لخدمة Supabase
  static String get supabaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://ivxlvztnwsurquebshgh.supabase.co';
      case Environment.staging:
        // استخدام سيرفر MCP في بيئة الاختبار
        return 'https://mcp-server.example.com/supabase-proxy';
      case Environment.production:
        // استخدام سيرفر MCP في بيئة الإنتاج
        return 'https://mcp-server.example.com/supabase-proxy';
    }
  }
  
  // الحصول على مفتاح Supabase
  static String get supabaseKey {
    // المفتاح الجديد الذي قدمه المستخدم
    const defaultKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2eGx2enRud3N1cnF1ZWJzaGdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ2NTc1ODMsImV4cCI6MjA2MDIzMzU4M30.huKnQQ6BH14pqpsB0wbYONgA9v7ZGc0LEYHbnz-y07s';
    
    // محاولة الحصول على المفتاح من متغيرات البيئة
    final envKey = const String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
    
    // إذا كان المفتاح غير موجود في متغيرات البيئة، استخدم المفتاح الافتراضي
    if (envKey.isEmpty) {
      return defaultKey;
    }
    
    return envKey;
  }
  
  // الحصول على عنوان URL لسيرفر MCP
  static String get mcpServerUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:8080';
      case Environment.staging:
        return 'https://mcp-server.example.com';
      case Environment.production:
        return 'https://mcp-server.example.com';
    }
  }
}
