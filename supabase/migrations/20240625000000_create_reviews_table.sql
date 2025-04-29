-- إنشاء جدول التقييمات
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES auth.users(id),
  doctor_id UUID NOT NULL,
  appointment_id UUID, -- معرف الموعد (اختياري)
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  is_approved BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- إنشاء فهارس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_reviews_doctor_id ON public.reviews(doctor_id);
CREATE INDEX IF NOT EXISTS idx_reviews_patient_id ON public.reviews(patient_id);
CREATE INDEX IF NOT EXISTS idx_reviews_appointment_id ON public.reviews(appointment_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(rating);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON public.reviews(created_at DESC);

-- تمكين سياسات أمان الصفوف (RLS)
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- سياسة للمستخدمين المصادق عليهم لعرض التقييمات المعتمدة
CREATE POLICY "Users can view approved reviews" 
ON public.reviews 
FOR SELECT 
TO authenticated 
USING (is_approved = TRUE);

-- سياسة للمستخدمين لإضافة تقييماتهم الخاصة
CREATE POLICY "Users can add their own reviews" 
ON public.reviews 
FOR INSERT 
TO authenticated 
WITH CHECK (patient_id = auth.uid());

-- سياسة للمستخدمين لتحديث تقييماتهم الخاصة
CREATE POLICY "Users can update their own reviews" 
ON public.reviews 
FOR UPDATE 
TO authenticated 
USING (patient_id = auth.uid());

-- سياسة للمستخدمين لحذف تقييماتهم الخاصة
CREATE POLICY "Users can delete their own reviews" 
ON public.reviews 
FOR DELETE 
TO authenticated 
USING (patient_id = auth.uid());

-- سياسة للمسؤولين لإدارة جميع التقييمات
CREATE POLICY "Admins can manage all reviews" 
ON public.reviews 
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
GRANT SELECT, INSERT, UPDATE, DELETE ON public.reviews TO authenticated;

-- إضافة تعليقات توضيحية للجدول والأعمدة
COMMENT ON TABLE public.reviews IS 'جدول لتخزين تقييمات المرضى للأطباء';
COMMENT ON COLUMN public.reviews.id IS 'المعرف الفريد للتقييم';
COMMENT ON COLUMN public.reviews.patient_id IS 'معرف المريض الذي قام بالتقييم';
COMMENT ON COLUMN public.reviews.doctor_id IS 'معرف الطبيب الذي تم تقييمه';
COMMENT ON COLUMN public.reviews.appointment_id IS 'معرف الموعد المرتبط بالتقييم (اختياري)';
COMMENT ON COLUMN public.reviews.rating IS 'درجة التقييم (من 1 إلى 5)';
COMMENT ON COLUMN public.reviews.comment IS 'تعليق المريض (اختياري)';
COMMENT ON COLUMN public.reviews.is_approved IS 'هل تم اعتماد التقييم للعرض العام';
COMMENT ON COLUMN public.reviews.created_at IS 'وقت إنشاء التقييم';
COMMENT ON COLUMN public.reviews.updated_at IS 'وقت آخر تحديث للتقييم';
