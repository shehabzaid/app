-- إضافة عمود appointment_id إلى جدول التقييمات إذا لم يكن موجودًا
ALTER TABLE public.reviews
ADD COLUMN IF NOT EXISTS appointment_id UUID REFERENCES public.appointments(id);

-- إنشاء فهرس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_reviews_appointment_id ON public.reviews(appointment_id);

-- إضافة تعليق توضيحي للعمود
COMMENT ON COLUMN public.reviews.appointment_id IS 'معرف الموعد المرتبط بالتقييم (اختياري)';
