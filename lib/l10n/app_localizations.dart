import 'package:flutter/material.dart';

/// App-wide localization support for Arabic and English
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get(String key) =>
      _localizedStrings[locale.languageCode]?[key] ??
      _localizedStrings['ar']![key] ??
      key;

  // Shorthand getters for common strings
  String get appName => get('app_name');

  // Navigation
  String get products => get('products');
  String get inventory => get('inventory');
  String get expenses => get('expenses');
  String get discounts => get('discounts');
  String get reports => get('reports');
  String get settings => get('settings');
  String get pos => get('pos');
  String get shift => get('shift');
  String get logout => get('logout');

  // Common Actions
  String get save => get('save');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get edit => get('edit');
  String get add => get('add');
  String get close => get('close');
  String get confirm => get('confirm');
  String get search => get('search');
  String get filter => get('filter');
  String get reset => get('reset');
  String get back => get('back');
  String get next => get('next');
  String get done => get('done');
  String get yes => get('yes');
  String get no => get('no');
  String get ok => get('ok');

  // Login
  String get enterPin => get('enter_pin');
  String get login => get('login');
  String get invalidPin => get('invalid_pin');
  String get loginFailed => get('login_failed');

  // POS Screen
  String get cart => get('cart');
  String get categories => get('categories');
  String get viewAll => get('view_all');
  String get noProducts => get('no_products');
  String get cartEmpty => get('cart_empty');
  String get selectCustomer => get('select_customer');
  String get noCustomer => get('no_customer');
  String get subtotal => get('subtotal');
  String get tax => get('tax');
  String get discount => get('discount');
  String get total => get('total');
  String get pay => get('pay');
  String get previousOrders => get('previous_orders');
  String get holdOrder => get('hold_order');
  String get heldOrders => get('held_orders');
  String get noHeldOrders => get('no_held_orders');
  String get restore => get('restore');
  String get orderHeld => get('order_held');
  String get orderRestored => get('order_restored');

  // Order Types
  String get dineIn => get('dine_in');
  String get takeaway => get('takeaway');
  String get delivery => get('delivery');
  String get quickActions => get("quick_actions");
  // Payment
  String get payment => get('payment');
  String get cash => get('cash');
  String get card => get('card');
  String get paymentMethod => get('payment_method');
  String get amountReceived => get('amount_received');
  String get changeAmount => get('change_amount');
  String get paymentComplete => get('payment_complete');
  String get selectSize => get('select_size');
  String get addToOrder => get('add_to_order');

  // Shift
  String get openShift => get('open_shift');
  String get closeShift => get('close_shift');
  String get shiftClosed => get('shift_closed');
  String get shiftOpen => get('shift_open');
  String get startCash => get('start_cash');
  String get endCash => get('end_cash');
  String get shiftRequired => get('shift_required');
  String get manageShift => get('manage_shift');
  String get shiftClosedSuccess => get('shift_closed_success');
  String get refunds => get('refunds');
  String get noShiftsFound => get('no_shifts_found');

  // Products
  String get productName => get('product_name');
  String get price => get('price');
  String get cost => get('cost');
  String get category => get('category');
  String get addProduct => get('add_product');
  String get editProduct => get('edit_product');
  String get deleteProduct => get('delete_product');
  String get addCategory => get('add_category');
  String get categoryName => get('category_name');
  String get addons => get('addons');
  String get ingredients => get('ingredients');
  String get priceSmall => get('price_small');
  String get priceMedium => get('price_medium');
  String get priceLarge => get('price_large');
  String get laborCost => get('labor_cost');

  // Inventory
  String get stock => get('stock');
  String get currentStock => get('current_stock');
  String get minStock => get('min_stock');
  String get lowStock => get('low_stock');
  String get unit => get('unit');
  String get addIngredient => get('add_ingredient');
  String get ingredientName => get('ingredient_name');

  String get chooseImage => get('choose_image');
  String get editCategory => get('edit_category');
  String get fieldRequired => get('field_required');
  String get invalidValue => get('invalid_value');
  String get all => get('all');
  String get deleteCategory => get('delete_category');
  String get importOptions => get('import_options');
  String get importModeDescription => get('import_mode_description');
  String get overwriteLocalData => get('overwrite_local_data');
  String get appendLocalData => get('append_local_data');

  // Expenses
  String get expense => get('expense');
  String get addExpense => get('add_expense');
  String get expenseCategory => get('expense_category');
  String get amount => get('amount');
  String get date => get('date');
  String get notes => get('notes');

  String get dashboardSummary => get('dashboard_summary');
  String get dateFilter => get('date_filter');
  String get week => get('week');
  String get month => get('month');

  String get allStaff => get('all_staff');
  String get filterEmployee => get('filter_employee');
  String get ordersCount => get('orders_count');
  String get financialPerformance => get('financial_performance');
  String get revenue => get('revenue');
  String get analytics => get('analytics');
  String get confirmReturn => get('confirm_return');
  String get profit => get('profit');

  String get creditCard => get('credit_card');
  String get transfer => get('transfer');
  String get unknown => get('unknown');
  String get totalPayments => get('total_payments');
  String get paymentMethods => get('payment_methods');
  String get salesForecast => get('sales_forecast');
  String get salesForecastMsg => get('sales_forecast_msg');
  String get bestSeller => get('best_seller');
  String get bestSellerMsg => get('best_seller_msg');
  String get profitTips => get('profit_tips');
  String get profitTipsMsg => get('profit_tips_msg');
  String get statisticalInfo => get('statistical_info');
  String get peakHours => get('peak_hours');

  String get percentageOfSales => get('percentage_of_sales');
  String get operation => get('operation');
  String get unknownCustomer => get('unknown_customer');
  String get lastOrder => get('last_order');
  String get order => get('order');
  String get avgOrderValue => get('avg_order_value');
  String get topProducts => get('top_products');
  String get staffPerformance => get('staff_performance');
  String get shifts => get('shifts');
  String get totalExpenses => get('total_expenses');
  String get expensesCount => get('expenses_count');
  String get expensesDistribution => get('expenses_distribution');
  String get expensesLog => get('expenses_log');
  String get noExpensesFound => get('no_expenses_found');
  String get requiredField => get('required_field');
  String get addNewExpense => get('add_new_expense');
  String get editExpense => get('edit_expense');
  String get expenseTitle => get('expense_title');
  String get saveExpense => get('save_expense');
  String get requiredFieldZero => get('required_field_zero');
  String get filterExpenses => get('filter_expenses');
  String get timePeriod => get('time_period');
  String get applyFilter => get('apply_filter');
  String get daily => get('daily');
  String get weekly => get('weekly');
  String get monthly => get('monthly');
  String get threeMonths => get('three_months');
  String get avg => get('avg');
  String get count => get('count');
  String get highestExpense => get('highest_expense');
  String get uncategorized => get('uncategorized');
  String get allCategories => get('all_categories');
  String get rent => get('rent');
  String get electricity => get('electricity');
  String get water => get('water');
  String get salaries => get('salaries');
  String get maintenance => get('maintenance');
  String get marketing => get('marketing');
  String get others => get('others');

  // Reports
  String get summary => get('summary');
  String get sales => get('sales');
  String get customers => get('customers');
  String get staff => get('staff');
  String get totalSales => get('total_sales');
  String get totalOrders => get('total_orders');
  String get netProfit => get('net_profit');
  String get activeCustomers => get('active_customers');
  String get today => get('today');
  String get thisWeek => get('this_week');
  String get thisMonth => get('this_month');
  String get custom => get('custom');
  String get from => get('from');
  String get to => get('to');
  String get filterByProduct => get('filter_by_product');
  String get allIngredients => get('all_ingredients');
  String get noIngredientsFound => get('no_ingredients_found');
  String get noIngredientsLinked => get('no_ingredients_linked');
  String get quantityInProduct => get('quantity_in_product');
  String get totalCustomers => get('total_customers');
  String get totalSpent => get('total_spent');
  String get noCustomersInPeriod => get('no_customers_in_period');
  String get productsCount => get('products_count');
  String get filterBySales => get('filter_by_sales');
  String get quantity => get('quantity');
  String get sellPrice => get('sell_price');
  String get ongoing => get('ongoing');
  String get hourShort => get('hour_short');
  String get minuteShort => get('minute_short');

  // Settings
  String get general => get('general');
  String get connection => get('connection');
  String get tools => get('tools');
  String get more => get('more');
  String get restaurantName => get('restaurant_name');
  String get address => get('address');
  String get phone => get('phone');
  String get printers => get('printers');
  String get addPrinter => get('add_printer');
  String get printerName => get('printer_name');
  String get ipAddress => get('ip_address');
  String get port => get('port');
  String get receiptPrinter => get('receipt_printer');
  String get kitchenPrinter => get('kitchen_printer');
  String get testPrint => get('test_print');
  String get paymentDevices => get('payment_devices');
  String get addDevice => get('add_device');
  String get factoryReset => get('factory_reset');
  String get factoryResetConfirm => get('factory_reset_confirm');
  String get database => get('database');
  String get usePostgres => get('use_postgres');
  String get host => get('host');
  String get databaseName => get('database_name');
  String get username => get('username');
  String get password => get('password');
  String get saveSettings => get('save_settings');
  String get testConnection => get('test_connection');

  // More Settings
  String get resetInvoice => get('reset_invoice');
  String get resetInvoiceDesc => get('reset_invoice_desc');
  String get resetInvoiceConfirm => get('reset_invoice_confirm');
  String get invoiceReset => get('invoice_reset');
  String get chooseTheme => get('choose_theme');
  String get chooseLanguage => get('choose_language');
  String get themeNote => get('theme_note');
  String get restartRequired => get('restart_required');
  String get themeChanged => get('theme_changed');
  String get languageChanged => get('language_changed');

  // Users/Staff
  String get users => get('users');
  String get addUser => get('add_user');
  String get editUser => get('edit_user');
  String get userName => get('user_name');
  String get pin => get('pin');
  String get role => get('role');
  String get admin => get('admin');
  String get cashier => get('cashier');
  String get chef => get('chef');

  // Customers
  String get customer => get('customer');
  String get addCustomer => get('add_customer');
  String get customerName => get('customer_name');
  String get noCustomers => get('no_customers');

  // Discounts
  String get addDiscount => get('add_discount');
  String get discountName => get('discount_name');
  String get discountType => get('discount_type');
  String get percentage => get('percentage');
  String get fixedAmount => get('fixed_amount');
  String get scope => get('scope');
  String get global => get('global');
  String get selectCategory => get('select_category');
  String get selectProduct => get('select_product');

  // Messages
  String get success => get('success');
  String get error => get('error');
  String get warning => get('warning');
  String get loading => get('loading');
  String get noData => get('no_data');
  String get connectionError => get('connection_error');
  String get savedSuccessfully => get('saved_successfully');
  String get deletedSuccessfully => get('deleted_successfully');
  String get confirmDelete => get('confirm_delete');
  String get areYouSure => get('are_you_sure');

  static const Map<String, Map<String, String>> _localizedStrings = {
    'ar': {
      'app_name': 'نظام نقاط البيع',

      // Navigation
      'products': 'المنتجات',
      'inventory': 'المخزن',
      'expenses': 'المصروفات',
      'discounts': 'العروض',
      'reports': 'التقارير',
      'settings': 'الإعدادات',
      'pos': 'نقطة البيع',
      'shift': 'الوردية',
      'logout': 'خروج',

      // Common Actions
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'close': 'إغلاق',
      'confirm': 'تأكيد',
      'search': 'بحث',
      'filter': 'تصفية',
      'reset': 'تصفير',
      'back': 'رجوع',
      'next': 'التالي',
      'done': 'تم',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',

      // Login
      'enter_pin': 'أدخل رمز PIN',
      'login': 'تسجيل الدخول',
      'invalid_pin': 'رمز PIN غير صحيح',
      'login_failed': 'فشل تسجيل الدخول',

      // POS Screen
      'cart': 'السلة',
      'categories': 'الفئات',
      'view_all': 'عرض الكل',
      'no_products': 'لا يوجد منتجات',
      'cart_empty': 'السلة فارغة',
      'select_customer': 'اختر العميل',
      'no_customer': 'بدون عميل',
      'subtotal': 'المجموع',
      'tax': 'الضريبة',
      'discount': 'الخصم',
      'total': 'الإجمالي',
      'pay': 'دفــــع',
      'previous_orders': 'الطلبات السابقة',
      'hold_order': 'تعليق',
      'held_orders': 'الفواتير المعلقة',
      'no_held_orders': 'لا توجد فواتير معلقة',
      'restore': 'استعادة',
      'order_held': 'تم تعليق الطلب بنجاح',
      'order_restored': 'تم استعادة الطلب',

      // Order Types
      'dine_in': 'داخلي',
      'takeaway': 'خارجي',
      'delivery': 'توصيل',
      'quick_actions': 'الإجراءات السريعة',
      // Payment
      'payment': 'الدفع',
      'cash': 'نقدي',
      'card': 'بطاقة',
      'payment_method': 'طريقة الدفع',
      'amount_received': 'المبلغ المستلم',
      'change_amount': 'الباقي',
      'payment_complete': 'تم الدفع بنجاح',
      'select_size': 'اختر الحجم',
      'add_to_order': 'إضافة للطلب',

      // Shift
      'open_shift': 'افتح وردية',
      'close_shift': 'إغلاق الوردية',
      'shift_closed': 'تم اغلاق الوردية',
      'shift_open': 'الوردية مفتوحة',
      'start_cash': 'النقدي بداية الوردية',
      'end_cash': 'النقدي في الدرج',
      'shift_required': 'افتح وردية لبدء البيع',
      'manage_shift': 'ادارة الوردية',
      'shift_closed_success': 'تم إغلاق الوردية بنجاح',
      'refunds': 'المستردات',
      'no_shifts_found': 'لا توجد ورديات في هذه الفترة',

      // Products
      'product_name': 'اسم المنتج',
      'price': 'السعر',
      'cost': 'التكلفة',
      'category': 'الفئة',
      'add_product': 'إضافة منتج',
      'edit_product': 'تعديل منتج',
      'delete_product': 'حذف منتج',
      'add_category': 'إضافة فئة',
      'category_name': 'اسم الفئة',
      'addons': 'الإضافات',
      'ingredients': 'المكونات',
      'price_small': 'سعر صغير',
      'price_medium': 'سعر وسط',
      'price_large': 'سعر كبير',
      'labor_cost': 'تكلفة العمالة',

      // Inventory
      'stock': 'المخزون',
      'current_stock': 'المخزون الحالي',
      'min_stock': 'الحد الأدنى',
      'low_stock': 'مخزون منخفض',
      'unit': 'الوحدة',
      'add_ingredient': 'إضافة مكون',
      'ingredient_name': 'اسم المكون',

      'choose_image': 'اختر صورة',
      'edit_category': 'تعديل فئة',
      'field_required': 'مطلوب',
      'invalid_value': 'قيمة غير صالحة',

      // Expenses
      'expense': 'مصروف',
      'add_expense': 'إضافة مصروف',
      'expense_category': 'تصنيف المصروف',
      'amount': 'المبلغ',
      'date': 'التاريخ',
      'notes': 'ملاحظات',

      'dashboard_summary': 'الملخص',
      'date_filter': 'فلترة التاريخ',
      'week': 'أسبوع',
      'month': 'شهر',
      'all_staff': 'جميع الموظفين',
      'filter_employee': 'فلترة الموظف',
      'orders_count': 'عدد الطلبات',
      'financial_performance': 'الأداء المالي',
      'revenue': 'الإيرادات',
      'analytics': 'التحليل',
      'confirm_return': 'تأكيد الإرجاع',
      'profit': 'الربح',
      'credit_card': 'بطاقة ائتمان',
      'transfer': 'تحويل بنكي',
      'unknown': 'غير معروف',
      'total_payments': 'إجمالي المدفوعات',
      'payment_methods': 'قائمة طرق الدفع',
      'sales_forecast': 'توقعات المبيعات',
      'sales_forecast_msg':
          'المبيعات متوقعة للزيادة بنسبة 15% خلال الأسبوع القادم بناءً على البيانات التاريخية',
      'best_seller': 'الأكثر مبيعاً',
      'best_seller_msg':
          'المنتج: @product\nهذا المنتج يحقق أعلى معدل دوران في المخزون',
      'profit_tips': 'اقتراحات لزيادة الأرباح',
      'profit_tips_msg':
          '1. عمل حزم وعروض خاصة\n2. تحفيز الموظفين على البيع\n3. برنامج ولاء للعملاء الدائمين',
      'statistical_info': 'معلومات إحصائية',
      'peak_hours': 'ساعات الذروة',
      'percentage_of_sales': 'من إجمالي المبيعات',
      'operation': 'عملية',
      'unknown_customer': 'عميل غير معروف',
      'last_order': 'آخر طلب',
      'order': 'طلب',
      'avg_order_value': 'متوسط قيمة الطلب',
      'top_products': 'أكثر المنتجات',
      'staff_performance': 'أداء الموظفين',
      'shifts': 'الورديات',
      'total_expenses': 'إجمالي المصروفات',
      'expenses_count': 'عدد المصروفات',
      'expenses_distribution': 'توزيع المصروفات',
      'expenses_log': 'سجل المصروفات',
      'no_expenses_found': 'لا توجد مصروفات في هذه الفترة',
      'required_field': 'هذا الحقل مطلوب',
      'add_new_expense': 'إضافة مصروف جديد',
      'edit_expense': 'تعديل المصروف',
      'expense_title': 'عنوان المصروف',
      'save_expense': 'حفظ المصروف',
      'required_field_zero': 'أدخل قيمة صحيحة أكبر من صفر',
      'filter_expenses': 'فلترة المصروفات',
      'time_period': 'الفترة الزمنية',
      'apply_filter': 'تطبيق الفلترة',
      'daily': 'اليوم',
      'weekly': 'أسبوع',
      'monthly': 'شهر',
      'three_months': 'ثلاثة أشهر',
      'avg': 'المتوسط',
      'count': 'العدد',
      'highest_expense': 'أعلى مصروف',
      'uncategorized': 'غير مصنف',
      'all_categories': 'كل التصنيفات',
      'rent': 'إيجار',
      'electricity': 'كهرباء',
      'water': 'ماء',
      'salaries': 'رواتب',
      'maintenance': 'صيانة',
      'marketing': 'تسويق',
      'others': 'أخرى',

      // Reports
      'summary': 'ملخص',
      'sales': 'المبيعات',
      'customers': 'العملاء',
      'staff': 'الموظفين',
      'total_sales': 'إجمالي المبيعات',
      'total_orders': 'إجمالي الطلبات',
      'net_profit': 'صافي الربح',
      'active_customers': 'العملاء النشطين',
      'today': 'اليوم',
      'this_week': 'هذا الأسبوع',
      'this_month': 'هذا الشهر',
      'custom': 'مخصص',
      'from': 'من',
      'to': 'إلى',
      'filter_by_product': 'تصفية حسب المنتج',
      'all_ingredients': 'جميع المكونات',
      'no_ingredients_found': 'لا توجد مكونات في المخزن',
      'no_ingredients_linked': 'لا توجد مكونات مرتبطة بهذا المنتج',
      'quantity_in_product': 'الكمية في المنتج',
      'total_customers': 'إجمالي العملاء',
      'total_spent': 'المشتريات',
      'no_customers_in_period': 'لا يوجد عملاء في هذه الفترة',
      'products_count': 'عدد المنتجات',
      'filter_by_sales': 'تصفية حسب المبيعات',
      'quantity': 'الكمية',
      'sell_price': 'سعر البيع',
      'ongoing': 'مستمر',
      'hour_short': 'س',
      'minute_short': 'د',

      // Settings
      'general': 'عام',
      'connection': 'الاتصال',
      'tools': 'الأدوات',
      'more': 'المزيد',
      'restaurant_name': 'اسم المطعم',
      'address': 'العنوان',
      'phone': 'الهاتف',
      'printers': 'الطابعات',
      'add_printer': 'إضافة طابعة',
      'printer_name': 'اسم الطابعة',
      'ip_address': 'عنوان IP',
      'port': 'المنفذ',
      'receipt_printer': 'طابعة الفواتير',
      'kitchen_printer': 'طابعة المطبخ',
      'test_print': 'طباعة تجريبية',
      'payment_devices': 'أجهزة الدفع',
      'add_device': 'إضافة جهاز',
      'factory_reset': 'إعادة ضبط المصنع',
      'factory_reset_confirm': 'هل أنت متأكد من إعادة ضبط المصنع؟',
      'database': 'قاعدة البيانات',
      'use_postgres': 'استخدام PostgreSQL',
      'host': 'المضيف',
      'database_name': 'اسم قاعدة البيانات',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'save_settings': 'حفظ الإعدادات',
      'test_connection': 'اختبار الاتصال',

      // More Settings
      'reset_invoice': 'تصفير ترقيم الفاتورة',
      'reset_invoice_desc': 'إعادة بدء العد من الفاتورة رقم 1',
      'reset_invoice_confirm': 'هل أنت متأكد من إعادة تصفير ترقيم الفواتير؟',
      'invoice_reset': 'تم تصفير ترقيم الفواتير',
      'choose_theme': 'اختر سمة التطبيق',
      'choose_language': 'اختر اللغة',
      'theme_note': 'يتطلب تغيير السمة أو اللغة إعادة تشغيل التطبيق',
      'restart_required': 'يتطلب إعادة تشغيل التطبيق',
      'theme_changed': 'تم تغيير السمة',
      'language_changed': 'تم تغيير اللغة',

      // Users/Staff
      'users': 'المستخدمين',
      'add_user': 'إضافة مستخدم',
      'edit_user': 'تعديل مستخدم',
      'user_name': 'اسم المستخدم',
      'pin': 'رمز PIN',
      'role': 'الصلاحية',
      'admin': 'مدير',
      'cashier': 'كاشير',
      'chef': 'طباخ',

      // Customers
      'customer': 'عميل',
      'add_customer': 'إضافة عميل جديد',
      'customer_name': 'اسم العميل',
      'no_customers': 'لا يوجد عملاء',

      // Discounts
      'add_discount': 'إضافة خصم',
      'discount_name': 'اسم الخصم',
      'discount_type': 'نوع الخصم',
      'percentage': 'نسبة مئوية',
      'fixed_amount': 'مبلغ ثابت',
      'scope': 'النطاق',
      'global': 'شامل',
      'select_category': 'اختر الفئة',
      'select_product': 'اختر المنتج',

      // Messages
      'success': 'نجاح',
      'error': 'خطأ',
      'warning': 'تحذير',
      'loading': 'جاري التحميل...',
      'no_data': 'لا توجد بيانات',
      'connection_error': 'خطأ في الاتصال',
      'saved_successfully': 'تم الحفظ بنجاح',
      'deleted_successfully': 'تم الحذف بنجاح',
      'confirm_delete': 'تأكيد الحذف',
      'are_you_sure': 'هل أنت متأكد؟',
      'all': 'الكل',
      'delete_category': 'حذف فئة',
      'import_options': 'خيارات الاستيراد',
      'import_mode_description': 'اختر طريقة استيراد البيانات:',
      'overwrite_local_data': 'مسح البيانات المحلية والاستيراد',
      'append_local_data': 'الاحتفاظ بالبيانات القديمة والاستيراد',
    },
    'en': {
      'app_name': 'POS System',

      // Navigation
      'products': 'Products',
      'inventory': 'Inventory',
      'expenses': 'Expenses',
      'discounts': 'Discounts',
      'reports': 'Reports',
      'settings': 'Settings',
      'pos': 'POS',
      'shift': 'Shift',
      'logout': 'Logout',

      // Common Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'confirm': 'Confirm',
      'search': 'Search',
      'filter': 'Filter',
      'reset': 'Reset',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',

      // Login
      'enter_pin': 'Enter PIN',
      'login': 'Login',
      'invalid_pin': 'Invalid PIN',
      'login_failed': 'Login Failed',

      // POS Screen
      'cart': 'Cart',
      'categories': 'Categories',
      'view_all': 'View All',
      'no_products': 'No products',
      'cart_empty': 'Cart is empty',
      'select_customer': 'Select Customer',
      'no_customer': 'No Customer',
      'subtotal': 'Subtotal',
      'tax': 'Tax',
      'discount': 'Discount',
      'total': 'Total',
      'pay': 'Pay',
      'previous_orders': 'Previous Orders',
      'hold_order': 'Hold',
      'held_orders': 'Held Orders',
      'no_held_orders': 'No held orders',
      'restore': 'Restore',
      'order_held': 'Order held successfully',
      'order_restored': 'Order restored',

      // Order Types
      'dine_in': 'Dine In',
      'takeaway': 'Takeaway',
      'delivery': 'Delivery',

      // Payment
      'payment': 'Payment',
      'cash': 'Cash',
      'card': 'Card',
      'payment_method': 'Payment Method',
      'amount_received': 'Amount Received',
      'change_amount': 'Change',
      'payment_complete': 'Payment Complete',
      'select_size': 'Select Size',
      'add_to_order': 'Add to Order',

      // Shift
      'open_shift': 'Open Shift',
      'close_shift': 'Close Shift',
      'shift_closed': 'Shift Closed',
      'shift_open': 'Shift Open',
      'start_cash': 'Starting Cash',
      'end_cash': 'Cash in Drawer',
      'shift_required': 'Open a shift to start selling',
      'manage_shift': 'Manage Shift',
      'shift_closed_success': 'Shift Closed Successfully',
      'refunds': 'Refunds',
      'no_shifts_found': 'No shifts found in this period',

      // Products
      'product_name': 'Product Name',
      'price': 'Price',
      'cost': 'Cost',
      'category': 'Category',
      'add_product': 'Add Product',
      'edit_product': 'Edit Product',
      'delete_product': 'Delete Product',
      'add_category': 'Add Category',
      'category_name': 'Category Name',
      'addons': 'Addons',
      'ingredients': 'Ingredients',
      'price_small': 'Small Price',
      'price_medium': 'Medium Price',
      'price_large': 'Large Price',
      'labor_cost': 'Labor Cost',

      // Inventory
      'stock': 'Stock',
      'current_stock': 'Current Stock',
      'min_stock': 'Min Stock',
      'low_stock': 'Low Stock',
      'unit': 'Unit',
      'add_ingredient': 'Add Ingredient',
      'ingredient_name': 'Ingredient Name',

      'choose_image': 'Choose Image',
      'edit_category': 'Edit Category',
      'field_required': 'Required',
      'invalid_value': 'Invalid Value',

      // Expenses
      'expense': 'Expense',
      'add_expense': 'Add Expense',
      'expense_category': 'Expense Category',
      'amount': 'Amount',
      'date': 'Date',
      'notes': 'Notes',
      'quick_actions': 'Quick Actions',
      'dashboard_summary': 'Summary',
      'date_filter': 'Date Filter',
      'week': 'Week',
      'month': 'Month',
      'all_staff': 'All Staff',
      'filter_employee': 'Filter Employee',
      'orders_count': 'Orders Count',
      'financial_performance': 'Financial Performance',
      'revenue': 'Revenue',
      'analytics': 'Analytics',
      'confirm_return': 'Confirm Return',
      'profit': 'Profit',
      'credit_card': 'Credit Card',
      'transfer': 'Bank Transfer',
      'unknown': 'Unknown',
      'total_payments': 'Total Payments',
      'payment_methods': 'Payment Methods',
      'sales_forecast': 'Sales Forecast',
      'sales_forecast_msg':
          'Sales are expected to increase by 15% next week based on historical data',
      'best_seller': 'Best Seller',
      'best_seller_msg':
          'Product: @product\nThis product has the highest inventory turnover',
      'profit_tips': 'Profit Tips',
      'profit_tips_msg':
          '1. Create bundles and special offers\n2. Incentivize staff sales\n3. Loyalty program for regulars',
      'statistical_info': 'Statistical Info',
      'peak_hours': 'Peak Hours',
      'percentage_of_sales': 'of total sales',
      'operation': 'operation',
      'unknown_customer': 'Unknown Customer',
      'last_order': 'Last Order',
      'order': 'Order',
      'import_options': 'Import Options',
      'import_mode_description': 'Choose how you want to import data:',
      'overwrite_local_data': 'Clear local data and import',
      'append_local_data': 'Keep local data and import',
      'avg_order_value': 'Average Order Value',
      'top_products': 'Top Products',
      'staff_performance': 'Staff Performance',
      'shifts': 'Shifts',
      'total_expenses': 'Total Expenses',
      'expenses_count': 'Expenses Count',
      'expenses_distribution': 'Expenses Distribution',
      'expenses_log': 'Expenses Log',
      'no_expenses_found': 'No expenses found in this period',
      'required_field': 'Required field',
      'add_new_expense': 'Add New Expense',
      'edit_expense': 'Edit Expense',
      'expense_title': 'Expense Title',
      'save_expense': 'Save Expense',
      'required_field_zero': 'Enter a value greater than zero',
      'filter_expenses': 'Filter Expenses',
      'time_period': 'Time Period',
      'apply_filter': 'Apply Filter',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'three_months': '3 Months',
      'avg': 'Average',
      'count': 'Count',
      'highest_expense': 'Highest Expense',
      'uncategorized': 'Uncategorized',
      'all_categories': 'All Categories',
      'rent': 'Rent',
      'electricity': 'Electricity',
      'water': 'Water',
      'salaries': 'Salaries',
      'maintenance': 'Maintenance',
      'marketing': 'Marketing',
      'others': 'Others',

      // Reports
      'summary': 'Summary',
      'sales': 'Sales',
      'customers': 'Customers',
      'staff': 'Staff',
      'total_sales': 'Total Sales',
      'total_orders': 'Total Orders',
      'net_profit': 'Net Profit',
      'active_customers': 'Active Customers',
      'today': 'Today',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'custom': 'Custom',
      'from': 'From',
      'to': 'To',
      'filter_by_product': 'Filter by Product',
      'all_ingredients': 'All Ingredients',
      'no_ingredients_found': 'No ingredients in stock',
      'no_ingredients_linked': 'No ingredients linked to this product',
      'quantity_in_product': 'Quantity in Product',
      'total_customers': 'Total Customers',
      'total_spent': 'Total Spent',
      'no_customers_in_period': 'No customers in this period',
      'products_count': 'Products Count',
      'filter_by_sales': 'Filter by Sales',
      'quantity': 'Quantity',
      'sell_price': 'Sell Price',
      'ongoing': 'Active',
      'hour_short': 'h',
      'minute_short': 'm',

      // Settings
      'general': 'General',
      'connection': 'Connection',
      'tools': 'Tools',
      'more': 'More',
      'restaurant_name': 'Restaurant Name',
      'address': 'Address',
      'phone': 'Phone',
      'printers': 'Printers',
      'add_printer': 'Add Printer',
      'printer_name': 'Printer Name',
      'ip_address': 'IP Address',
      'port': 'Port',
      'receipt_printer': 'Receipt Printer',
      'kitchen_printer': 'Kitchen Printer',
      'test_print': 'Test Print',
      'payment_devices': 'Payment Devices',
      'add_device': 'Add Device',
      'factory_reset': 'Factory Reset',
      'factory_reset_confirm': 'Are you sure you want to reset?',
      'database': 'Database',
      'use_postgres': 'Use PostgreSQL',
      'host': 'Host',
      'database_name': 'Database Name',
      'username': 'Username',
      'password': 'Password',
      'save_settings': 'Save Settings',
      'test_connection': 'Test Connection',

      // More Settings
      'reset_invoice': 'Reset Invoice Counter',
      'reset_invoice_desc': 'Restart numbering from invoice #1',
      'reset_invoice_confirm':
          'Are you sure you want to reset invoice numbering?',
      'invoice_reset': 'Invoice numbering reset',
      'choose_theme': 'Choose Theme',
      'choose_language': 'Choose Language',
      'theme_note': 'Changing theme or language requires app restart',
      'restart_required': 'Restart required',
      'theme_changed': 'Theme changed',
      'language_changed': 'Language changed',

      // Users/Staff
      'users': 'Users',
      'add_user': 'Add User',
      'edit_user': 'Edit User',
      'user_name': 'User Name',
      'pin': 'PIN',
      'role': 'Role',
      'admin': 'Admin',
      'cashier': 'Cashier',
      'chef': 'Chef',

      // Customers
      'customer': 'Customer',
      'add_customer': 'Add Customer',
      'customer_name': 'Customer Name',
      'no_customers': 'No customers',

      // Discounts
      'add_discount': 'Add Discount',
      'discount_name': 'Discount Name',
      'discount_type': 'Discount Type',
      'percentage': 'Percentage',
      'fixed_amount': 'Fixed Amount',
      'scope': 'Scope',
      'global': 'Global',
      'select_category': 'Select Category',
      'select_product': 'Select Product',

      // Messages
      'success': 'Success',
      'error': 'Error',
      'warning': 'Warning',
      'loading': 'Loading...',
      'no_data': 'No data',
      'connection_error': 'Connection Error',
      'saved_successfully': 'Saved successfully',
      'deleted_successfully': 'Deleted successfully',
      'confirm_delete': 'Confirm Delete',
      'are_you_sure': 'Are you sure?',
      'all': 'All',
      'delete_category': 'Delete Category',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easy access to localization
extension LocalizationExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
