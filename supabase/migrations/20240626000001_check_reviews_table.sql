-- التحقق من وجود جدول التقييمات
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public'
   AND table_name = 'reviews'
);

-- عرض هيكل جدول التقييمات إذا كان موجودًا
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'reviews'
ORDER BY ordinal_position;
