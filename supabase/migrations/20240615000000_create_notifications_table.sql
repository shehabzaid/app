-- إنشاء جدول الإشعارات
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT, -- نوع الإشعار (appointment, medical_record, etc.)
  reference_id TEXT, -- معرف المرجع (مثل معرف الموعد)
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- إنشاء فهرس على عمود user_id لتحسين سرعة استرجاع الإشعارات للمستخدمين
CREATE INDEX idx_notifications_user_id ON public.notifications (user_id);

-- إنشاء فهرس على عمود created_at لترتيب الإشعارات حسب التاريخ
CREATE INDEX idx_notifications_created_at ON public.notifications (created_at DESC);

-- إنشاء فهرس على عمود is_read لتصفية الإشعارات المقروءة وغير المقروءة
CREATE INDEX idx_notifications_is_read ON public.notifications (is_read);

-- تمكين سياسات أمان الصفوف (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- سياسة للمستخدمين المصادق عليهم لعرض إشعاراتهم فقط
CREATE POLICY "Users can view their own notifications" 
ON public.notifications 
FOR SELECT 
TO authenticated 
USING (user_id = auth.uid());

-- سياسة للمسؤولين لإدارة جميع الإشعارات
CREATE POLICY "Admins can manage all notifications" 
ON public.notifications 
FOR ALL 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.role = 'admin'
  )
);

-- منح الصلاحيات اللازمة
GRANT SELECT, INSERT, UPDATE ON public.notifications TO authenticated;

-- إضافة تعليقات توضيحية للجدول والأعمدة
COMMENT ON TABLE public.notifications IS 'جدول لتخزين إشعارات المستخدمين';
COMMENT ON COLUMN public.notifications.id IS 'المعرف الفريد للإشعار';
COMMENT ON COLUMN public.notifications.user_id IS 'معرف المستخدم الذي سيتلقى الإشعار';
COMMENT ON COLUMN public.notifications.title IS 'عنوان الإشعار';
COMMENT ON COLUMN public.notifications.body IS 'نص الإشعار (التفاصيل)';
COMMENT ON COLUMN public.notifications.type IS 'نوع الإشعار (موعد، سجل طبي، إلخ)';
COMMENT ON COLUMN public.notifications.reference_id IS 'معرف المرجع (مثل معرف الموعد)';
COMMENT ON COLUMN public.notifications.is_read IS 'هل قرأ المستخدم الإشعار أم لا';
COMMENT ON COLUMN public.notifications.created_at IS 'وقت إنشاء الإشعار';
