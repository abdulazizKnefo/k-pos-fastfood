نظام إدارة نقاط البيع الذكي (POS22) 🚀

نظام متكامل لإدارة نقاط البيع (Point of Sale) مبني باستخدام Flutter، يتميز بقدرته على العمل دون اتصال بالإنترنت مع مزامنة سحابية متقدمة ودعم لمنصات متعددة (Windows, Android, iOS).

✨ المميزات الرئيسية

دعم متعدد المنصات: يعمل بسلاسة على أنظمة ويندوز، أندرويد، و iOS.

نظام هجين للبيانات: \* تخزين محلي باستخدام SQLite للأداء العالي والعمل بدون إنترنت.

مزامنة سحابية مع Firebase/Firestore لضمان أمان البيانات والوصول من أي مكان.

أمان ثنائي المستوى:

تسجيل دخول الجهاز عبر البريد الإلكتروني (Firebase Auth).

تسجيل دخول الموظفين عبر رمز PIN سريع لكل موظف.

إدارة المخزون: دعم المنتجات، التصنيفات، المكونات (Ingredients)، والإضافات (Addons).

التقارير والإحصائيات: لوحة تحكم تحتوي على رسوم بيانية تفاعلية لمراقبة المبيعات والأداء.

دعم الطباعة: وحدة متكاملة لطباعة الفواتير وتخصيصها.

🛠 التقنيات المستخدمة

Framework: Flutter

Database (Local): sqflite / sqflite_ffi للويندوز.

Cloud Backend: Firebase (Auth & Firestore).

State Management: Provider.

Charts: Syncfusion Flutter Charts.

🚀 بدء التشغيل

المتطلبات الأساسية

Flutter SDK (أحدث إصدار مستقر).

مشروع Firebase مفعل ومربوط بالتطبيق.

التثبيت

قم بعمل Clone للمستودع:

git clone [https://github.com/your-username/pos22.git](https://github.com/your-username/pos22.git)

تثبيت الحزم البرمجية:

flutter pub get

تشغيل التطبيق:

flutter run

📂 هيكلية المشروع

lib/main.dart: نقطة الدخول الرئيسية، معالج المصادقة، وإعدادات الحالة العامة.

lib/database_service.dart: محرك قواعد البيانات المحلية SQLite.

lib/services/firestore_sync_service.dart: منطق المزامنة بين السحابة والجهاز.

lib/screens/: تحتوي على واجهات التطبيق (تسجيل الدخول، لوحة التحكم، الإعدادات).

🔒 المصادقة (Authentication)

يستخدم التطبيق نظام AuthWrapper الذكي الذي يتحقق من:

حالة الجهاز: هل الجهاز مسجل في Firebase؟ (عبر DeviceLoginScreen).

حالة المستخدم: هل الموظف قام بإدخال رمز الـ PIN؟ (عبر LoginScreen).

تم تطويره بكل ❤️ باستخدام Flutter.
