import 'dart:io';
import 'dart:async';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart'; // Ensure sqflite is imported for ConflictAlgorithm
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
//import 'screens/device_login_screen.dart';
import 'services/firestore_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentTheme = 'material';
  String _currentLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('app_theme') ?? 'material';
    final lang = prefs.getString('app_language') ?? 'ar';
    if (mounted && (theme != _currentTheme || lang != _currentLanguage)) {
      setState(() {
        _currentTheme = theme;
        _currentLanguage = lang;
      });
    }
  }

  ThemeData _getTheme() {
    switch (_currentTheme) {
      case 'ios6':
        return _buildIOS6Theme();
      case 'cupertino':
        return _buildCupertinoTheme();
      case 'material':
      default:
        return _buildMaterialTheme();
    }
  }

  // Material Design Theme (Current Default)
  ThemeData _buildMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2C3E50),
        brightness: Brightness.light,
        primary: const Color(0xFF2C3E50),
        secondary: const Color(0xFFE74C3C),
        surface: const Color(0xFFF5F6FA),
      ),
      fontFamily: 'Segoe UI',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // iOS 6 Style Theme (Skeuomorphic, Gradients)
  ThemeData _buildIOS6Theme() {
    return ThemeData(
      useMaterial3: false,
      primaryColor: const Color(0xFF1C5AA3),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1C5AA3),
        secondary: const Color(0xFF5AB5E8),
        surface: const Color(0xFFE8E8E8),
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFE8E8E8),
      fontFamily: 'Helvetica Neue',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF5090D0),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFBBBBBB), width: 1),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90D9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFBBBBBB)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }

  // Cupertino-Style Theme (San Francisco, iOS Modern)
  ThemeData _buildCupertinoTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF007AFF),
        secondary: const Color(0xFF5856D6),
        surface: const Color(0xFFF2F2F7),
        onPrimary: Colors.white,
        outline: const Color(0xFFC6C6C8),
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      fontFamily: 'SF Pro Text',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Color(0xFF007AFF),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFC6C6C8),
        thickness: 0.5,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF007AFF),
        unselectedLabelColor: Color(0xFF8E8E93),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KPOS Restaurant',
      debugShowCheckedModeBanner: false,
      theme: _getTheme(),
      locale: Locale(_currentLanguage),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ADD THIS BLOCK:
      home: Directionality(
        textDirection: _currentLanguage == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // مراقبة حالة التطبيق المحلية (Local State)
    final appState = context.watch<AppState>();

    // إذا لم يكن هناك مستخدم مسجل محلياً، اعرض شاشة PIN، وإلا اعرض الشاشة الرئيسية
    return appState.currentUser == null
        ? const LoginScreen()
        : const MainLayout();
  }
}
// --- Models ---

// --- Branch Model ---
class Branch {
  final int? id;
  final String name;
  final String? createdAt;
  final bool isActive;

  Branch({this.id, required this.name, this.createdAt, this.isActive = true});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
    'is_active': isActive ? 1 : 0,
  };

  factory Branch.fromMap(Map<String, dynamic> map) => Branch(
    id: map['id'],
    name: map['name'],
    createdAt: map['created_at'],
    isActive: (map['is_active'] is int
        ? map['is_active'] == 1
        : map['is_active'] == true),
  );
}

class User {
  final int? id;
  final String name;
  final String pin;
  final String role;
  final int? branchId;
  final bool isSynced;

  User({
    this.id,
    required this.name,
    required this.pin,
    required this.role,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'pin': pin,
    'role': role,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    name: map['name'],
    pin: map['pin'],
    role: map['role'],
    branchId: map['branch_id'],
    isSynced: (map['is_synced'] is int
        ? map['is_synced'] == 1
        : map['is_synced'] == true),
  );
}

class Expense {
  final int? id;
  final String title;
  final double amount;
  final String date;
  final String? notes;
  final String? category;
  final int? userId;
  final String? createdAt;
  final int? branchId;
  final bool isSynced;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
    this.category,
    this.userId,
    this.createdAt,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'notes': notes,
      'category': category,
      'userId': userId,
      'createdAt': createdAt,
      'branch_id': branchId,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      notes: map['notes'],
      category: map['category'],
      userId: map['userId'],
      createdAt: map['createdAt'],
      branchId: map['branch_id'],
      isSynced: (map['is_synced'] is int
          ? map['is_synced'] == 1
          : map['is_synced'] == true),
    );
  }
}

class Printer {
  final int? id;
  final String name;
  final String ipAddress;
  final int port;
  final bool
  isReceipt; // If true, prints receipts. If false, categorization only.

  Printer({
    this.id,
    required this.name,
    required this.ipAddress,
    this.port = 9100,
    this.isReceipt = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'ipAddress': ipAddress,
    'port': port,
    'isReceipt': isReceipt ? 1 : 0,
  };

  factory Printer.fromMap(Map<String, dynamic> map) => Printer(
    id: map['id'],
    name: map['name'],
    ipAddress: map['ipAddress'],
    port: map['port'] ?? 9100,
    isReceipt: (map['isReceipt'] ?? 0) == 1,
  );
}

class Category {
  final int? id;
  final String name;
  final String? printerName; // Deprecated but kept for migration
  final int? printerId; // New Foreign Key
  final int? iconCode;
  final int? colorValue;
  final int? branchId;
  final bool isSynced;

  Category({
    this.id,
    required this.name,
    this.printerName,
    this.printerId,
    this.iconCode,
    this.colorValue,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'printerName': printerName,
    'printerId': printerId,
    'iconCode': iconCode,
    'colorValue': colorValue,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
  };
  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id'],
    name: map['name'],
    printerName: map['printerName'],
    printerId: map['printerId'],
    iconCode: map['iconCode'],
    colorValue: map['colorValue'],
  );
}

class Product {
  final int? id;
  final String name;
  final int categoryId;
  final double costPrice;
  final double sellPrice;
  final double laborCost;
  final String? imagePath;
  final int stock;
  final double? priceSmall;
  final double? priceMedium;
  final double? priceLarge;
  final int? iconCode;
  final int? colorValue;
  final int? branchId;
  final bool isSynced;
  final String? unit;
  final double unitsPerPackage;
  final double minStock;
  final bool isActive;

  // Transient
  List<Addon> availableAddons = [];

  Product({
    this.id,
    required this.name,
    required this.categoryId,
    required this.costPrice,
    required this.sellPrice,
    required this.laborCost,
    this.imagePath,
    this.stock = 0,
    this.priceSmall,
    this.priceMedium,
    this.priceLarge,
    this.iconCode,
    this.colorValue,
    this.branchId,
    this.isSynced = false,
    this.unit,
    this.unitsPerPackage = 1,
    this.minStock = 0,
    this.isActive = true,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'],
    name: map['name'],
    categoryId: map['categoryId'],
    costPrice: (map['costPrice'] as num).toDouble(),
    sellPrice: (map['sellPrice'] as num).toDouble(),
    laborCost: (map['laborCost'] as num).toDouble(),
    imagePath: map['imagePath'],
    stock: map['stock'] ?? 0,
    priceSmall: (map['priceSmall'] as num?)?.toDouble(),
    priceMedium: (map['priceMedium'] as num?)?.toDouble(),
    priceLarge: (map['priceLarge'] as num?)?.toDouble(),
    iconCode: map['iconCode'],
    colorValue: map['colorValue'],
    branchId: map['branch_id'],
    isSynced: (map['is_synced'] is int
        ? map['is_synced'] == 1
        : map['is_synced'] == true),
    unit: map['unit'],
    unitsPerPackage: (map['unitsPerPackage'] as num?)?.toDouble() ?? 1,
    minStock: (map['minStock'] as num?)?.toDouble() ?? 0,
    isActive: (map['isActive'] is int
        ? map['isActive'] == 1
        : map['isActive'] == true),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'costPrice': costPrice,
    'sellPrice': sellPrice,
    'laborCost': laborCost,
    'imagePath': imagePath,
    'stock': stock,
    'priceSmall': priceSmall,
    'priceMedium': priceMedium,
    'priceLarge': priceLarge,
    'iconCode': iconCode,
    'colorValue': colorValue,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
    'unit': unit,
    'unitsPerPackage': unitsPerPackage,
    'minStock': minStock,
    'isActive': isActive ? 1 : 0,
  };
}

class Addon {
  final int? id;
  final int? productId; // Nullable for category-shared addons
  final String name;
  final double price;
  final int? categoryId;

  Addon({
    this.id,
    this.productId,
    required this.name,
    required this.price,
    this.categoryId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'name': name,
    'price': price,
    'categoryId': categoryId,
  };

  factory Addon.fromMap(Map<String, dynamic> map) => Addon(
    id: map['id'],
    productId: map['productId'],
    name: map['name'],
    price: (map['price'] as num).toDouble(),
    categoryId: map['categoryId'],
  );

  // copyWith مصححة لضمان عدم وجود مشاكل مع القيم المطلوبة
  Addon copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
    int? categoryId,
  }) {
    return Addon(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      // نستخدم القيمة الجديدة إذا وجدت، وإلا نستخدم القيمة القديمة
      name: name ?? this.name,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class Discount {
  final int? id;
  final String name;
  final String type;
  final double value;
  final String startDate;
  final String endDate;
  final int? targetCategoryId;
  final int? targetProductId;

  Discount({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    this.targetCategoryId,
    this.targetProductId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'value': value,
    'startDate': startDate,
    'endDate': endDate,
    'targetCategoryId': targetCategoryId,
    'targetProductId': targetProductId,
  };

  factory Discount.fromMap(Map<String, dynamic> map) => Discount(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    value: (map['value'] as num).toDouble(),
    startDate: map['startDate'],
    endDate: map['endDate'],
    targetCategoryId: map['targetCategoryId'],
    targetProductId: map['targetProductId'],
  );
}

class Sale {
  final int? id;
  final String invoiceId;
  final double totalAmount;
  final double taxAmount;
  final String date;
  final String paymentMethod;
  final String orderType;
  final int? customerId;
  final int? paymentDeviceId;
  final int userId;
  final int isRefunded;
  final int isCancelled;
  final int? branchId;
  final bool isSynced;

  Sale({
    this.id,
    required this.invoiceId,
    required this.totalAmount,
    this.taxAmount = 0.0,
    required this.date,
    required this.paymentMethod,
    required this.orderType,
    this.customerId,
    this.paymentDeviceId,
    required this.userId,
    this.isRefunded = 0,
    this.isCancelled = 0,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceId': invoiceId,
    'totalAmount': totalAmount,
    'taxAmount': taxAmount,
    'date': date,
    'paymentMethod': paymentMethod,
    'orderType': orderType,
    'customerId': customerId,
    'paymentDeviceId': paymentDeviceId,
    'userId': userId,
    'isRefunded': isRefunded,
    'isCancelled': isCancelled,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
  };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
    id: map['id'],
    invoiceId: map['invoiceId'],
    totalAmount: (map['totalAmount'] as num).toDouble(),
    taxAmount: (map['taxAmount'] as num? ?? 0.0).toDouble(),
    date: map['date'],
    paymentMethod: map['paymentMethod'],
    orderType: map['orderType'] ?? 'داخلي',
    customerId: map['customerId'],
    paymentDeviceId: map['paymentDeviceId'],
    userId: map['userId'],
    isRefunded: map['isRefunded'] ?? 0,
    isCancelled: map['isCancelled'] ?? 0,
    branchId: map['branch_id'],
    isSynced: (map['is_synced'] is int
        ? map['is_synced'] == 1
        : map['is_synced'] == true),
  );
}

class SaleItem {
  final int? id;
  final int saleId;
  final int productId;
  final int quantity;
  final double price;
  final double costPrice; // Snapshot of cost at time of sale
  final String productName;

  final String? size; // S, M, L
  final String? addonsStr; // JSON or comma sep

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.costPrice = 0.0,
    required this.productName,
    this.size,
    this.addonsStr,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'saleId': saleId,
    'productId': productId,
    'quantity': quantity,
    'price': price,
    'costPrice': costPrice,
    'productName': productName,
    'size': size,
    'addonsStr': addonsStr,
  };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
    id: map['id'],
    saleId: map['saleId'],
    productId: map['productId'],
    quantity: map['quantity'],
    price: (map['price'] as num).toDouble(),
    costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
    productName: map['productName'],
    size: map['size'],
    addonsStr: map['addonsStr'],
  );
}

class Shift {
  final int? id;
  final int userId;
  final String startTime;
  final String? endTime;
  final double startCash;
  final double? endCash;
  final double salesTotal;
  final double refundsTotal;
  final int? branchId;
  final bool isSynced;

  Shift({
    this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.startCash,
    this.endCash,
    this.salesTotal = 0,
    this.refundsTotal = 0,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'startTime': startTime,
    'endTime': endTime,
    'startCash': startCash,
    'endCash': endCash,
    'salesTotal': salesTotal,
    'refundsTotal': refundsTotal,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
  };

  factory Shift.fromMap(Map<String, dynamic> map) => Shift(
    id: map['id'],
    userId: map['userId'],
    startTime: map['startTime'],
    endTime: map['endTime'],
    startCash: (map['startCash'] as num).toDouble(),
    endCash: (map['endCash'] as num?)?.toDouble(),
    salesTotal: (map['salesTotal'] as num?)?.toDouble() ?? 0,
    refundsTotal: (map['refundsTotal'] as num?)?.toDouble() ?? 0,
  );

  Shift copyWith({
    int? id,
    int? userId,
    String? startTime,
    String? endTime,
    double? startCash,
    double? endCash,
    double? salesTotal,
    double? refundsTotal,
  }) {
    return Shift(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startCash: startCash ?? this.startCash,
      endCash: endCash ?? this.endCash,
      salesTotal: salesTotal ?? this.salesTotal,
      refundsTotal: refundsTotal ?? this.refundsTotal,
    );
  }
}

class HeldOrder {
  final int id;
  final List<CartItem> items;
  final Customer? customer;
  final DateTime date;
  final String orderType;

  HeldOrder({
    required this.id,
    required this.items,
    this.customer,
    required this.date,
    required this.orderType,
  });

  double get total => items.fold(0, (sum, item) => sum + item.totalLinePrice);
}

class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final int? branchId;
  final bool isSynced;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    this.branchId,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'notes': notes,
    'branch_id': branchId,
    'is_synced': isSynced ? 1 : 0,
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    email: map['email'],
    notes: map['notes'],
    branchId: map['branch_id'],
    isSynced: (map['is_synced'] is int
        ? map['is_synced'] == 1
        : map['is_synced'] == true),
  );
}

class PaymentDevice {
  final int? id;
  final String name;
  final String type; // 'POS', 'CardReader', 'CashDrawer', etc.
  final String connectionType; // 'TCP', 'Serial', 'USB'
  final String? ipAddress;
  final int? port;
  final String? serialPort;
  final int? baudRate;
  final bool isActive;

  PaymentDevice({
    this.id,
    required this.name,
    required this.type,
    required this.connectionType,
    this.ipAddress,
    this.port,
    this.serialPort,
    this.baudRate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'connectionType': connectionType,
    'ipAddress': ipAddress,
    'port': port,
    'serialPort': serialPort,
    'baudRate': baudRate,
    'isActive': isActive ? 1 : 0,
  };

  factory PaymentDevice.fromMap(Map<String, dynamic> map) => PaymentDevice(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    connectionType: map['connectionType'],
    ipAddress: map['ipAddress'],
    port: map['port'],
    serialPort: map['serialPort'],
    baudRate: map['baudRate'],
    isActive: (map['isActive'] as int?) == 1,
  );
}

class Supplier {
  final int? id;
  final String name;
  final String? contact;
  final String? address;
  final String? createdAt;

  Supplier({
    this.id,
    required this.name,
    this.contact,
    this.address,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'contact': contact,
    'address': address,
    'createdAt': createdAt,
  };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
    id: map['id'],
    name: map['name'],
    contact: map['contact'],
    address: map['address'],
    createdAt: map['createdAt'],
  );
}

class PurchaseInvoice {
  final int? id;
  final String? invoiceNumber;
  final int? supplierId; // Made nullable to allow invoices without supplier
  final String date;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String? notes;
  final int? createdBy;
  final String? createdAt;

  PurchaseInvoice({
    this.id,
    this.invoiceNumber,
    this.supplierId, // No longer required
    required this.date,
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.total = 0,
    this.notes,
    this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'supplierId': supplierId,
    'date': date,
    'subtotal': subtotal,
    'tax': tax,
    'discount': discount,
    'total': total,
    'notes': notes,
    'createdBy': createdBy,
    'createdAt': createdAt,
  };

  factory PurchaseInvoice.fromMap(Map<String, dynamic> map) => PurchaseInvoice(
    id: map['id'],
    invoiceNumber: map['invoiceNumber'],
    supplierId: map['supplierId'],
    date: map['date'],
    subtotal: (map['subtotal'] as num).toDouble(),
    tax: (map['tax'] as num).toDouble(),
    discount: (map['discount'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
    notes: map['notes'],
    createdBy: map['createdBy'],
    createdAt: map['createdAt'],
  );
}

class PurchaseInvoiceItem {
  final int? id;
  final int invoiceId;
  final int itemId;
  final String? unit;
  final double unitsCount;
  final double qtyTotal;
  final double costPrice;
  final double? sellingPrice;
  final String? expiryDate;

  PurchaseInvoiceItem({
    this.id,
    required this.invoiceId,
    required this.itemId,
    this.unit,
    this.unitsCount = 1,
    required this.qtyTotal,
    required this.costPrice,
    this.sellingPrice,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceId': invoiceId,
    'itemId': itemId,
    'unit': unit,
    'unitsCount': unitsCount,
    'qtyTotal': qtyTotal,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'expiryDate': expiryDate,
  };

  factory PurchaseInvoiceItem.fromMap(Map<String, dynamic> map) =>
      PurchaseInvoiceItem(
        id: map['id'],
        invoiceId: map['invoiceId'],
        itemId: map['itemId'],
        unit: map['unit'],
        unitsCount: (map['unitsCount'] as num).toDouble(),
        qtyTotal: (map['qtyTotal'] as num).toDouble(),
        costPrice: (map['costPrice'] as num).toDouble(),
        sellingPrice: (map['sellingPrice'] as num?)?.toDouble(),
        expiryDate: map['expiryDate'],
      );
}

class StockBatch {
  final int? id;
  final int itemId;
  final String? batchNo;
  final double qty;
  final double originalQty;
  final String? unit;
  final String? expiryDate;
  final int? purchaseInvoiceItemId;
  final String? receivedDate;
  final double? costPrice;

  StockBatch({
    this.id,
    required this.itemId,
    this.batchNo,
    required this.qty,
    required this.originalQty,
    this.unit,
    this.expiryDate,
    this.purchaseInvoiceItemId,
    this.receivedDate,
    this.costPrice,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'itemId': itemId,
    'batchNo': batchNo,
    'qty': qty,
    'originalQty': originalQty,
    'unit': unit,
    'expiryDate': expiryDate,
    'purchaseInvoiceItemId': purchaseInvoiceItemId,
    'receivedDate': receivedDate,
    'costPrice': costPrice,
  };

  factory StockBatch.fromMap(Map<String, dynamic> map) => StockBatch(
    id: map['id'],
    itemId: map['itemId'],
    batchNo: map['batchNo'],
    qty: (map['qty'] as num).toDouble(),
    originalQty: (map['originalQty'] as num).toDouble(),
    unit: map['unit'],
    expiryDate: map['expiryDate'],
    purchaseInvoiceItemId: map['purchaseInvoiceItemId'],
    receivedDate: map['receivedDate'],
    costPrice: (map['costPrice'] as num?)?.toDouble(),
  );
}

// --- Ingredient Model (المكونات) ---
class Ingredient {
  final int? id;
  final String name;
  final String? unit; // كجم، لتر، قطعة
  final double currentStock;
  final double minStock;
  final double costPrice;

  Ingredient({
    this.id,
    required this.name,
    this.unit,
    this.currentStock = 0,
    this.minStock = 0,
    this.costPrice = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'unit': unit,
    'currentStock': currentStock,
    'minStock': minStock,
    'costPrice': costPrice,
  };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
    id: map['id'],
    name: map['name'],
    unit: map['unit'],
    currentStock: (map['currentStock'] as num?)?.toDouble() ?? 0,
    minStock: (map['minStock'] as num?)?.toDouble() ?? 0,
    costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0,
  );

  Ingredient copyWith({
    int? id,
    String? name,
    String? unit,
    double? currentStock,
    double? minStock,
    double? costPrice,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      costPrice: costPrice ?? this.costPrice,
    );
  }
}

// --- Product-Ingredient Relationship (ربط المنتج بالمكونات) ---
class ProductIngredient {
  final int? id;
  final int productId;
  final int ingredientId;
  final double quantity; // الكمية المطلوبة من المكون لكل وحدة منتج

  // Transient for UI display
  String? ingredientName;
  String? ingredientUnit;

  ProductIngredient({
    this.id,
    required this.productId,
    required this.ingredientId,
    required this.quantity,
    this.ingredientName,
    this.ingredientUnit,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'ingredientId': ingredientId,
    'quantity': quantity,
  };

  factory ProductIngredient.fromMap(Map<String, dynamic> map) =>
      ProductIngredient(
        id: map['id'],
        productId: map['productId'],
        ingredientId: map['ingredientId'],
        quantity: (map['quantity'] as num).toDouble(),
        ingredientName: map['ingredientName'],
        ingredientUnit: map['ingredientUnit'],
      );
}

// --- Database Helper ---

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseService? _service;

  Future<void> resetConnection() async {
    if (_service != null) {
      await _service!.close();
      _service = null;
    }
  }

  DatabaseHelper._init();

  Future<DatabaseService> get _dbService async {
    if (_service != null) return _service!;

    final prefs = await SharedPreferences.getInstance();
    final isPostgres = prefs.getBool('use_postgres') ?? false;

    if (isPostgres) {
      _service = PostgresService(
        host: prefs.getString('pg_host') ?? 'localhost',
        port: prefs.getInt('pg_port') ?? 5432,
        databaseName: prefs.getString('pg_db') ?? 'kpos',
        username: prefs.getString('pg_user') ?? 'postgres',
        password: prefs.getString('pg_pass') ?? 'password',
      );
    } else {
      _service = SqfliteService(
        path: 'kpos_v2.db',
        version: 25,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }

    try {
      debugPrint('Initializing database service...');
      await _service!.init();
      debugPrint('Database service initialized successfully');

      if (isPostgres) {
        debugPrint('Setting up PostgreSQL schema...');
        await _ensurePostgresSchema(_service!);
        debugPrint('PostgreSQL schema setup completed');
      } else {
        debugPrint('Running SQLite safety migrations...');
        await _runSafetyMigrations(_service!);
        debugPrint('SQLite migrations completed');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing database: $e');
      debugPrint('Stack trace: $stackTrace');

      if (isPostgres) {
        debugPrint('⚠️ PostgreSQL connection failed, falling back to SQLite');

        // Clear the failed service
        _service = null;

        // Fallback to SQLite
        _service = SqfliteService(
          path: 'kpos_v2.db',
          version: 25,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        );

        try {
          await _service!.init();
          await _runSafetyMigrations(_service!);
          debugPrint('✓ Fallback to SQLite successful');
        } catch (sqliteError) {
          debugPrint('❌ Even SQLite failed: $sqliteError');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
    return _service!;
  }

  /// Run manual migrations to ensure columns exist (Square & Suspenders)
  Future<void> _runSafetyMigrations(DatabaseService db) async {
    try {
      await _safeAddColumnInternal(db, 'products', 'iconCode', 'INTEGER');
      await _safeAddColumnInternal(db, 'products', 'colorValue', 'INTEGER');
      await _safeAddColumnInternal(db, 'categories', 'iconCode', 'INTEGER');
      await _safeAddColumnInternal(db, 'categories', 'colorValue', 'INTEGER');
      await _safeAddColumnInternal(
        db,
        'sales',
        'isCancelled',
        'INTEGER DEFAULT 0',
      );
      await _safeAddColumnInternal(db, 'sales', 'taxAmount', 'REAL DEFAULT 0');

      // Ensure Sync Columns on ALL tables
      final syncTables = [
        'users',
        'printers',
        'categories',
        'products',
        'addons',
        'discounts',
        'sales',
        'sale_items',
        'shifts',
        'customers',
        'payment_devices',
        'suppliers',
        'purchase_invoices',
        'purchase_invoice_items',
        'stock_batches',
        'expenses',
        'ingredients',
        'product_ingredients',
        'branches',
      ];

      for (var table in syncTables) {
        // We use try-catch inside _safeAddColumnInternal, but table might not exist if migration failed partially?
        // _safeAddColumnInternal handles column adding. If table doesn't exist, it might throw or just fail.
        // We really want to add columns.
        await _safeAddColumnInternal(db, table, 'branch_id', 'INTEGER');
        await _safeAddColumnInternal(
          db,
          table,
          'is_synced',
          'INTEGER DEFAULT 0',
        );
        await _safeAddColumnInternal(db, table, 'cloud_id', 'TEXT');
      }
    } catch (e) {
      debugPrint('Safety migration error: $e');
    }
  }

  Future<void> _safeAddColumnInternal(
    DatabaseService db,
    String table,
    String column,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
      debugPrint('Safety migration: Added $column to $table');
    } catch (e) {
      // Column likely exists
    }
  }

  Future<void> _ensurePostgresSchema(DatabaseService db) async {
    const idType = 'SERIAL PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNullable = 'INTEGER';
    const realType = 'DOUBLE PRECISION NOT NULL';
    const realTypeNullable = 'DOUBLE PRECISION';
    const boolType = 'BOOLEAN NOT NULL DEFAULT FALSE';

    debugPrint('📊 Starting PostgreSQL schema creation...');

    try {
      // Users table
      debugPrint('Creating users table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id $idType,
          name $textType,
          pin $textType,
          role $textType
        )
      ''');
      debugPrint('✓ Users table created');

      // Check and seed users
      final users = await db.query('users');
      debugPrint('Current users count: ${users.length}');

      if (users.isEmpty) {
        debugPrint('📝 Seeding default users...');

        try {
          final adminId = await db.insert(
            'users',
            User(name: 'Admin', pin: '1234', role: 'admin').toMap(),
          );
          debugPrint('✓ Admin user created with ID: $adminId');
        } catch (e) {
          debugPrint('⚠️ Error creating Admin user: $e');
        }

        try {
          final cashierId = await db.insert(
            'users',
            User(name: 'Cashier', pin: '0000', role: 'cashier').toMap(),
          );
          debugPrint('✓ Cashier user created with ID: $cashierId');
        } catch (e) {
          debugPrint('⚠️ Error creating Cashier user: $e');
        }

        // Verify seeding
        final verifyUsers = await db.query('users');
        debugPrint('✓ Total users after seeding: ${verifyUsers.length}');

        for (var user in verifyUsers) {
          debugPrint(
            '  - User: ${user['name']} (PIN: ${user['pin']}, Role: ${user['role']})',
          );
        }
      } else {
        debugPrint('✓ Users already exist, skipping seed');
        for (var user in users) {
          debugPrint(
            '  - Existing user: ${user['name']} (Role: ${user['role']})',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in users table setup: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }

    try {
      // Printers table
      debugPrint('Creating printers table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS printers (
          id $idType,
          name $textType,
          ipAddress $textType,
          port $integerType DEFAULT 9100,
          isReceipt $boolType
        )
      ''');
      debugPrint('✓ Printers table created');
    } catch (e) {
      debugPrint('⚠️ Error creating printers table: $e');
    }

    try {
      // Categories table
      debugPrint('Creating categories table...');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id $idType,
          name $textType,
          printerName $textTypeNullable,
          printerId $integerTypeNullable,
          iconCode $integerTypeNullable,
          colorValue $integerTypeNullable
        )
      ''');
      debugPrint('✓ Categories table created');

      // Seed General Category if empty
      final cats = await db.query('categories');
      debugPrint('Current categories count: ${cats.length}');

      if (cats.isEmpty) {
        debugPrint('📝 Seeding default category...');
        try {
          final catId = await db.insert(
            'categories',
            Category(name: 'General').toMap(),
          );
          debugPrint('✓ General category created with ID: $catId');
        } catch (e) {
          debugPrint('⚠️ Error creating General category: $e');
        }
      } else {
        debugPrint('✓ Categories already exist');
      }
    } catch (e) {
      debugPrint('⚠️ Error in categories table setup: $e');
    }

    // Create all remaining tables with error handling
    final tables = [
      {
        'name': 'products',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS products (
            id $idType,
            name $textType,
            categoryId $integerType,
            costPrice $realType,
            sellPrice $realType,
            laborCost $realType,
            imagePath $textTypeNullable,
            stock $integerType DEFAULT 0,
            priceSmall $realTypeNullable,
            priceMedium $realTypeNullable,
            priceLarge $realTypeNullable,
            iconCode $integerTypeNullable,
            colorValue $integerTypeNullable
          )
        ''',
      },
      {
        'name': 'addons',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS addons (
            id $idType,
            productId $integerTypeNullable,
            name $textType,
            price $realType,
            categoryId $integerTypeNullable
          )
        ''',
      },
      {
        'name': 'discounts',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS discounts (
            id $idType,
            name $textType,
            type $textType,
            value $realType,
            startDate $textType,
            endDate $textType,
            targetCategoryId $integerTypeNullable,
            targetProductId $integerTypeNullable
          )
        ''',
      },
      {
        'name': 'sales',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS sales (
            id $idType,
            invoiceId $textType,
            totalAmount $realType,
            taxAmount $realType DEFAULT 0,
            date $textType,
            paymentMethod $textType,
            orderType $textTypeNullable DEFAULT 'داخلي',
            customerId $integerTypeNullable,
            paymentDeviceId $integerTypeNullable,
            userId $integerType,
            isRefunded $boolType,
            isCancelled $boolType
          )
        ''',
      },
      {
        'name': 'sale_items',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS sale_items (
            id $idType,
            saleId $integerType,
            productId $integerType,
            quantity $integerType,
            price $realType,
            costPrice $realType DEFAULT 0,
            productName $textType,
            size $textTypeNullable,
            addonsStr $textTypeNullable
          )
        ''',
      },
      {
        'name': 'shifts',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS shifts (
            id $idType,
            userId $integerType,
            startTime $textType,
            endTime $textTypeNullable,
            startCash $realType,
            endCash $realTypeNullable,
            salesTotal $realType DEFAULT 0,
            refundsTotal $realType DEFAULT 0
          )
        ''',
      },
      {
        'name': 'customers',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS customers (
            id $idType,
            name $textType,
            phone $textTypeNullable,
            email $textTypeNullable,
            notes $textTypeNullable
          )
        ''',
      },
      {
        'name': 'payment_devices',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS payment_devices (
            id $idType,
            name $textType,
            type $textType,
            connectionType $textType,
            ipAddress $textTypeNullable,
            port $integerTypeNullable,
            serialPort $textTypeNullable,
            baudRate $integerTypeNullable,
            isActive $boolType
          )
        ''',
      },
      {
        'name': 'suppliers',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS suppliers (
            id $idType,
            name $textType,
            contact $textTypeNullable,
            address $textTypeNullable,
            createdAt $textTypeNullable
          )
        ''',
      },
      {
        'name': 'purchase_invoices',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS purchase_invoices (
            id $idType,
            invoiceNumber $textTypeNullable,
            supplierId $integerTypeNullable,
            date $textType,
            subtotal $realType DEFAULT 0,
            tax $realType DEFAULT 0,
            discount $realType DEFAULT 0,
            total $realType DEFAULT 0,
            notes $textTypeNullable,
            createdBy $integerTypeNullable,
            createdAt $textTypeNullable
          )
        ''',
      },
      {
        'name': 'purchase_invoice_items',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS purchase_invoice_items (
            id $idType,
            invoiceId $integerType,
            itemId $integerType,
            unit $textTypeNullable,
            unitsCount $realType DEFAULT 1,
            qtyTotal $realType,
            costPrice $realType,
            sellingPrice $realType,
            expiryDate $textTypeNullable
          )
        ''',
      },
      {
        'name': 'stock_batches',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS stock_batches (
            id $idType,
            itemId $integerType,
            batchNo $textTypeNullable,
            qty $realType,
            originalQty $realType,
            unit $textTypeNullable,
            expiryDate $textTypeNullable,
            purchaseInvoiceItemId $integerTypeNullable,
            receivedDate $textTypeNullable,
            costPrice $realType
          )
        ''',
      },
      {
        'name': 'expenses',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS expenses (
            id $idType,
            title $textType,
            amount $realType,
            date $textType,
            notes $textTypeNullable,
            category $textTypeNullable,
            userId $integerTypeNullable,
            createdAt $textTypeNullable
          )
        ''',
      },
      {
        'name': 'ingredients',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS ingredients (
            id $idType,
            name $textType,
            unit $textTypeNullable,
            currentStock $realType DEFAULT 0,
            minStock $realType DEFAULT 0,
            costPrice $realType DEFAULT 0
          )
        ''',
      },
      {
        'name': 'product_ingredients',
        'sql':
            '''
          CREATE TABLE IF NOT EXISTS product_ingredients (
            id $idType,
            productId $integerType,
            ingredientId $integerType,
            quantity $realType
          )
        ''',
      },
    ];

    int successCount = 0;
    int failCount = 0;

    for (var table in tables) {
      try {
        debugPrint('Creating ${table['name']} table...');
        await db.execute(table['sql'] as String);
        debugPrint('✓ ${table['name']} table created');
        successCount++;
      } catch (e) {
        debugPrint('❌ Error creating ${table['name']} table: $e');
        failCount++;
      }
    }

    debugPrint('');
    debugPrint('📊 Schema creation summary:');
    debugPrint('  ✓ Success: $successCount tables');
    debugPrint('  ❌ Failed: $failCount tables');
    debugPrint('  📝 Total: ${tables.length} tables');

    if (failCount > 0) {
      debugPrint(
        '⚠️ Warning: Some tables failed to create. System may not work properly.',
      );
    } else {
      debugPrint('✓ All tables created successfully!');
    }
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    return await query(table);
  }

  // --- Proxy Methods ---

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _dbService;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await _dbService;
    return db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _dbService;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _dbService;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await _dbService;
    return db.rawQuery(sql, arguments);
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final db = await _dbService;
    return db.execute(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await _dbService;
    return db.rawUpdate(sql, arguments);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT,
          startCash REAL NOT NULL,
          endCash REAL,
          salesTotal REAL DEFAULT 0,
          refundsTotal REAL DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE products ADD COLUMN priceSmall REAL");
        await db.execute("ALTER TABLE products ADD COLUMN priceMedium REAL");
        await db.execute("ALTER TABLE products ADD COLUMN priceLarge REAL");
        await db.execute("ALTER TABLE sale_items ADD COLUMN size TEXT");
        await db.execute("ALTER TABLE sale_items ADD COLUMN addonsStr TEXT");
      } catch (e) {
        // Ignore if exists
      }
    }
    if (oldVersion < 4) {
      // Ensure columns exist (fix for missing columns in v3)
      final List<Map<String, dynamic>> columns = await db.rawQuery(
        "PRAGMA table_info(products)",
      );
      final bool hasPriceSmall = columns.any((c) => c['name'] == 'priceSmall');
      if (!hasPriceSmall) {
        try {
          await db.execute("ALTER TABLE products ADD COLUMN priceSmall REAL");
          await db.execute("ALTER TABLE products ADD COLUMN priceMedium REAL");
          await db.execute("ALTER TABLE products ADD COLUMN priceLarge REAL");
        } catch (e) {
          // Ignore if exists
        }
      }

      final List<Map<String, dynamic>> itemColumns = await db.rawQuery(
        "PRAGMA table_info(sale_items)",
      );
      final bool hasSize = itemColumns.any((c) => c['name'] == 'size');
      if (!hasSize) {
        try {
          await db.execute("ALTER TABLE sale_items ADD COLUMN size TEXT");
          await db.execute("ALTER TABLE sale_items ADD COLUMN addonsStr TEXT");
        } catch (e) {
          // Ignore if exists
        }
      }
    }
    if (oldVersion < 6) {
      // v5 or v6 fix: Ensure shifts table endCash is nullable
      await db.execute("DROP TABLE IF EXISTS shifts_old");
      await db.execute("ALTER TABLE shifts RENAME TO shifts_old");
      await db.execute('''
        CREATE TABLE shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT,
          startCash REAL NOT NULL,
          endCash REAL, -- Nullable
          salesTotal REAL DEFAULT 0,
          refundsTotal REAL DEFAULT 0
        )
      ''');
      await db.execute('''
        INSERT INTO shifts (id, userId, startTime, endTime, startCash, endCash, salesTotal, refundsTotal)
        SELECT id, userId, startTime, endTime, startCash, endCash, salesTotal, refundsTotal
        FROM shifts_old
      ''');
      await db.execute("DROP TABLE shifts_old");
    }
    if (oldVersion < 8) {
      try {
        await db.execute("ALTER TABLE categories ADD COLUMN printerName TEXT");
      } catch (e) {
        /* ignore */
      }
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS printers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          ipAddress TEXT NOT NULL,
          port INTEGER DEFAULT 9100,
          isReceipt INTEGER DEFAULT 0
        )
      ''');
      try {
        await db.execute(
          "ALTER TABLE categories ADD COLUMN printerId INTEGER REFERENCES printers(id)",
        );
      } catch (e) {
        /* ignore */
      }
    }
    if (oldVersion < 10) {
      try {
        await db.execute(
          "ALTER TABLE sale_items ADD COLUMN costPrice REAL DEFAULT 0",
        );
        await db.execute("ALTER TABLE addons ADD COLUMN categoryId INTEGER");
      } catch (e) {
        /* ignore */
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute(
          "ALTER TABLE discounts ADD COLUMN targetProductId INTEGER",
        );
      } catch (e) {
        /* ignore */
      }
    }
    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          email TEXT,
          notes TEXT
        )
      ''');
    }
    if (oldVersion < 13) {
      try {
        await db.execute(
          "ALTER TABLE sales ADD COLUMN orderType TEXT DEFAULT 'داخلي'",
        );
      } catch (e) {
        /* ignore */
      }
    }
    if (oldVersion < 14) {
      // Fix addons table to allow NULL productId for shared addons
      try {
        // SQLite doesn't support ALTER COLUMN, so we need to recreate the table
        await db.execute('''
          CREATE TABLE addons_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            categoryId INTEGER,
            FOREIGN KEY (productId) REFERENCES products (id)
          )
        ''');
        await db.execute('''
          INSERT INTO addons_new (id, productId, name, price, categoryId)
          SELECT id, productId, name, price, categoryId FROM addons
        ''');
        await db.execute('DROP TABLE addons');
        await db.execute('ALTER TABLE addons_new RENAME TO addons');
      } catch (e) {
        debugPrint('Migration to v14 error: $e');
        // If migration fails, try to check if column already allows NULL
        // In that case, ignore the error
      }
    }
    if (oldVersion < 15) {
      // Add payment devices table
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS payment_devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            connectionType TEXT NOT NULL,
            ipAddress TEXT,
            port INTEGER,
            serialPort TEXT,
            baudRate INTEGER,
            isActive INTEGER NOT NULL DEFAULT 1
          )
        ''');
      } catch (e) {
        debugPrint('Migration to v15 error: $e');
      }
    }
    if (oldVersion < 16) {
      // Add paymentDeviceId to sales table
      try {
        // Check if column already exists
        final tableInfo = await db.rawQuery('PRAGMA table_info(sales)');
        final hasColumn = tableInfo.any(
          (col) => col['name'] == 'paymentDeviceId',
        );
        if (!hasColumn) {
          await db.execute(
            'ALTER TABLE sales ADD COLUMN paymentDeviceId INTEGER',
          );
          debugPrint('✓ Added paymentDeviceId column to sales table');
        } else {
          debugPrint('paymentDeviceId column already exists in sales table');
        }
      } catch (e) {
        debugPrint('Migration to v16 error: $e');
        // Try to add column anyway (might fail if already exists, which is OK)
        try {
          await db.execute(
            'ALTER TABLE sales ADD COLUMN paymentDeviceId INTEGER',
          );
        } catch (e2) {
          debugPrint('Failed to add paymentDeviceId column: $e2');
        }
      }
    }
    if (oldVersion < 17) {
      try {
        // Add new columns to products
        // using try-catch blocks individually or checking column existence is safer,
        // but for simplicity in this generated code we wrap the whole block or assume standard upgrade flow.

        // We'll use a helper to check/add columns to avoid errors if re-running
        await _safeAddColumn(db, 'products', 'unit', 'TEXT');
        await _safeAddColumn(
          db,
          'products',
          'unitsPerPackage',
          'REAL DEFAULT 1',
        );
        await _safeAddColumn(db, 'products', 'minStock', 'REAL DEFAULT 0');
        await _safeAddColumn(db, 'products', 'isActive', 'INTEGER DEFAULT 1');

        // Create new Inventory tables
        await db.execute('''
          CREATE TABLE IF NOT EXISTS suppliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT,
            address TEXT,
            createdAt TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS purchase_invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceNumber TEXT,
            supplierId INTEGER,
            date TEXT NOT NULL,
            subtotal REAL DEFAULT 0,
            tax REAL DEFAULT 0,
            discount REAL DEFAULT 0,
            total REAL DEFAULT 0,
            notes TEXT,
            createdBy INTEGER,
            createdAt TEXT,
            FOREIGN KEY (supplierId) REFERENCES suppliers(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS purchase_invoice_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceId INTEGER NOT NULL,
            itemId INTEGER NOT NULL,
            unit TEXT,
            unitsCount REAL DEFAULT 1,
            qtyTotal REAL NOT NULL,
            costPrice REAL NOT NULL,
            sellingPrice REAL,
            expiryDate TEXT,
            FOREIGN KEY (invoiceId) REFERENCES purchase_invoices(id),
            FOREIGN KEY (itemId) REFERENCES products(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS stock_batches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId INTEGER NOT NULL,
            batchNo TEXT,
            qty REAL NOT NULL,
            originalQty REAL NOT NULL,
            unit TEXT,
            expiryDate TEXT,
            purchaseInvoiceItemId INTEGER,
            receivedDate TEXT,
            costPrice REAL,
            FOREIGN KEY (itemId) REFERENCES products(id)
          )
        ''');

        debugPrint('Migration to v17 (Inventory) completed');
      } catch (e) {
        debugPrint('Migration to v17 error: $e');
      }
    }
    if (oldVersion < 18) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            notes TEXT,
            category TEXT,
            userId INTEGER,
            createdAt TEXT
          )
        ''');
        debugPrint('Migration to v18 (Expenses) completed');
      } catch (e) {
        debugPrint('Migration to v18 error: $e');
      }
    }
    if (oldVersion < 19) {
      try {
        // جدول المكونات (Ingredients)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            unit TEXT,
            currentStock REAL DEFAULT 0,
            minStock REAL DEFAULT 0,
            costPrice REAL DEFAULT 0
          )
        ''');

        // جدول ربط المنتجات بالمكونات
        await db.execute('''
          CREATE TABLE IF NOT EXISTS product_ingredients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER NOT NULL,
            ingredientId INTEGER NOT NULL,
            quantity REAL NOT NULL,
            FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE,
            FOREIGN KEY (ingredientId) REFERENCES ingredients(id) ON DELETE CASCADE
          )
        ''');

        debugPrint('Migration to v19 (Ingredients) completed');
      } catch (e) {
        debugPrint('Migration to v19 error: $e');
      }
    }
    if (oldVersion < 20) {
      try {
        // Create suppliers table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS suppliers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            contact TEXT,
            address TEXT,
            createdAt TEXT
          )
        ''');

        // Create purchase_invoices table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS purchase_invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceNumber TEXT,
            supplierId INTEGER,
            date TEXT NOT NULL,
            subtotal REAL DEFAULT 0,
            tax REAL DEFAULT 0,
            discount REAL DEFAULT 0,
            total REAL DEFAULT 0,
            notes TEXT,
            createdBy INTEGER,
            createdAt TEXT,
            FOREIGN KEY (supplierId) REFERENCES suppliers(id)
          )
        ''');

        // Create purchase_invoice_items table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS purchase_invoice_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoiceId INTEGER NOT NULL,
            itemId INTEGER NOT NULL,
            unit TEXT,
            unitsCount REAL DEFAULT 1,
            qtyTotal REAL,
            costPrice REAL,
            sellingPrice REAL,
            expiryDate TEXT,
            FOREIGN KEY (invoiceId) REFERENCES purchase_invoices(id),
            FOREIGN KEY (itemId) REFERENCES ingredients(id)
          )
        ''');

        // Create stock_batches table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS stock_batches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            itemId INTEGER NOT NULL,
            batchNo TEXT,
            qty REAL,
            originalQty REAL,
            unit TEXT,
            expiryDate TEXT,
            purchaseInvoiceItemId INTEGER,
            receivedDate TEXT,
            costPrice REAL,
            FOREIGN KEY (itemId) REFERENCES ingredients(id)
          )
        ''');

        debugPrint('Migration to v20 (Suppliers/Inventory) completed');
      } catch (e) {
        debugPrint('Migration to v20 error: $e');
      }
    }
    if (oldVersion < 21) {
      try {
        await _safeAddColumn(db, 'categories', 'iconCode', 'INTEGER');
        await _safeAddColumn(db, 'categories', 'colorValue', 'INTEGER');
        debugPrint('Migration to v21 (Category Icons/Colors) completed');
      } catch (e) {
        debugPrint('Migration to v21 error: $e');
      }
    }
    if (oldVersion < 22) {
      try {
        await _safeAddColumn(db, 'products', 'iconCode', 'INTEGER');
        await _safeAddColumn(db, 'products', 'colorValue', 'INTEGER');
        debugPrint('Migration to v22 (Product Icons/Colors) completed');
      } catch (e) {
        debugPrint('Migration to v22 error: $e');
      }
    }
    if (oldVersion < 23) {
      try {
        // Ensure products table has iconCode and colorValue even if already v22
        await _safeAddColumn(db, 'products', 'iconCode', 'INTEGER');
        await _safeAddColumn(db, 'products', 'colorValue', 'INTEGER');
        debugPrint('Migration to v23 (Product Icons/Colors check) completed');
      } catch (e) {
        debugPrint('Migration to v23 error: $e');
      }
    }
    if (oldVersion < 24) {
      try {
        // Add isCancelled column to sales table
        await _safeAddColumn(db, 'sales', 'isCancelled', 'INTEGER DEFAULT 0');
        debugPrint('Migration to v24 (Sales cancellation) completed');
      } catch (e) {
        debugPrint('Migration to v24 error: $e');
      }
    }
    if (oldVersion < 25) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS branches (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT,
            is_active INTEGER DEFAULT 1
          )
        ''');

        final tables = [
          'users',
          'categories',
          'products',
          'sales',
          'shifts',
          'customers',
          'expenses',
        ];
        for (var table in tables) {
          await _safeAddColumn(db, table, 'branch_id', 'INTEGER');
          await _safeAddColumn(db, table, 'is_synced', 'INTEGER DEFAULT 0');
        }
        debugPrint('Migration to v25 (Branch Support) completed');
      } catch (e) {
        debugPrint('Migration to v25 error: $e');
      }
    }
  }

  Future<void> _safeAddColumn(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Ignore if exists
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        pin $textType,
        role $textType,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.insert(
      'users',
      User(name: 'Admin', pin: '1234', role: 'admin').toMap(),
    );
    await db.insert(
      'users',
      User(name: 'Cashier', pin: '0000', role: 'cashier').toMap(),
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS branches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        printerName TEXT,
        printerId INTEGER REFERENCES printers(id),
        iconCode INTEGER,
        colorValue INTEGER,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE printers (
        id $idType,
        name $textType,
        ipAddress $textType,
        port $integerType DEFAULT 9100,
        isReceipt $boolType DEFAULT 0
      )
    ''');

    await db.insert('categories', Category(name: 'General').toMap());

    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        categoryId $integerType,
        costPrice $realType,
        sellPrice $realType,
        laborCost $realType,
        imagePath TEXT,
        stock $integerType,
        priceSmall REAL,
        priceMedium REAL,
        priceLarge REAL,
        iconCode INTEGER,
        colorValue INTEGER,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0,
        unit TEXT,
        unitsPerPackage REAL DEFAULT 1,
        minStock REAL DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE addons (
        id $idType,
        productId INTEGER,
        name $textType,
        price $realType,
        categoryId INTEGER,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE discounts (
        id $idType,
        name $textType,
        type $textType,
        value $realType,
        startDate $textType,
        endDate $textType,
        targetCategoryId INTEGER,
        targetProductId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        invoiceId $textType,
        totalAmount $realType,
        taxAmount $realType DEFAULT 0,
        date $textType,
        paymentMethod $textType,
        orderType TEXT DEFAULT 'داخلي',
        customerId INTEGER,
        paymentDeviceId INTEGER,
        userId $integerType,
        isRefunded $boolType,
        isCancelled $boolType DEFAULT 0,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        saleId $integerType,
        productId $integerType,
        quantity $integerType,
        price $realType,
        costPrice $realType DEFAULT 0,
        productName $textType,
        size TEXT,
        addonsStr TEXT,
        FOREIGN KEY (saleId) REFERENCES sales (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE shifts (
        id $idType,
        userId $integerType,
        startTime $textType,
        endTime TEXT,
        startCash $realType,
        endCash REAL,
        salesTotal $realType DEFAULT 0,
        refundsTotal $realType DEFAULT 0,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        name $textType,
        phone TEXT,
        email TEXT,
        notes TEXT,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_devices (
        id $idType,
        name $textType,
        type $textType,
        connectionType $textType,
        ipAddress TEXT,
        port INTEGER,
        serialPort TEXT,
        baudRate INTEGER,
        isActive $boolType DEFAULT 1
      )
    ''');

    // Inventory Tables for New Creation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id $idType,
        name $textType,
        contact TEXT,
        address TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_invoices (
        id $idType,
        invoiceNumber TEXT,
        supplierId INTEGER,
        date $textType,
        subtotal $realType DEFAULT 0,
        tax $realType DEFAULT 0,
        discount $realType DEFAULT 0,
        total $realType DEFAULT 0,
        notes TEXT,
        createdBy INTEGER,
        createdAt TEXT,
        FOREIGN KEY (supplierId) REFERENCES suppliers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_invoice_items (
        id $idType,
        invoiceId $integerType,
        itemId $integerType,
        unit TEXT,
        unitsCount $realType DEFAULT 1,
        qtyTotal $realType,
        costPrice $realType,
        sellingPrice $realType,
        expiryDate TEXT,
        FOREIGN KEY (invoiceId) REFERENCES purchase_invoices(id),
        FOREIGN KEY (itemId) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stock_batches (
        id $idType,
        itemId $integerType,
        batchNo TEXT,
        qty $realType,
        originalQty $realType,
        unit TEXT,
        expiryDate TEXT,
        purchaseInvoiceItemId INTEGER,
        receivedDate TEXT,
        costPrice $realType,
        FOREIGN KEY (itemId) REFERENCES products(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id $idType,
        title $textType,
        amount $realType,
        date $textType,
        notes TEXT,
        category TEXT,
        userId INTEGER,
        createdAt TEXT,
        branch_id INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Ingredients Tables (v19)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ingredients (
        id $idType,
        name $textType,
        unit TEXT,
        currentStock $realType DEFAULT 0,
        minStock $realType DEFAULT 0,
        costPrice $realType DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_ingredients (
        id $idType,
        productId $integerType,
        ingredientId $integerType,
        quantity $realType,
        FOREIGN KEY (productId) REFERENCES products(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredientId) REFERENCES ingredients(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await _dbService;
    await db.delete('sales');
    await db.delete('sale_items');
    await db.delete('products');
    await db.delete('categories');
    await db.delete('users');
    await db.insert(
      'users',
      User(name: 'Admin', pin: '1234', role: 'admin').toMap(),
    );
  }

  Future<List<Customer>> getCustomers() async {
    final db = await _dbService;
    final res = await db.query('customers');
    return res.map((e) => Customer.fromMap(e)).toList();
  }

  Future<int> addCustomer(Customer customer) async {
    final db = await _dbService;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<PaymentDevice>> getPaymentDevices() async {
    final db = await _dbService;
    final res = await db.query('payment_devices', orderBy: 'name');
    return res.map((e) => PaymentDevice.fromMap(e)).toList();
  }

  Future<int> addPaymentDevice(PaymentDevice device) async {
    final db = await _dbService;
    return await db.insert('payment_devices', device.toMap());
  }

  Future<int> updatePaymentDevice(PaymentDevice device) async {
    final db = await _dbService;
    return await db.update(
      'payment_devices',
      device.toMap(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
  }

  Future<int> deletePaymentDevice(int id) async {
    final db = await _dbService;
    return await db.delete('payment_devices', where: 'id = ?', whereArgs: [id]);
  }

  // --- Branch Methods ---
  Future<List<Branch>> getBranches() async {
    final db = await _dbService;
    final res = await db.query('branches');
    return res.map((e) => Branch.fromMap(e)).toList();
  }

  Future<int> addBranch(Branch branch) async {
    final db = await _dbService;
    return await db.insert('branches', branch.toMap());
  }

  Future<int> updateBranch(Branch branch) async {
    final db = await _dbService;
    return await db.update(
      'branches',
      branch.toMap(),
      where: 'id = ?',
      whereArgs: [branch.id],
    );
  }

  Future<int> deleteBranch(int id) async {
    final db = await _dbService;
    return await db.delete('branches', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<User>> getAllUsers() async {
    final db = await _dbService;
    final res = await db.query('users');
    return res.map((e) => User.fromMap(e)).toList();
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _dbService;
    final res = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [saleId],
    );
    return res.map((e) => SaleItem.fromMap(e)).toList();
  }

  Future<int> updateCategoryPrinter(int catId, String? printerName) async {
    final db = await _dbService;
    return await db.update(
      'categories',
      {'printerName': printerName},
      where: 'id = ?',
      whereArgs: [catId],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _dbService;
    // Note: We might want to handle products that belong to this category.
    // For now, we just delete the category.
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Expenses CRUD ---

  Future<int> addExpense(Expense expense) async {
    final db = await _dbService;
    return await db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await _dbService;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await _dbService;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpenses(DateTime start, DateTime end) async {
    final db = await _dbService;
    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();
    final res = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );
    return res.map((e) => Expense.fromMap(e)).toList();
  }

  // --- Ingredients CRUD ---

  Future<List<Ingredient>> getIngredients() async {
    final db = await _dbService;
    final res = await db.query('ingredients', orderBy: 'name');
    return res.map((e) => Ingredient.fromMap(e)).toList();
  }

  Future<int> addIngredient(Ingredient ingredient) async {
    final db = await _dbService;
    return await db.insert('ingredients', ingredient.toMap());
  }

  Future<int> updateIngredient(Ingredient ingredient) async {
    final db = await _dbService;
    return await db.update(
      'ingredients',
      ingredient.toMap(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<int> deleteIngredient(int id) async {
    final db = await _dbService;
    // Also delete related product_ingredients
    await db.delete(
      'product_ingredients',
      where: 'ingredientId = ?',
      whereArgs: [id],
    );
    return await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateIngredientStock(int ingredientId, double delta) async {
    final db = await _dbService;
    await db.rawUpdate(
      'UPDATE ingredients SET currentStock = currentStock + ? WHERE id = ?',
      [delta, ingredientId],
    );
  }

  Future<void> deductIngredientStock(int ingredientId, double amount) async {
    await updateIngredientStock(ingredientId, -amount);
  }

  // --- Product Ingredients CRUD ---

  Future<List<ProductIngredient>> getProductIngredients(int productId) async {
    final db = await _dbService;
    final res = await db.rawQuery(
      '''
      SELECT pi.*, i.name as ingredientName, i.unit as ingredientUnit
      FROM product_ingredients pi
      JOIN ingredients i ON pi.ingredientId = i.id
      WHERE pi.productId = ?
    ''',
      [productId],
    );
    return res.map((e) => ProductIngredient.fromMap(e)).toList();
  }

  Future<int> addProductIngredient(ProductIngredient pi) async {
    final db = await _dbService;
    return await db.insert('product_ingredients', pi.toMap());
  }

  Future<int> deleteProductIngredient(int id) async {
    final db = await _dbService;
    return await db.delete(
      'product_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllProductIngredients(int productId) async {
    final db = await _dbService;
    await db.delete(
      'product_ingredients',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> saveProductIngredients(
    int productId,
    List<ProductIngredient> ingredients,
  ) async {
    final db = await _dbService;
    // Delete existing
    await db.delete(
      'product_ingredients',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    // Insert new
    for (var ing in ingredients) {
      await db.insert('product_ingredients', {
        'productId': productId,
        'ingredientId': ing.ingredientId,
        'quantity': ing.quantity,
      });
    }
  }

  // Deduct ingredients for a product sale
  Future<void> deductIngredientsForSale(int productId, int quantity) async {
    try {
      final productIngredients = await getProductIngredients(productId);
      debugPrint(
        "Deducting ingredients for Product $productId (Qty: $quantity). Found ${productIngredients.length} ingredients.",
      );

      if (productIngredients.isEmpty) {
        debugPrint("No ingredients to deduct for product $productId");
        return;
      }

      for (var pi in productIngredients) {
        final deduction = pi.quantity * quantity;
        debugPrint(
          " - Ingredient ${pi.ingredientId} (${pi.ingredientName}): Deducting $deduction (Rate: ${pi.quantity})",
        );
        await deductIngredientStock(pi.ingredientId, deduction);
      }
    } catch (e) {
      debugPrint("Error in deductIngredientsForSale: $e");
      // Rethrow to let the caller handle it (e.g. show error in UI)
      rethrow;
    }
  }
}

// --- State Management ---

class AppState extends ChangeNotifier {
  User? currentUser;
  Shift? currentShift; // Track active shift
  List<Category> categories = [];
  List<Product> products = [];
  List<Discount> activeDiscounts = [];
  List<CartItem> cart = [];
  List<HeldOrder> heldOrders = [];
  List<Printer> availablePrinters = [];
  List<User> users = []; // Added for employee filter
  List<Expense> expenses = []; // Expenses list
  List<Ingredient> ingredients = []; // Ingredients list
  List<Branch> availableBranches = []; // Branches
  Branch? activeBranch;
  Customer? selectedCustomer; // Selected customer for current sale
  bool isLoading = false; // Loading state for async operations
  Map<String, String> restaurantSettings = {
    'name': 'KPOS Restaurant',
    'address': '123 Main St',
    'phone': '555-0123',
  };

  AppState() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadRestaurantSettings();
    await refreshProducts();
    await refreshCategories();
    await refreshDiscounts();
    await refreshPrinters();
    await refreshUsers();
    await refreshUsers();
    await refreshIngredients();
    await refreshBranches();
    await _loadActiveBranch();
  }

  Future<void> _loadRestaurantSettings() async {
    final prefs = await SharedPreferences.getInstance();
    restaurantSettings = {
      'name': prefs.getString('res_name') ?? 'KPOS Restaurant',
      'address': prefs.getString('res_address') ?? '123 Main St',
      'phone': prefs.getString('res_phone') ?? '555-0123',
      'tax': (prefs.getDouble('res_tax') ?? 0.0).toString(),
    };
    notifyListeners();
  }

  Future<void> refreshUsers() async {
    users = await getAllUsers();
    notifyListeners();
  }

  // --- Ingredients Logic ---
  Future<void> refreshIngredients() async {
    ingredients = await DatabaseHelper.instance.getIngredients();
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await DatabaseHelper.instance.addIngredient(ingredient);
    await refreshIngredients();
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await DatabaseHelper.instance.updateIngredient(ingredient);
    await refreshIngredients();
  }

  Future<void> deleteIngredient(int id) async {
    await DatabaseHelper.instance.deleteIngredient(id);
    ingredients.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // --- Expenses Logic ---
  Future<void> loadExpenses(
    DateTime start,
    DateTime end, {
    String? category,
  }) async {
    expenses = await DatabaseHelper.instance.getExpenses(start, end);
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.addExpense(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    // We assume the caller will reload if necessary, or we could remove from list locally
    expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    // Update the local list
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
    }
    notifyListeners();
  }

  Future<void> login(String pin) async {
    final db = DatabaseHelper.instance;
    debugPrint('Attempting login with PIN: $pin');
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    debugPrint('Login result count: ${result.length}');
    if (result.isNotEmpty) {
      debugPrint('User found: ${result.first}');
      currentUser = User.fromMap(result.first);
      await _checkForActiveShift();
      notifyListeners();
    } else {
      debugPrint('No user found for PIN');
      throw Exception('Invalid PIN');
    }
  }

  Future<void> _checkForActiveShift() async {
    if (currentUser == null) {
      currentShift = null;
      return;
    }

    final db = DatabaseHelper.instance;
    // البحث عن الوردية المفتوحة للمستخدم الحالي فقط
    final res = await db.query(
      'shifts',
      where: 'endTime IS NULL AND userId = ?',
      whereArgs: [currentUser!.id],
      limit: 1,
    );

    if (res.isNotEmpty) {
      currentShift = Shift.fromMap(res.first);
      debugPrint('وردية نشطة موجودة للمستخدم: ${currentUser!.name}');
    } else {
      currentShift = null;
      debugPrint('لا توجد وردية نشطة للمستخدم: ${currentUser!.name}');
    }
  }

  Future<void> refreshPrinters() async {
    final db = DatabaseHelper.instance;
    final res = await db.query('printers');
    availablePrinters = res.map((e) => Printer.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addPrinter(Printer printer) async {
    final db = DatabaseHelper.instance;
    await db.insert('printers', printer.toMap());
    await refreshPrinters();
  }

  Future<void> updatePrinter(Printer printer) async {
    final db = DatabaseHelper.instance;
    await db.update(
      'printers',
      printer.toMap(),
      where: 'id = ?',
      whereArgs: [printer.id],
    );
    await refreshPrinters();
  }

  Future<void> deletePrinter(int id) async {
    final db = DatabaseHelper.instance;
    await db.delete('printers', where: 'id = ?', whereArgs: [id]);
    await db.update(
      'categories',
      {'printerId': null},
      where: 'printerId = ?',
      whereArgs: [id],
    );
    await refreshPrinters();
    await refreshCategories();
  }

  Future<void> openShift(double startCash) async {
    if (currentUser == null || currentShift != null) return;

    final db = DatabaseHelper.instance;
    final newShift = Shift(
      userId: currentUser!.id!,
      startTime: DateTime.now().toIso8601String(),
      startCash: startCash,
    );

    final id = await db.insert('shifts', newShift.toMap());
    currentShift = newShift.copyWith(id: id);
    notifyListeners();
  }

  Future<void> closeShift(double endCash) async {
    if (currentShift == null) return;

    final db = DatabaseHelper.instance;

    final salesRes = await db.rawQuery(
      'SELECT SUM(totalAmount) as total FROM sales WHERE date >= ?',
      [currentShift!.startTime],
    );
    final totalSales = (salesRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final updatedShift = currentShift!.copyWith(
      endTime: DateTime.now().toIso8601String(),
      endCash: endCash,
      salesTotal: totalSales,
    );

    await db.update(
      'shifts',
      updatedShift.toMap(),
      where: 'id = ?',
      whereArgs: [currentShift!.id],
    );

    currentShift = null;
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    final db = DatabaseHelper.instance;
    await db.insert('users', user.toMap());
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    final db = DatabaseHelper.instance;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    final db = DatabaseHelper.instance;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  Future<List<User>> getAllUsers() async {
    final db = DatabaseHelper.instance;
    final res = await db.query('users');
    return res.map((e) => User.fromMap(e)).toList();
  }

  void logout() {
    currentUser = null;
    cart.clear();
    notifyListeners();
  }

  Future<void> refreshCategories() async {
    final data = await DatabaseHelper.instance.queryAll('categories');
    categories = data.map((e) => Category.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await refreshCategories();
  }

  Future<void> refreshProducts() async {
    final data = await DatabaseHelper.instance.queryAll('products');
    final productsList = data.map((e) => Product.fromMap(e)).toList();

    final db = DatabaseHelper.instance;
    for (var i = 0; i < productsList.length; i++) {
      final addonData = await db.query(
        'addons',
        where: 'productId = ?',
        whereArgs: [productsList[i].id],
      );
      productsList[i].availableAddons = addonData
          .map((e) => Addon.fromMap(e))
          .toList();
    }

    products = productsList;
    notifyListeners();
  }

  Future<void> refreshDiscounts() async {
    final data = await DatabaseHelper.instance.queryAll('discounts');
    activeDiscounts = data.map((e) => Discount.fromMap(e)).toList();
    notifyListeners();
  }

  // --- Held Orders Logic ---
  void suspendOrder(String orderType) {
    if (cart.isEmpty) return;

    final held = HeldOrder(
      id: DateTime.now().millisecondsSinceEpoch,
      items: List<CartItem>.from(cart),
      customer: selectedCustomer,
      date: DateTime.now(),
      orderType: orderType,
    );
    heldOrders.add(held);
    clearCart();
    notifyListeners();
  }

  void restoreHeldOrder(HeldOrder order) {
    cart = List<CartItem>.from(order.items);
    selectedCustomer = order.customer;
    heldOrders.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }

  void deleteHeldOrder(int id) {
    heldOrders.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  void addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    double? price,
    List<Addon> addons = const [],
  }) {
    final effectivePrice = price ?? product.sellPrice;

    final index = cart.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          _areAddonsEqual(item.addons, addons),
    );

    if (index != -1) {
      cart[index].quantity += quantity;
    } else {
      cart.add(
        CartItem(
          product: product,
          quantity: quantity,
          size: size,
          unitPrice: effectivePrice,
          addons: addons,
        ),
      );
    }
    notifyListeners();
  }

  bool _areAddonsEqual(List<Addon> a, List<Addon> b) {
    if (a.length != b.length) return false;
    final idsA = a.map((e) => e.id).toSet();
    final idsB = b.map((e) => e.id).toSet();
    return idsA.containsAll(idsB);
  }

  void updateCartItemQuantity(int index, int quantity) {
    if (index >= 0 && index < cart.length && quantity > 0) {
      cart[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    cart.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  // --- Branch Methods ---
  Future<void> refreshBranches() async {
    try {
      availableBranches = await DatabaseHelper.instance.getBranches();
      debugPrint('Branches refreshed: ${availableBranches.length}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing branches: $e');
    }
  }

  Future<void> _loadActiveBranch() async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getInt('active_branch_id');
    if (branchId != null) {
      if (availableBranches.isEmpty) {
        await refreshBranches();
      }
      try {
        activeBranch = availableBranches.firstWhere((b) => b.id == branchId);
      } catch (e) {
        activeBranch = null; // Branch might have been deleted
        await prefs.remove('active_branch_id');
      }
    } else {
      // Auto-select logic if desired, or leave null
      if (availableBranches.isNotEmpty) {
        // activeBranch = availableBranches.first;
        // await setActiveBranch(activeBranch);
      }
    }
    notifyListeners();
  }

  Future<void> setActiveBranch(Branch? branch) async {
    activeBranch = branch;
    final prefs = await SharedPreferences.getInstance();
    if (branch != null) {
      await prefs.setInt('active_branch_id', branch.id!);
    } else {
      await prefs.remove('active_branch_id');
    }
    notifyListeners();
  }

  Future<void> addBranch(String name) async {
    final branch = Branch(
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    try {
      await DatabaseHelper.instance.addBranch(branch);
      await refreshBranches();
      // Auto-select if first branch?
      if (activeBranch == null && availableBranches.isNotEmpty) {
        await setActiveBranch(availableBranches.last);
      }
    } catch (e) {
      debugPrint('Error adding branch: $e');
    }
  }

  double get cartTotal {
    double total = 0;
    for (var item in cart) {
      total += item.totalLinePrice;
    }
    return total;
  }

  double get taxPercentage =>
      double.tryParse(restaurantSettings['tax'] ?? '0') ?? 0.0;

  double get taxAmount {
    return discountedTotal * (taxPercentage / 100);
  }

  double get totalWithTax {
    return discountedTotal + taxAmount;
  }

  double get discountedTotal {
    double total = cartTotal;
    for (var discount in activeDiscounts) {
      // Check date validity
      try {
        if (discount.startDate.isNotEmpty && discount.endDate.isNotEmpty) {
          final start = DateTime.parse(discount.startDate);
          final end = DateTime.parse(discount.endDate);
          final now = DateTime.now();
          if (now.isBefore(start) || now.isAfter(end)) continue;
        }
      } catch (e) {
        /* ignore parse error */
      }

      if (discount.targetProductId != null) {
        // Product specific discount
        double prodTotal = 0;
        for (var item in cart) {
          if (item.product.id == discount.targetProductId) {
            prodTotal += item.totalLinePrice;
          }
        }
        if (prodTotal > 0) {
          if (discount.type == 'PERCENT') {
            total -= prodTotal * (discount.value / 100);
          } else {
            // Assume value is flat amount off total product line
            total -= discount.value;
          }
        }
      } else if (discount.targetCategoryId != null) {
        // Category specific discount
        double catTotal = 0;
        for (var item in cart) {
          if (item.product.categoryId == discount.targetCategoryId) {
            catTotal += item.totalLinePrice;
          }
        }
        if (catTotal > 0) {
          if (discount.type == 'PERCENT') {
            total -= catTotal * (discount.value / 100);
          } else {
            total -= discount.value;
          }
        }
      } else {
        // Global discount
        if (discount.type == 'PERCENT') {
          total -= total * (discount.value / 100);
        } else {
          total -= discount.value;
        }
      }
    }
    return total < 0 ? 0 : total;
  }

  Future<Sale?> processCheckout(
    String paymentMethod,
    String orderType, {
    int? paymentDeviceId,
  }) async {
    if (cart.isEmpty || currentUser == null) return null;

    final db = DatabaseHelper.instance;

    // Get sequential invoice number from preferences
    final prefs = await SharedPreferences.getInstance();
    final counter = (prefs.getInt('invoice_counter') ?? 0) + 1;
    await prefs.setInt('invoice_counter', counter);
    final invoiceId = 'INV-${counter.toString().padLeft(5, '0')}';

    final total = totalWithTax;
    final tax = taxAmount;

    final saleId = await db.insert(
      'sales',
      Sale(
        invoiceId: invoiceId,
        totalAmount: total,
        taxAmount: tax,
        date: DateTime.now().toIso8601String(),
        paymentMethod: paymentMethod,
        orderType: orderType,
        userId: currentUser!.id!,
        customerId: selectedCustomer?.id, // Add customer ID if selected
        paymentDeviceId: paymentDeviceId, // Add payment device ID if selected
      ).toMap(),
    );

    for (var item in cart) {
      await db.insert(
        'sale_items',
        SaleItem(
          saleId: saleId,
          productId: item.product.id!,
          quantity: item.quantity,
          price: item.unitPrice,
          costPrice: item.product.costPrice,
          productName: item.product.name,
          size: item.size,
          addonsStr: item.addons.map((e) => e.name).join(", "),
        ).toMap(),
      );

      await db.rawUpdate('UPDATE products SET stock = stock - ? WHERE id = ?', [
        item.quantity,
        item.product.id,
      ]);

      // Deduct ingredients from stock based on product-ingredient mappings
      try {
        await DatabaseHelper.instance.deductIngredientsForSale(
          item.product.id!,
          item.quantity,
        );
      } catch (e) {
        debugPrint("FAILED to deduct ingredients for sale: $e");
        // We do NOT rethrow here because the sale is already recorded.
        // We explicitly want to allow the checkout to 'succeed' from a POS perspective
        // even if inventory sync fails, but we log it for debugging.
      }
    }

    final processedSale = Sale(
      id: saleId,
      invoiceId: invoiceId,
      totalAmount: total,
      taxAmount: tax,
      date: DateTime.now().toIso8601String(),
      paymentMethod: paymentMethod,
      orderType: orderType,
      userId: currentUser!.id!,
      customerId: selectedCustomer?.id, // Add customer ID if selected
      paymentDeviceId: paymentDeviceId, // Add payment device ID if selected
    );

    cart.clear();
    selectedCustomer = null; // Clear selected customer after checkout
    await refreshProducts();
    notifyListeners();
    return processedSale;
  }

  void setSelectedCustomer(Customer? customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    final db = DatabaseHelper.instance;
    await db.insert('customers', customer.toMap());
    notifyListeners();
  }

  Future<List<Customer>> getCustomers() async {
    return await DatabaseHelper.instance.getCustomers();
  }

  Future<void> updateRestaurantInfo(
    String name,
    String address,
    String phone,
    double tax,
  ) async {
    restaurantSettings = {
      'name': name,
      'address': address,
      'phone': phone,
      'tax': tax.toString(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('res_name', name);
    await prefs.setString('res_address', address);
    await prefs.setString('res_phone', phone);
    await prefs.setDouble('res_tax', tax);
    notifyListeners();
  }

  Future<void> seedTestData() async {
    if (!kDebugMode) return;
    final db = DatabaseHelper.instance;

    for (int i = 1; i <= 10; i++) {
      final categoryId = await db.insert('categories', {
        'name': 'فئة تجريبية $i',
        'iconCode': Icons.category.codePoint,
        'colorValue': Colors.blue.value,
      });

      for (int j = 1; j <= 5; j++) {
        await db.insert('products', {
          'name': 'منتج $j في فئة $i',
          'categoryId': categoryId,
          'costPrice': 10.0 * j,
          'sellPrice': 15.0 * j,
          'laborCost': 2.0,
          'stock': 100,
          'priceSmall': 15.0 * j,
          'iconCode': Icons.fastfood.codePoint,
          'colorValue': Colors.orange.value,
        });
      }
    }

    await refreshCategories();
    await refreshProducts();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;
  final String? size; // S, M, L
  final double unitPrice; // Price at time of add
  final List<Addon> addons;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.size,
    required this.unitPrice,
    this.addons = const [],
  });

  double get totalLinePrice {
    double addonTotal = addons.fold(0, (sum, item) => sum + item.price);
    return (unitPrice + addonTotal) * quantity;
  }
}

// --- Services ---

/// Helper for Arabic text support in ESC/POS printing
class ArabicPrinterHelper {
  /// Simple map for CP1256 encoding (Windows-1256)
  /// Only covers basic Arabic characters needed for receipts
  static final Map<int, int> _cp1256Map = {
    0x060C: 0xA1, // Arabic Comma
    0x061F: 0xBF, // Arabic Question Mark
    0x0621: 0xC1, // Hamza
    0x0622: 0xC2, // Alef with Madda
    0x0623: 0xC3, // Alef with Hamza Above
    0x0624: 0xC4, // Waw with Hamza Above
    0x0625: 0xC5, // Alef with Hamza Below
    0x0626: 0xC6, // Ya with Hamza Above
    0x0627: 0xC7, // Alef
    0x0628: 0xC8, // Ba
    0x0629: 0xC9, // Ta Marbuta
    0x062A: 0xCA, // Ta
    0x062B: 0xCB, // Tha
    0x062C: 0xCC, // Jeem
    0x062D: 0xCD, // Hah
    0x062E: 0xCE, // Khah
    0x062F: 0xCF, // Dal
    0x0630: 0xD0, // Thal
    0x0631: 0xD1, // Ra
    0x0632: 0xD2, // Zain
    0x0633: 0xD3, // Seen
    0x0634: 0xD4, // Sheen
    0x0635: 0xD5, // Sad
    0x0636: 0xD6, // Dad
    0x0637: 0xD7, // Tah
    0x0638: 0xD8, // Zah
    0x0639: 0xD9, // Ain
    0x063A: 0xDA, // Ghain
    0x0641: 0xE1, // Fa
    0x0642: 0xE2, // Qaf
    0x0643: 0xE3, // Kaf
    0x0644: 0xE4, // Lam
    0x0645: 0xE5, // Meem
    0x0646: 0xE6, // Noon
    0x0647: 0xE7, // Heh
    0x0648: 0xE8, // Waw
    0x0649: 0xE9, // Alef Maksura
    0x064A: 0xEA, // Ya
    0x064B: 0xEB, // Fathatan
    0x064C: 0xEC, // Dammatan
    0x064D: 0xED, // Kasratan
    0x064E: 0xEE, // Fatha
    0x064F: 0xEF, // Damma
    0x0650: 0xF0, // Kasra
    0x0651: 0xF1, // Shadda
    0x0652: 0xF2, // Sukun
  };

  /// Check if a string contains Arabic characters
  static bool containsArabic(String text) {
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (code >= 0x0600 && code <= 0x06FF) return true;
    }
    return false;
  }

  /// Reverse Arabic parts of a string while keeping non-Arabic in place
  /// This is a simplified Bidi approach
  static String fixRtl(String text) {
    if (!containsArabic(text)) return text;

    List<String> words = text.split(' ');
    List<String> fixedWords = [];

    for (var word in words) {
      if (containsArabic(word)) {
        fixedWords.add(word.split('').reversed.join(''));
      } else {
        fixedWords.add(word);
      }
    }

    // For full RTL, we reverse the order of words as well
    return fixedWords.reversed.join(' ');
  }

  /// Encode string to CP1256 bytes
  static List<int> encodeCP1256(String text) {
    List<int> bytes = [];
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (_cp1256Map.containsKey(code)) {
        bytes.add(_cp1256Map[code]!);
      } else if (code < 128) {
        bytes.add(code);
      } else {
        // Fallback or space for unknown chars
        bytes.add(0x20);
      }
    }
    return bytes;
  }
}

/// Service for printing images to ESC/POS thermal printers
class ImagePrintingService {
  /// Convert Flutter image bytes to ESC/POS raster format
  /// Convert Flutter image bytes to ESC/POS raster format with 80mm support
  static List<int> imageToRaster(Uint8List imageBytes, {int maxWidth = 576}) {
    // Default to 80mm (576 dots) for receipts, 58mm (384 dots) for kitchen
    final image = img.decodeImage(imageBytes);
    if (image == null) return [];

    // Use the actual image width if it's smaller than maxWidth (for kitchen tickets)
    final targetWidth = image.width < maxWidth ? image.width : maxWidth;
    final resized = img.copyResize(image, width: targetWidth);
    final grayscale = img.grayscale(resized);

    final bytes = <int>[];
    bytes.addAll([0x1B, 0x40]); // ESC @ Initialize
    bytes.addAll([0x1B, 0x33, 0x00]); // Line spacing 0

    final width = grayscale.width;
    final height = grayscale.height;

    for (int y = 0; y < height; y += 24) {
      bytes.addAll([0x1B, 0x2A, 33, width & 0xFF, (width >> 8) & 0xFF]);

      for (int x = 0; x < width; x++) {
        for (int k = 0; k < 3; k++) {
          int sliceByte = 0;
          for (int bit = 0; bit < 8; bit++) {
            int py = y + k * 8 + bit;
            if (py < height) {
              final pixel = grayscale.getPixel(x, py);
              if (img.getLuminance(pixel) < 128) {
                sliceByte |= (0x80 >> bit);
              }
            }
          }
          bytes.add(sliceByte);
        }
      }
      bytes.add(0x0A);
    }

    bytes.addAll([0x1B, 0x32]); // Reset line spacing
    bytes.addAll([0x1B, 0x64, 0x05]); // Feed 5 lines
    bytes.addAll([0x1D, 0x56, 0x00]); // Cut

    return bytes;
  }

  /// Capture a widget as an image
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  static Widget buildReceiptWidget({
    required Sale sale,
    required List<CartItem> items,
    required User cashier,
    required Map<String, String> settings,
    Customer? customer,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 570, // عرض الورقة 80 مم
        color: Colors.white,
        // نستخدم Column مباشرة بدلاً من SingleChildScrollView
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // مهم جداً: يجعل الطول يتمدد حسب المحتوى فقط
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ... (نفس محتوى الفاتورة السابق دون تغيير في النصوص) ...

                  // Restaurant Name
                  Text(
                    settings['name'] ?? 'المطعم',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  if (settings['address']?.isNotEmpty == true)
                    Text(
                      settings['address']!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Tajawal',
                        color: Colors.black,
                      ),
                    ),
                  if (settings['phone']?.isNotEmpty == true)
                    Text(
                      'هاتف: ${settings['phone']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontFamily: 'Tajawal',
                        color: Colors.black,
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.black, thickness: 2),

                  // Invoice Info
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الفاتورة: ${sale.invoiceId}',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'التاريخ: ${sale.date.substring(0, 16).replaceAll('T', ' ')}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'الكاشير: ${cashier.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'نوع الطلب: ${sale.orderType}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (customer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'العميل: ${customer.name}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Tajawal',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 2),

                  // Table Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'المنتج',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'الكمية',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'السعر',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black, thickness: 1),

                  // Items Loop
                  ...items.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isLast = entry.key == items.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item.product.name,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.totalLinePrice.toStringAsFixed(2),
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.size != null && item.size != 'Standard')
                                Text(
                                  '  الحجم: ${item.size}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Tajawal',
                                    color: Colors.black87,
                                  ),
                                ),
                              ...item.addons.map(
                                (addon) => Text(
                                  '  + ${addon.name}',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontFamily: 'Tajawal',
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Divider(color: Colors.black, thickness: 1),
                      ],
                    );
                  }),

                  const Divider(color: Colors.black, thickness: 2),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي:',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '\$${sale.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'الدفع: ${sale.paymentMethod}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 2),
                  const SizedBox(height: 8),
                  const Text(
                    'شكراً لزيارتكم!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  // إضافة مساحة بيضاء في الأسفل لضمان عدم القص عند القطع
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildKitchenTicketWidget({
    required String invoiceId,
    required String categoryName,
    required List<CartItem> items,
    required String printerName,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 570,
        color: Colors.white,
        // استخدام Column مباشرة
        child: Column(
          mainAxisSize: MainAxisSize.min, // التمدد حسب المحتوى
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '** المطبخ **',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 2),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الطلب: $invoiceId',
                          style: const TextStyle(
                            fontSize: 46,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'الوقت: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Tajawal',
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 2),

                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.quantity}x ${item.product.name}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                              color: Colors.black,
                            ),
                          ),
                          if (item.size != null && item.size != 'Standard')
                            Text(
                              '  >> ${item.size}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                                color: Colors.black87,
                              ),
                            ),
                          ...item.addons.map(
                            (addon) => Text(
                              '  + ${addon.name}',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const Divider(color: Colors.black, thickness: 2),
                        ],
                      ),
                    ),
                  ),

                  const Divider(color: Colors.black, thickness: 2),
                  const Text(
                    '** نهاية **',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50), // مسافة للقطع
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrintingService {
  // ESC/POS Commands
  static const List<int> _escInit = [0x1B, 0x40]; // Initialize printer
  static const List<int> _escCenter = [0x1B, 0x61, 0x01]; // Center align
  static const List<int> _escLeft = [0x1B, 0x61, 0x00]; // Left align
  static const List<int> _escBoldOn = [0x1B, 0x45, 0x01]; // Bold on
  static const List<int> _escBoldOff = [0x1B, 0x45, 0x00]; // Bold off
  static const List<int> _escDoubleOn = [
    0x1B,
    0x21,
    0x30,
  ]; // Double height & width
  static const List<int> _escDoubleOff = [0x1B, 0x21, 0x00]; // Normal size
  static const List<int> _escCut = [0x1D, 0x56, 0x00];
  static const List<int> _escFeed5 = [0x1B, 0x64, 0x05]; // Feed 5 lines
  static const List<int> _lineFeed = [0x0A]; // Line feed

  /// Get the main receipt printer from AppState
  static Printer? _getReceiptPrinter(AppState appState) {
    try {
      return appState.availablePrinters.firstWhere((p) => p.isReceipt);
    } catch (e) {
      // No receipt printer found
      return appState.availablePrinters.isNotEmpty
          ? appState.availablePrinters.first
          : null;
    }
  }

  /// Send raw bytes to network printer via TCP socket
  static Future<String?> _sendToPrinter(
    String ipAddress,
    int port,
    List<int> data,
  ) async {
    try {
      final socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(data);
      await socket.flush();
      await socket.close();
      return null;
    } catch (e) {
      debugPrint('Printer connection error: $e');
      if (e is SocketException) {
        return 'Connection failed: ${e.message} (OS Error: ${e.osError?.message})';
      }
      return 'Error: $e';
    }
  }

  /// Build receipt bytes for ESC/POS thermal printer
  static List<int> _buildReceiptBytes({
    required Sale sale,
    required List<CartItem> items,
    required User cashier,
    required Map<String, String> settings,
  }) {
    final bytes = <int>[];

    // Initialize printer
    // FS . (Cancel Chinese Mode if enabled) - Critical for solving the "Chinese characters" issue
    bytes.addAll([0x1C, 0x2E]);
    bytes.addAll([0x1C, 0x26]); // FS & - Select standard mode (Xprinter)
    bytes.addAll(_escInit);

    // Switch to Arabic Code Page (CP1256)
    // Try standard 22 (0x16). If this fails, 40 (0x28) is another common value for Xprinter.
    bytes.addAll([0x1B, 0x74, 0x16]);

    bytes.addAll(_escCenter);
    bytes.addAll(_escDoubleOn);
    bytes.addAll(_escBoldOn);

    bytes.addAll(_textToBytes(settings['name']?.toUpperCase() ?? 'RESTAURANT'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escDoubleOff);
    bytes.addAll(_escBoldOff);

    // Address and Phone
    if (settings['address']?.isNotEmpty == true) {
      bytes.addAll(_textToBytes(settings['address']!));
      bytes.addAll(_lineFeed);
    }
    if (settings['phone']?.isNotEmpty == true) {
      bytes.addAll(_textToBytes('الهاتف: ${settings['phone']}'));
      bytes.addAll(_lineFeed);
    }

    // Separator line
    bytes.addAll(_lineFeed);
    bytes.addAll(_textToBytes('================================'));
    bytes.addAll(_lineFeed);

    // Invoice info (Left aligned)
    bytes.addAll(_escLeft);
    bytes.addAll(_textToBytes('رقم الفاتورة: ${sale.invoiceId}'));
    bytes.addAll(_lineFeed);

    // Format date nicely
    String formattedDate;
    try {
      final dateTime = DateTime.parse(sale.date);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      formattedDate = sale.date.substring(0, 16).replaceAll('T', ' ');
    }
    bytes.addAll(_textToBytes('التاريخ: $formattedDate'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_textToBytes('الكاشير: ${cashier.name}'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_textToBytes('نوع الطلب: ${sale.orderType}'));
    bytes.addAll(_lineFeed);
    // Separator
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(_lineFeed);

    // Column headers
    bytes.addAll(_escBoldOn);
    bytes.addAll(_textToBytes(_formatLine('المنتج', 'الكمية', 'السعر')));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escBoldOff);
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(_lineFeed);

    // Items
    for (var item in items) {
      // Product name (truncate if needed)
      String name = item.product.name;
      if (name.length > 20) {
        name = '${name.substring(0, 17)}...';
      }

      final qty = item.quantity.toString();
      final total = item.totalLinePrice.toStringAsFixed(2);

      bytes.addAll(_textToBytes(_formatLine(name, qty, total)));
      bytes.addAll(_lineFeed);

      // Size if available
      if (item.size != null && item.size != 'Standard') {
        bytes.addAll(_textToBytes('  الحجم: ${item.size}'));
        bytes.addAll(_lineFeed);
      }

      // Addons if available
      for (var addon in item.addons) {
        bytes.addAll(
          _textToBytes('  + ${addon.name} (${addon.price.toStringAsFixed(2)})'),
        );
        bytes.addAll(_lineFeed);
      }
    }

    // Separator before totals
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(_lineFeed);

    // Subtotal, Tax, Total
    final subtotal = sale.totalAmount - sale.taxAmount;
    bytes.addAll(
      _textToBytes(_formatTotalLine('المجموع:', subtotal.toStringAsFixed(2))),
    );
    bytes.addAll(_lineFeed);

    // Calculate effective tax percentage for display
    double taxPercent = 0.0;
    if (subtotal > 0) {
      taxPercent = (sale.taxAmount / subtotal) * 100;
    }
    bytes.addAll(
      _textToBytes(
        _formatTotalLine(
          'الضريبة (${taxPercent.toStringAsFixed(1)}%):',
          sale.taxAmount.toStringAsFixed(2),
        ),
      ),
    );
    bytes.addAll(_lineFeed);

    // Separator
    bytes.addAll(_textToBytes('================================'));
    bytes.addAll(_lineFeed);

    // Total (Bold, Large)
    bytes.addAll(_escBoldOn);
    bytes.addAll(_escDoubleOn);
    bytes.addAll(
      _textToBytes(
        _formatTotalLine(
          'الاجمالي:',
          '\$${sale.totalAmount.toStringAsFixed(2)}',
        ),
      ),
    );
    bytes.addAll(_lineFeed);
    bytes.addAll(_escDoubleOff);
    bytes.addAll(_escBoldOff);

    // Payment method
    bytes.addAll(
      _textToBytes(_formatTotalLine('الدفع بواسطة:', sale.paymentMethod)),
    );
    bytes.addAll(_lineFeed);
    bytes.addAll(_textToBytes('================================'));
    bytes.addAll(_lineFeed);

    // Thank you message (Centered)
    bytes.addAll(_escCenter);
    bytes.addAll(_lineFeed);
    bytes.addAll(_escBoldOn);
    bytes.addAll(_textToBytes('شكراً!'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escBoldOff);
    bytes.addAll(_textToBytes('يرجى زيارتنا مرة أخرى'));
    bytes.addAll(_lineFeed);

    // Feed paper and cut
    bytes.addAll(_escFeed5);
    bytes.addAll(_escCut);

    return bytes;
  }

  /// Format a 3-column line for items (32 char width typical for 58mm paper)
  static String _formatLine(String item, String qty, String price) {
    const totalWidth = 32;
    const qtyWidth = 4;
    const priceWidth = 8;
    final itemWidth = totalWidth - qtyWidth - priceWidth;

    String itemStr = item.length > itemWidth
        ? item.substring(0, itemWidth)
        : item.padRight(itemWidth);
    String qtyStr = qty.padLeft(qtyWidth);
    String priceStr = price.padLeft(priceWidth);

    return '$itemStr$qtyStr$priceStr';
  }

  /// Format a 2-column line for totals
  static String _formatTotalLine(String label, String value) {
    const totalWidth = 32;
    final valueWidth = totalWidth - label.length;
    return '$label${value.padLeft(valueWidth)}';
  }

  /// Convert text to bytes (ASCII/CP1256 encoding for thermal printers)
  static List<int> _textToBytes(String text) {
    if (ArabicPrinterHelper.containsArabic(text)) {
      String fixed = ArabicPrinterHelper.fixRtl(text);
      return ArabicPrinterHelper.encodeCP1256(fixed);
    }
    // Standard Latin-1 for non-Arabic
    return text.codeUnits;
  }

  /// Print a test page to verify printer connection - NOW USES IMAGE
  static Future<String?> testPrint(
    BuildContext context,
    Printer printer,
  ) async {
    // Create a simple test widget
    final testWidget = Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 570, // 80mm Paper width
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'فحص الطابعة',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PRINTER TEST',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 3),
            const Text(
              'الاتصال ناجح!',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Tajawal',
                color: Colors.black,
              ),
            ),
            const Text(
              'Connection OK!',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'طابعة: ${printer.name}',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.black,
              ),
            ),
            Text(
              'IP: ${printer.ipAddress}:${printer.port}',
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              'التاريخ: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 2),
            const Text(
              'شكراً لاستخدامكم نظامنا',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

    // Convert widget to image bytes
    final imageBytes = await _widgetToImageBytes(testWidget);
    if (imageBytes == null) {
      debugPrint('Failed to capture test widget as image');
      return 'Failed to capture test widget as image';
    }

    // Convert image to raster bytes
    final rasterBytes = ImagePrintingService.imageToRaster(imageBytes);
    if (rasterBytes.isEmpty) {
      debugPrint('Failed to convert image to raster');
      return 'Failed to convert image to raster';
    }

    return await _sendToPrinter(printer.ipAddress, printer.port, rasterBytes);
  }

  /// Test kitchen printer specifically
  static Future<String?> testKitchenPrint(
    BuildContext context,
    Printer printer,
  ) async {
    debugPrint('🧪 اختبار طابعة المطبخ: ${printer.name}');

    // Create a kitchen test ticket
    final testWidget = ImagePrintingService.buildKitchenTicketWidget(
      invoiceId: 'TEST-${DateTime.now().millisecondsSinceEpoch}',
      categoryName: 'اختبار المطبخ',
      items: [
        CartItem(
          product: Product(
            id: 1,
            name: 'منتج تجريبي',
            categoryId: 1,
            costPrice: 5.0,
            sellPrice: 10.0,
            laborCost: 2.0,
          ),
          quantity: 2,
          unitPrice: 10.0,
          addons: [Addon(name: 'إضافة تجريبية', price: 1.5)],
        ),
      ],
      printerName: printer.name,
    );

    // Convert to image
    final imageBytes = await _widgetToImageBytes(testWidget);
    if (imageBytes == null) {
      debugPrint('❌ فشل في إنشاء صورة تذكرة الاختبار');
      return 'فشل في إنشاء صورة تذكرة الاختبار';
    }

    // Convert to raster and print
    final rasterBytes = ImagePrintingService.imageToRaster(
      imageBytes,
      maxWidth: 576,
    );
    if (rasterBytes.isEmpty) {
      debugPrint('❌ فشل في تحويل الصورة إلى بيانات طباعة');
      return 'فشل في تحويل الصورة إلى بيانات طباعة';
    }

    debugPrint('✅ تم إنشاء تذكرة الاختبار بنجاح (${rasterBytes.length} bytes)');
    return await _sendToPrinter(printer.ipAddress, printer.port, rasterBytes);
  }

  static Future<Uint8List?> _widgetToImageBytes(Widget widget) async {
    try {
      const double pixelRatio = 2.0;

      final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

      // 1. إعداد الـ ViewConfiguration المبدئي (مساحة غير محدودة)
      // التعديل هنا: استبدال size بـ logicalConstraints
      final ViewConfiguration initialConfig = ViewConfiguration(
        logicalConstraints: BoxConstraints.loose(
          const Size(double.infinity, double.infinity),
        ),
        devicePixelRatio: pixelRatio,
      );

      final RenderView renderView = RenderView(
        view: WidgetsBinding.instance.platformDispatcher.views.first,
        child: RenderPositionedBox(
          alignment: Alignment.topCenter,
          child: repaintBoundary,
        ),
        configuration: initialConfig,
      );

      final PipelineOwner pipelineOwner = PipelineOwner();
      final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      final RenderObjectToWidgetElement<RenderBox> rootElement =
          RenderObjectToWidgetAdapter<RenderBox>(
            container: repaintBoundary,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Material(color: Colors.white, child: widget),
            ),
          ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // الحصول على الحجم الفعلي للمحتوى
      final double contentHeight = repaintBoundary.size.height;
      final double contentWidth = 570.0; // عرض ثابت (80mm)

      // 2. تحديث الـ ViewConfiguration بالحجم الفعلي الجديد
      // التعديل هنا أيضاً: استخدام logicalConstraints بدلاً من size
      renderView.configuration = ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(
          Size(contentWidth, contentHeight),
        ),
        devicePixelRatio: pixelRatio,
      );

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: pixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating dynamic image: $e');
      return null;
    }
  }

  /// Print receipt to network printer - USES IMAGE FOR ARABIC SUPPORT
  static Future<void> printReceipt(
    BuildContext context,
    Sale sale,
    List<CartItem> items,
    User cashier,
    Map<String, String> settings,
  ) async {
    final appState = context.read<AppState>();
    final printer = _getReceiptPrinter(appState);

    if (printer == null) {
      debugPrint('No receipt printer configured - continuing without printing');
      // Allow working without printer - no warning shown to user
      return;
    }

    try {
      // Get customer if exists
      Customer? customer;
      if (sale.customerId != null) {
        final db = DatabaseHelper.instance;
        final customerRes = await db.query(
          'customers',
          where: 'id = ?',
          whereArgs: [sale.customerId],
        );
        if (customerRes.isNotEmpty) {
          customer = Customer.fromMap(customerRes.first);
        }
      }

      // Build receipt widget
      final receiptWidget = ImagePrintingService.buildReceiptWidget(
        sale: sale,
        items: items,
        cashier: cashier,
        settings: settings,
        customer: customer,
      );

      // Convert to image
      final imageBytes = await _widgetToImageBytes(receiptWidget);

      String? error;
      if (imageBytes != null) {
        // Convert to raster and print (receipt uses 80mm = 576 dots)
        final rasterBytes = ImagePrintingService.imageToRaster(
          imageBytes,
          maxWidth: 576,
        );
        if (rasterBytes.isNotEmpty) {
          error = await _sendToPrinter(
            printer.ipAddress,
            printer.port,
            rasterBytes,
          );
          if (error == null) {
            debugPrint('Receipt printed successfully to ${printer.name}');
          } else {
            debugPrint('Receipt print failed: $error');
          }
        } else {
          error = 'فشل في تحويل الصورة إلى بيانات الطباعة';
          debugPrint(error);
        }
      } else {
        debugPrint('Failed to convert receipt to image - falling back to text');
        // Fallback to text-based printing
        final receiptBytes = _buildReceiptBytes(
          sale: sale,
          items: items,
          cashier: cashier,
          settings: settings,
        );
        error = await _sendToPrinter(
          printer.ipAddress,
          printer.port,
          receiptBytes,
        );
        if (error == null) {
          debugPrint('Receipt (text) printed successfully to ${printer.name}');
        } else {
          debugPrint('Receipt (text) print failed: $error');
        }
      }

      // Show result to user
      if (context.mounted) {
        String message;
        if (error == null) {
          message = '✓ تم طباعة الفاتورة بنجاح';
        } else {
          // تحسين رسالة الخطأ لتكون أكثر وضوحاً
          String errorMsg = error;
          if (error.contains('Connection failed') ||
              error.contains('SocketException')) {
            errorMsg = 'فشل الاتصال بالطابعة. تحقق من العنوان والاتصال';
          } else if (error.contains('timeout')) {
            errorMsg = 'انتهت مهلة الاتصال. تحقق من الطابعة';
          } else {
            errorMsg =
                'خطأ في الطباعة: ${error.length > 50 ? "${error.substring(0, 50)}..." : error}';
          }
          message = '✗ $errorMsg';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: error == null ? Colors.green : Colors.red,
            duration: Duration(seconds: error == null ? 3 : 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in printReceipt: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ خطأ في طباعة الفاتورة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    // Show Preview - DISABLED per user request
    // await _showReceiptPreview(context, sale, items, cashier, settings, printer);
  }

  /// Build kitchen ticket bytes for a specific category's items
  static List<int> _buildKitchenTicketBytes({
    required String invoiceId,
    required String categoryName,
    required List<CartItem> items,
    required String printerName,
  }) {
    final bytes = <int>[];

    // Initialize printer with Chinese mode cancellation
    bytes.addAll([0x1C, 0x2E]); // FS . - Cancel Chinese mode
    bytes.addAll([0x1C, 0x26]); // FS & - Select standard mode
    bytes.addAll(_escInit);

    // Switch to Arabic Code Page
    bytes.addAll([0x1B, 0x74, 0x16]);

    // Header - KITCHEN ORDER (Large, Centered, Bold)
    bytes.addAll(_escCenter);
    bytes.addAll(_escDoubleOn);
    bytes.addAll(_escBoldOn);
    bytes.addAll(_textToBytes('** KITCHEN **'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escDoubleOff);
    bytes.addAll(_escBoldOff);

    // Category Name
    bytes.addAll(_escBoldOn);
    bytes.addAll(_textToBytes(categoryName.toUpperCase()));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escBoldOff);

    // Separator
    bytes.addAll(_textToBytes('================================'));
    bytes.addAll(_lineFeed);

    // Order Info (Left aligned)
    bytes.addAll(_escLeft);
    bytes.addAll(_textToBytes('Order: $invoiceId'));
    bytes.addAll(_lineFeed);
    bytes.addAll(
      _textToBytes('Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}'),
    );
    bytes.addAll(_lineFeed);
    bytes.addAll(_textToBytes('Printer: $printerName'));
    bytes.addAll(_lineFeed);

    // Separator
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(_lineFeed);

    // Items (Large font for kitchen visibility)
    bytes.addAll(_escDoubleOn);
    for (var item in items) {
      // Quantity x Product Name
      bytes.addAll(_textToBytes('${item.quantity}x ${item.product.name}'));
      bytes.addAll(_lineFeed);

      // Size if available
      if (item.size != null && item.size != 'Standard') {
        bytes.addAll(_escDoubleOff);
        bytes.addAll(_textToBytes('   >> ${item.size}'));
        bytes.addAll(_lineFeed);
        bytes.addAll(_escDoubleOn);
      }

      // Addons (important for kitchen)
      if (item.addons.isNotEmpty) {
        bytes.addAll(_escDoubleOff);
        for (var addon in item.addons) {
          bytes.addAll(_textToBytes('   + ${addon.name}'));
          bytes.addAll(_lineFeed);
        }
        bytes.addAll(_escDoubleOn);
      }
    }
    bytes.addAll(_escDoubleOff);

    // Footer
    bytes.addAll(_textToBytes('================================'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escCenter);
    bytes.addAll(_escBoldOn);
    bytes.addAll(_textToBytes('** END **'));
    bytes.addAll(_lineFeed);
    bytes.addAll(_escBoldOff);

    // Feed paper and cut
    bytes.addAll(_escFeed5);
    bytes.addAll(_escCut);

    return bytes;
  }

  /// Print kitchen tickets - distributes items to their category's printer - USES IMAGE FOR ARABIC
  static Future<Map<String, bool>> printKitchenTickets({
    required BuildContext context,
    required String invoiceId,
    required List<CartItem> items,
  }) async {
    final appState = context.read<AppState>();
    final results = <String, bool>{};
    // ============================================================
    // تعديل هام: انتظر 2 ثانية قبل البدء بطباعة المطبخ
    // هذا يسمح للطابعة بإغلاق الاتصال السابق والاستعداد للجديد
    await Future.delayed(const Duration(seconds: 2));
    // ============================================================
    debugPrint('=== بدء طباعة تذاكر المطبخ ===');
    debugPrint('رقم الفاتورة: $invoiceId');
    debugPrint('عدد العناصر: ${items.length}');
    debugPrint('الطابعات المتاحة: ${appState.availablePrinters.length}');

    // Group items by category
    final Map<int?, List<CartItem>> itemsByCategory = {};
    for (var item in items) {
      final catId = item.product.categoryId;
      itemsByCategory.putIfAbsent(catId, () => []).add(item);
      debugPrint('منتج: ${item.product.name} - فئة: $catId');
    }

    debugPrint('عدد الفئات: ${itemsByCategory.length}');

    // Get category info and printer assignments
    for (var entry in itemsByCategory.entries) {
      final categoryId = entry.key;
      final categoryItems = entry.value;

      if (categoryId == null) {
        debugPrint('تحذير: عنصر بدون فئة، تم التجاهل');
        continue;
      }

      // Find the category
      final category = appState.categories
          .where((c) => c.id == categoryId)
          .firstOrNull;
      if (category == null) {
        debugPrint('تحذير: فئة غير موجودة ID: $categoryId');
        continue;
      }

      debugPrint('معالجة فئة: ${category.name} (ID: ${category.id})');
      debugPrint('طابعة الفئة ID: ${category.printerId}');

      // Find the printer for this category
      Printer? printer;
      if (category.printerId != null) {
        printer = appState.availablePrinters
            .where((p) => p.id == category.printerId)
            .firstOrNull;
        debugPrint(
          'طابعة موجودة: ${printer?.name ?? "غير موجودة"} (${printer?.ipAddress ?? "N/A"})',
        );
      }

      // Skip if no printer assigned
      if (printer == null) {
        debugPrint(
          '❌ لا توجد طابعة مطبخ مخصصة للفئة: ${category.name} - continuing without printing',
        );
        results[category.name] = false;
        // Allow working without printer - no warning shown to user
        continue;
      }

      // Skip if this is a receipt-only printer
      if (printer.isReceipt) {
        debugPrint('تجاهل طابعة الفواتير فقط: ${printer.name}');
        continue;
      }

      try {
        // Build kitchen ticket widget
        final ticketWidget = ImagePrintingService.buildKitchenTicketWidget(
          invoiceId: invoiceId,
          categoryName: category.name,
          items: categoryItems,
          printerName: printer.name,
        );

        // Convert to image
        final imageBytes = await _widgetToImageBytes(ticketWidget);

        bool success = false;
        String? error;
        debugPrint('🖨️ محاولة طباعة تذكرة المطبخ للفئة: ${category.name}');
        debugPrint(
          'الطابعة: ${printer.name} (${printer.ipAddress}:${printer.port})',
        );

        if (imageBytes != null) {
          debugPrint('✅ تم إنشاء صورة التذكرة بنجاح');
          // Convert to raster and print (kitchen uses 80mm = 576 dots)
          final rasterBytes = ImagePrintingService.imageToRaster(
            imageBytes,
            maxWidth: 576,
          );
          if (rasterBytes.isNotEmpty) {
            debugPrint(
              '✅ تم تحويل الصورة إلى بيانات طباعة (${rasterBytes.length} bytes)',
            );
            error = await _sendToPrinter(
              printer.ipAddress,
              printer.port,
              rasterBytes,
            );
            if (error == null) {
              debugPrint(
                '✅ تم طباعة تذكرة المطبخ بنجاح إلى ${printer.name} للفئة ${category.name}',
              );
              success = true;
            } else {
              debugPrint(
                '❌ خطأ في طباعة المطبخ للفئة ${category.name}: $error',
              );
              // Show detailed error to user
              if (context.mounted) {
                String errorMsg = error;
                if (error.contains('Connection refused') ||
                    error.contains('Connection failed')) {
                  errorMsg =
                      'فشل الاتصال بطابعة المطبخ: ${printer.name}\nالعنوان: ${printer.ipAddress}:${printer.port}\nتأكد من:\n• تشغيل الطابعة\n• الاتصال بالشبكة\n• صحة عنوان IP';
                } else if (error.contains('timeout')) {
                  errorMsg =
                      'انتهت مهلة الاتصال بطابعة المطبخ: ${printer.name}';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ $errorMsg'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'إعادة المحاولة',
                      textColor: Colors.white,
                      onPressed: () {
                        // Retry printing this specific ticket
                        _sendToPrinter(
                          printer!.ipAddress,
                          printer.port,
                          rasterBytes,
                        );
                      },
                    ),
                  ),
                );
              }
            }
          } else {
            error = 'فشل في تحويل الصورة إلى بيانات الطباعة';
            debugPrint('❌ خطأ في تحويل الصورة للفئة ${category.name}: $error');
          }
        } else {
          // Fallback to text-based printing
          debugPrint(
            '⚠️ فشل إنشاء الصورة، التبديل إلى الطباعة النصية للفئة: ${category.name}',
          );
          final ticketBytes = _buildKitchenTicketBytes(
            invoiceId: invoiceId,
            categoryName: category.name,
            items: categoryItems,
            printerName: printer.name,
          );
          error = await _sendToPrinter(
            printer.ipAddress,
            printer.port,
            ticketBytes,
          );
          if (error == null) {
            debugPrint(
              '✅ تم طباعة تذكرة المطبخ (نص) بنجاح إلى ${printer.name} للفئة ${category.name}',
            );
            success = true;
          } else {
            debugPrint(
              '❌ خطأ في الطباعة النصية للفئة ${category.name}: $error',
            );
          }
        }

        results[category.name] = success;
        // ==========================================
        // التعديل هنا: انتظر ثانية بين كل تذكرة مطبخ وأخرى
        // لمنع تداخل المهام على نفس الطابعة
        await Future.delayed(const Duration(seconds: 1));
        // ==========================================
      } catch (e) {
        debugPrint('Exception in printKitchenTickets for ${category.name}: $e');
        results[category.name] = false;
      }
    }

    debugPrint('=== نتائج طباعة المطبخ: $results ===');
    return results;
  }

  /// Print all (receipt + kitchen tickets)
  static Future<void> printAll({
    required BuildContext context,
    required Sale sale,
    required List<CartItem> items,
    required User cashier,
    required Map<String, String> settings,
  }) async {
    try {
      // Print receipt first
      await printReceipt(context, sale, items, cashier, settings);

      // Wait a bit to ensure receipt printing completes
      await Future.delayed(const Duration(milliseconds: 500));

      // Then print kitchen tickets
      final kitchenResults = await printKitchenTickets(
        context: context,
        invoiceId: sale.invoiceId,
        items: items,
      );

      // Show kitchen print summary
      if (context.mounted && kitchenResults.isNotEmpty) {
        final successCount = kitchenResults.values.where((v) => v).length;
        final totalCount = kitchenResults.length;
        final failedCategories = kitchenResults.entries
            .where((e) => !e.value)
            .map((e) => e.key)
            .toList();

        String message;
        if (successCount == totalCount) {
          message =
              '✓ تم طباعة جميع تذاكر المطبخ بنجاح ($successCount/$totalCount)';
        } else if (successCount > 0) {
          message = '⚠️ تم طباعة $successCount من $totalCount تذاكر المطبخ';
          if (failedCategories.isNotEmpty) {
            message += '\nفشل: ${failedCategories.join(", ")}';
          }
        } else {
          message = '✗ فشل في طباعة جميع تذاكر المطبخ';
          if (failedCategories.isNotEmpty) {
            message += '\nالفئات: ${failedCategories.join(", ")}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: successCount == totalCount
                ? Colors.green
                : successCount > 0
                ? Colors.orange
                : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (context.mounted && kitchenResults.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ لا توجد فئات مرتبطة بطابعات للطباعة'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in printAll: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ خطأ في عملية الطباعة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// --- Screens ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";
  bool _isLoggingIn = false;
  String? _dbStatus;

  @override
  void initState() {
    super.initState();
    _checkDbStatus();
  }

  Future<void> _checkDbStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isPostgres = prefs.getBool('use_postgres') ?? false;
    setState(() {
      _dbStatus = isPostgres ? "PostgreSQL" : "SQLite (Local)";
    });
  }

  void _onDigitPress(String digit) {
    if (_pin.length < 4 && !_isLoggingIn) {
      setState(() => _pin += digit);
      if (_pin.length == 4) {
        _submit();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isLoggingIn) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _submit() async {
    setState(() => _isLoggingIn = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // UX delay
      if (!mounted) return;
      await context.read<AppState>().login(_pin);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.loginFailed}: ${e.toString()}'),
          ),
        );
      }
      setState(() {
        _pin = "";
        _isLoggingIn = false;
      });
    }
  }

  // ... build method ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // نبدأ بـ Row مباشرة ليأخذ كامل عرض وطول الشاشة
      body: Row(
        children: [
          // -----------------------------------------------------------
          // القسم الأول: الصورة (يسار الشاشة)
          // -----------------------------------------------------------
          Expanded(
            flex: 1, // يأخذ 50% من الشاشة
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              // طبقة تعتيم لجعل النصوص مقروءة (اختياري)
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.l10n.appName, // Using App Name or Welcome
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_dbStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Chip(
                          label: Text(_dbStatus!),

                          labelStyle: const TextStyle(
                            color: Colors.white,
                            backgroundColor: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // -----------------------------------------------------------
          // القسم الثاني: لوحة الأرقام (يمين الشاشة)
          // -----------------------------------------------------------
          Expanded(
            flex: 1, // يأخذ 50% من الشاشة
            child: SafeArea(
              // SafeArea تضمن عدم تغطية النوتش أو شريط الحالة
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // نستخدم Spacer لتوزيع المساحات بمرونة بدلاً من SizedBox الثابت
                    const Spacer(flex: 2),

                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 60,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.login,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      context.l10n.enterPin,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    const Spacer(flex: 1), // مسافة مرنة
                    // مؤشر النقاط (PIN Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < _pin.length
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 1), // مسافة مرنة
                    // لوحة الأرقام
                    // نضعها داخل ConstrainedBox لضمان عدم تمددها بشكل مبالغ فيه على الشاشات الكبيرة جداً
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio:
                            1.5, // اجعل الأزرار أعرض قليلاً لتقليل الطول العمودي
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 20,
                        children: [
                          for (var i = 1; i <= 9; i++)
                            _buildPinBtn(i.toString()),
                          IconButton(
                            onPressed: _onBackspace,
                            icon: const Icon(
                              Icons.backspace_rounded,
                              color: Colors.redAccent,
                            ),
                            iconSize: 32,
                          ),
                          _buildPinBtn("0"),
                          IconButton(
                            onPressed: _submit,
                            icon: const Icon(
                              Icons.arrow_circle_right_rounded,
                              color: Colors.green,
                            ),
                            iconSize: 56,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2), // مسافة في الأسفل
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تحسين تصميم الزر ليكون دائرياً وعصرياً
  Widget _buildPinBtn(String label) {
    return InkWell(
      onTap: () => _onDigitPress(label),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// شاشة الوصول المحظور
class _AccessDeniedScreen extends StatelessWidget {
  const _AccessDeniedScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text(
            'الوصول محظور',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'عذراً، ليس لديك صلاحية للوصول إلى هذه الصفحة',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'هذه الصفحة متاحة للمدير فقط',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 6;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAdmin = appState.currentUser?.role == 'admin';

    // الشاشات حسب الصلاحية
    final List<Widget> _screens = [
      if (isAdmin) const ProductsScreen() else const _AccessDeniedScreen(),
      if (isAdmin) const InventoryScreen() else const _AccessDeniedScreen(),
      if (isAdmin) const ExpensesScreen() else const _AccessDeniedScreen(),
      if (isAdmin) const DiscountsScreen() else const _AccessDeniedScreen(),
      if (isAdmin) const ReportsScreen() else const _AccessDeniedScreen(),
      if (isAdmin) const SettingsScreen() else const _AccessDeniedScreen(),
      const PosScreen(), // متاح للجميع
    ];

    // ألوان عصرية ومتناسقة
    const Color railBackgroundColor = Color(0xFF1E293B);
    const Color activeColor = Color(0xFF3B82F6);
    const Color inactiveColor = Colors.white60;

    // تعريف نمط الخط الموحد
    const TextStyle labelStyle = TextStyle(
      fontFamily: 'Tajawal', // الخط المطلوب
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // --- بداية الشريط الجانبي المخصص ---
            Container(
              color: railBackgroundColor,
              child: Column(
                children: [
                  // القسم العلوي: العناصر الأساسية (تأخذ المساحة المتاحة)
                  if (isAdmin)
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex > 5
                            ? null
                            : _selectedIndex, // إخفاء التحديد إذا كان العنصر سفلياً
                        backgroundColor: Colors
                            .transparent, // الخلفية تأتي من الـ Container الأب
                        indicatorColor: activeColor,
                        labelType: NavigationRailLabelType.all,

                        // تنسيق الأيقونات
                        selectedIconTheme: const IconThemeData(
                          color: Colors.white,
                          size: 26,
                        ),
                        unselectedIconTheme: const IconThemeData(
                          color: inactiveColor,
                          size: 24,
                        ),

                        // تنسيق النصوص (أبيض + تجوال)
                        selectedLabelTextStyle: labelStyle.copyWith(
                          color: Colors.white,
                        ),
                        unselectedLabelTextStyle: labelStyle.copyWith(
                          color: inactiveColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
                        ),

                        onDestinationSelected: (int index) {
                          setState(() => _selectedIndex = index);
                        },

                        // العناصر العلوية فقط (ترتيب المؤشرات: 0, 1, 2, 3, 4)
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.inventory_2_outlined),
                            selectedIcon: const Icon(Icons.inventory_2),
                            label: Text(context.l10n.products),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.warehouse_outlined),
                            selectedIcon: const Icon(Icons.warehouse),
                            label: Text(context.l10n.inventory),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.money_off_outlined),
                            selectedIcon: const Icon(Icons.money_off),
                            label: Text(context.l10n.expenses),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.local_offer_outlined),
                            selectedIcon: const Icon(Icons.local_offer),
                            label: Text(context.l10n.discounts),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.bar_chart_outlined),
                            selectedIcon: const Icon(Icons.bar_chart),
                            label: Text(context.l10n.reports),
                          ),

                          NavigationRailDestination(
                            icon: const Icon(Icons.settings_outlined),
                            selectedIcon: const Icon(Icons.settings),
                            label: Text(context.l10n.settings),
                          ),
                        ],
                      ),
                    )
                  else
                    // للكاشير: عرض رسالة بدلاً من القائمة
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 48,
                                color: inactiveColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'كاشير',
                                style: labelStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.currentUser?.name ?? '',
                                style: labelStyle.copyWith(
                                  color: inactiveColor,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // القسم السفلي: الإعدادات، الوردية، الخروج
                  // تم إنشاؤها يدوياً لتشبه NavigationRail ولكن تكون ثابتة في الأسفل
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        // زر نقطة البيع (يعامل كصفحة برقم إندكس 5)
                        _buildBottomRailItem(
                          icon: Icons.point_of_sale_outlined,
                          activeIcon: Icons.point_of_sale,
                          label: context.l10n.pos,
                          isSelected: _selectedIndex == 6,
                          onTap: () => setState(() => _selectedIndex = 6),
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                        ),

                        const SizedBox(height: 10),

                        // زر الوردية (حوار Dialog)
                        _buildBottomRailItem(
                          icon: Icons.access_time,
                          label: context.l10n.shift,
                          isSelected: false,
                          onTap: () => _showShiftDialog(context),
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                        ),

                        const SizedBox(height: 10),

                        // زر الخروج (Action)
                        _buildBottomRailItem(
                          icon: Icons.logout,
                          label: context.l10n.logout,
                          isSelected: false,
                          onTap: () => context.read<AppState>().logout(),
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- نهاية الشريط الجانبي ---
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: Color(0xFFE2E8F0),
            ),

            // محتوى الشاشة
            Expanded(
              child: Container(
                color: Colors.white,
                // ملاحظة: تأكد أن قائمة _screens مرتبة كالتالي:
                // [المنتجات, العروض, التقارير, نقطة البيع, الإعدادات]
                child: _screens[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء الأزرار السفلية بنفس تصميم الـ NavigationRail
  Widget _buildBottomRailItem({
    required IconData icon,
    IconData? activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50, // عرض تقريبي لمساحة الأيقونة
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? (activeIcon ?? icon) : icon,
              color: isSelected ? Colors.white : inactiveColor,
              size: isSelected ? 26 : 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: isSelected ? Colors.white : inactiveColor,
              fontSize: isSelected ? 12 : 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showShiftDialog(BuildContext context) {
    final state = context.read<AppState>();
    if (state.currentShift == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.shiftClosed)));
      return;
    }
    final cashCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.manageShift),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.l10n.from}: ${state.currentShift!.startTime.substring(0, 16).replaceAll("T", " ")}",
            ),
            Text(
              "${context.l10n.startCash}: \$${state.currentShift!.startCash}",
            ),
            const Divider(),
            Text("${context.l10n.closeShift}:"),
            TextField(
              controller: cashCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.endCash,
                prefixText: "\$",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final amount = double.tryParse(cashCtrl.text);
              if (amount != null) {
                try {
                  await state.closeShift(amount);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.shiftClosedSuccess)),
                    );
                  }
                } catch (e) {
                  debugPrint("Error closing shift: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${context.l10n.error}: $e")),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.invalidPin),
                  ), // Reusing generic error logic or add invalid_amount
                );
              }
            },
            child: Text(context.l10n.closeShift),
          ),
        ],
      ),
    );
  }
}

// --- Screens Logic ---

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.products), // Using "Products" as title
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.products),
              Tab(text: context.l10n.categories),
            ],
          ),
        ),
        body: const TabBarView(children: [_ProductList(), _CategoryList()]),
      ),
    );
  }
}

class _ProductList extends StatefulWidget {
  const _ProductList();

  @override
  State<_ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<_ProductList> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();

    // Filter products based on selected category
    final filteredProducts = _selectedCategoryId == null
        ? state.products
        : state.products
              .where((p) => p.categoryId == _selectedCategoryId)
              .toList();

    // Determine grid columns based on width
    final double width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 6;
    } else if (width > 900) {
      crossAxisCount = 5;
    } else if (width > 600) {
      crossAxisCount = 4;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        label: Text(context.l10n.addProduct),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Category Filter Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(context.l10n.all),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                  ),
                ),
                ...state.categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          // Products Grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: Text(context.l10n.noProducts))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProductDialog(context, product: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.blueGrey.shade50,
                child:
                    product.imagePath != null &&
                        product.imagePath!.isNotEmpty &&
                        File(product.imagePath!).existsSync()
                    ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          IconData(
                            product.iconCode ?? Icons.fastfood.codePoint,
                            fontFamily: 'MaterialIcons',
                          ),
                          size: 32,
                          color: Color(
                            product.colorValue ?? Colors.blueGrey.value,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "\$${product.sellPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final state = context.read<AppState>();
    final defaultCat = state.categories.isNotEmpty
        ? state.categories.first.id
        : null;

    showDialog(
      context: context,
      builder: (_) =>
          _ProductDialog(product: product, initialCategoryId: defaultCat),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;
  final int? initialCategoryId;
  const _ProductDialog({this.product, this.initialCategoryId});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _priceSmallCtrl;
  late TextEditingController _priceMediumCtrl;
  late TextEditingController _priceLargeCtrl;
  late TextEditingController _laborCtrl;
  // Stock controller removed
  int? _selectedCategoryId;
  List<Addon> _addons = [];
  List<ProductIngredient> _productIngredients = []; // Product ingredients list
  bool _isNew = true;
  String? _imagePath;
  int? _iconCode;
  int? _colorValue;

  @override
  void initState() {
    super.initState();
    _isNew = widget.product == null;
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _costCtrl = TextEditingController(
      text: widget.product?.costPrice.toString() ?? '0.0',
    );
    final defaultPrice = widget.product?.sellPrice ?? 0.0;
    _priceSmallCtrl = TextEditingController(
      text: widget.product?.priceSmall?.toString() ?? defaultPrice.toString(),
    );
    _priceMediumCtrl = TextEditingController(
      text: widget.product?.priceMedium?.toString() ?? '',
    );
    _priceLargeCtrl = TextEditingController(
      text: widget.product?.priceLarge?.toString() ?? '',
    );
    _laborCtrl = TextEditingController(
      text: widget.product?.laborCost.toString() ?? '0.0',
    );

    _imagePath = widget.product?.imagePath;
    _iconCode = widget.product?.iconCode;
    _colorValue = widget.product?.colorValue;
    _selectedCategoryId =
        widget.product?.categoryId ?? widget.initialCategoryId;

    _addons = List.from(widget.product?.availableAddons ?? []);
    _loadProductIngredients();
  }

  Future<void> _loadProductIngredients() async {
    if (widget.product?.id != null) {
      final ingredients = await DatabaseHelper.instance.getProductIngredients(
        widget.product!.id!,
      );
      setState(() {
        _productIngredients = ingredients;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppState>().categories;

    // Ensure _selectedCategoryId is either null or points to a valid category
    final bool categoryExists = categories.any(
      (c) => c.id == _selectedCategoryId,
    );
    if (!categoryExists && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product == null
                          ? context.l10n.addProduct
                          : context.l10n.editProduct,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- Name & Category ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.productName,
                                prefixIcon: const Icon(Icons.shopping_bag),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v!.trim().isEmpty
                                  ? context.l10n.fieldRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<int>(
                              value:
                                  categories.any(
                                    (c) => c.id == _selectedCategoryId,
                                  )
                                  ? _selectedCategoryId
                                  : (categories.isNotEmpty
                                        ? categories.first.id
                                        : null),
                              items: categories
                                  .fold<List<Category>>([], (list, cat) {
                                    if (!list.any((e) => e.id == cat.id)) {
                                      list.add(cat);
                                    }
                                    return list;
                                  })
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCategoryId = v),
                              decoration: InputDecoration(
                                labelText: context.l10n.category,
                                prefixIcon: const Icon(Icons.category),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v == null ? context.l10n.fieldRequired : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Cost & Labor (Stock removed) ---
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _costCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.cost,
                                prefixIcon: const Icon(
                                  Icons.account_balance_wallet,
                                ),
                                prefixText: "\$ ",
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) => double.tryParse(v ?? '') == null
                                  ? context.l10n.invalidValue
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _laborCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.laborCost,
                                prefixIcon: const Icon(Icons.handyman),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- Prices ---
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceSmallCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.priceSmall,
                                prefixIcon: const Icon(Icons.attach_money),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) => double.tryParse(v ?? '') == null
                                  ? context.l10n.invalidValue
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceMediumCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.priceMedium,
                                prefixIcon: const Icon(Icons.attach_money),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceLargeCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.priceLarge,
                                prefixIcon: const Icon(Icons.attach_money),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Image & Addons & Ingredients ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _imagePath == null
                                      ? const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(_imagePath!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.upload),
                                  label: Text(context.l10n.chooseImage),
                                  onPressed: () async {
                                    try {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                          );
                                      if (image != null) {
                                        setState(() => _imagePath = image.path);
                                      }
                                    } catch (e) {
                                      debugPrint("Error picking image: $e");
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("مسح التخصيص"),
                                  onPressed: () {
                                    setState(() {
                                      _imagePath = null;
                                      _iconCode = null;
                                      _colorValue = null;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Icon Picker
                                const Text(
                                  "الأيقونة",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildIconPicker(),
                                const SizedBox(height: 16),
                                // Color Picker
                                const Text(
                                  "اللون",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildColorPicker(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Collapsible Addons & Ingredients
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // Addons Collapsible
                                Card(
                                  elevation: 1,
                                  child: ExpansionTile(
                                    title: const Text(
                                      "الإضافات",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    initiallyExpanded:
                                        false, // Collapsed by default
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton.icon(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                label: const Text("إضافة"),
                                                onPressed: _showAddAddonDialog,
                                              ),
                                            ),
                                            if (_addons.isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Text(
                                                  "لا توجد إضافات حالياً.",
                                                ),
                                              )
                                            else
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: _addons.length,
                                                itemBuilder: (context, index) {
                                                  final addon = _addons[index];
                                                  return ListTile(
                                                    dense: true,
                                                    title: Text(addon.name),
                                                    subtitle: Text(
                                                      "\$${addon.price.toStringAsFixed(2)}",
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          _deleteAddon(addon),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Ingredients Collapsible
                                Card(
                                  elevation: 1,
                                  child: ExpansionTile(
                                    title: const Text(
                                      "المكونات",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    initiallyExpanded:
                                        false, // Collapsed by default
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton.icon(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                label: const Text("إضافة مكون"),
                                                onPressed:
                                                    _showAddIngredientDialog,
                                              ),
                                            ),
                                            if (_productIngredients.isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Text(
                                                  "لا توجد مكونات مرتبطة.",
                                                ),
                                              )
                                            else
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    _productIngredients.length,
                                                itemBuilder: (context, index) {
                                                  final pi =
                                                      _productIngredients[index];
                                                  return ListTile(
                                                    dense: true,
                                                    title: Text(
                                                      pi.ingredientName ??
                                                          'مكون #${pi.ingredientId}',
                                                    ),
                                                    subtitle: Text(
                                                      "الكمية: ${pi.quantity} ${pi.ingredientUnit ?? ''}",
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _productIngredients
                                                              .removeAt(index);
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer / Sticky Actions
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.product != null)
                    TextButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("تأكيد الحذف"),
                            content: const Text(
                              "هل أنت متأكد من حذف هذا المنتج؟",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("لا"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("نعم"),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await DatabaseHelper.instance.delete(
                              'products',
                              where: 'id = ?',
                              whereArgs: [widget.product!.id!],
                            );
                            if (mounted) {
                              context.read<AppState>().refreshProducts();
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            debugPrint("Error deleting product: $e");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("خطأ في حذف المنتج: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text(
                        "حذف",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("إلغاء"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("حفظ", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      try {
        final pSmall = double.tryParse(_priceSmallCtrl.text) ?? 0;
        final pMedium = double.tryParse(_priceMediumCtrl.text);
        final pLarge = double.tryParse(_priceLargeCtrl.text);

        final product = Product(
          id: widget.product?.id,
          name: _nameCtrl.text,
          categoryId: _selectedCategoryId!,
          costPrice: double.tryParse(_costCtrl.text) ?? 0,
          sellPrice: pSmall,
          laborCost: double.tryParse(_laborCtrl.text) ?? 0,
          stock: 0, // Stock field removed from UI, default to 0
          imagePath: _imagePath,
          priceSmall: pSmall,
          priceMedium: pMedium,
          priceLarge: pLarge,
          iconCode: _iconCode,
          colorValue: _colorValue,
        );

        int productId;
        if (widget.product == null) {
          productId = await DatabaseHelper.instance.insert(
            'products',
            product.toMap(),
          );
        } else {
          productId = widget.product!.id!;
          await DatabaseHelper.instance.update(
            'products',
            product.toMap(),
            where: 'id = ?',
            whereArgs: [productId],
          );
        }

        // حفظ الإضافات
        await _saveAddons(productId);

        // حفظ المكونات
        await _saveProductIngredients(productId);

        if (context.mounted) {
          context.read<AppState>().refreshProducts();
          Navigator.pop(context);
        }
      } catch (e, st) {
        debugPrint("Error saving product: $e\n$st");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("خطأ في حفظ المنتج: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveAddons(int productId) async {
    try {
      // حفظ الإضافات الجديدة
      for (final addon in _addons) {
        if (addon.id == null) {
          final newAddon = Addon(
            productId: productId,
            name: addon.name,
            price: addon.price,
            categoryId: null,
          );

          debugPrint('Inserting addon with map: ${newAddon.toMap()}');

          await DatabaseHelper.instance.insert('addons', newAddon.toMap());
        }
      }

      // حذف الإضافات التي تم إزالتها (إذا كان منتجاً موجوداً)
      if (widget.product != null) {
        final existingAddons = widget.product!.availableAddons;
        for (final existingAddon in existingAddons) {
          if (!_addons.any((a) => a.id == existingAddon.id)) {
            await DatabaseHelper.instance.delete(
              'addons',
              where: 'id = ?',
              whereArgs: [existingAddon.id!],
            );
          }
        }
      }
    } catch (e, st) {
      debugPrint("Error saving addons: $e\n$st");
      rethrow;
    }
  }

  Future<void> _showAddAddonDialog() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("إضافة إضافة جديدة"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "اسم الإضافة",
                prefixIcon: Icon(Icons.add_task),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: "سعر الإضافة",
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, true);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text("يرجى إدخال اسم الإضافة")),
                );
              }
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty && mounted) {
      final name = nameCtrl.text.trim();
      final price = double.tryParse(priceCtrl.text) ?? 0.0;

      // طباعة للتصحيح
      debugPrint('Creating addon: name=$name, price=$price, isNew=$_isNew');

      // إضافة مؤقتة
      final newAddon = Addon(
        id: null,
        productId: null,
        name: name,
        price: price,
        categoryId: null,
      );

      // طباعة الـ map لرؤية المفاتيح
      debugPrint('Addon toMap(): ${newAddon.toMap()}');
      debugPrint('Map keys: ${newAddon.toMap().keys.join(', ')}');

      setState(() {
        _addons.add(newAddon);
      });
    }
  }

  Future<void> _deleteAddon(Addon addon) async {
    // حذف من قاعدة البيانات إذا كان محفوظاً
    if (addon.id != null) {
      try {
        await DatabaseHelper.instance.delete(
          'addons',
          where: 'id = ?',
          whereArgs: [addon.id!],
        );
      } catch (e, st) {
        debugPrint("Error deleting addon: $e\n$st");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("خطأ في حذف الإضافة: $e")));
        }
        return;
      }
    }

    // حذف من القائمة
    if (mounted) {
      setState(() {
        _addons.removeWhere((a) => a.id == addon.id);
      });
    }
  }

  void _showAddIngredientDialog() {
    final appState = context.read<AppState>();
    Ingredient? selectedIngredient;
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة مكون للمنتج'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Ingredient>(
                  items: appState.ingredients
                      .where(
                        (i) => !_productIngredients.any(
                          (pi) => pi.ingredientId == i.id,
                        ),
                      )
                      .map(
                        (i) => DropdownMenuItem(value: i, child: Text(i.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedIngredient = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'المكون',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qtyController,
                  decoration: InputDecoration(
                    labelText: 'الكمية المطلوبة',
                    suffixText: selectedIngredient?.unit ?? '',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedIngredient != null) {
                final qty = double.tryParse(qtyController.text) ?? 1;
                setState(() {
                  _productIngredients.add(
                    ProductIngredient(
                      productId: widget.product?.id ?? 0,
                      ingredientId: selectedIngredient!.id!,
                      quantity: qty,
                      ingredientName: selectedIngredient!.name,
                      ingredientUnit: selectedIngredient!.unit,
                    ),
                  );
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconPicker() {
    final List<IconData> iconOptions = [
      Icons.fastfood,
      Icons.coffee,
      Icons.icecream,
      Icons.lunch_dining,
      Icons.local_pizza,
      Icons.cake,
      Icons.local_drink,
      Icons.restaurant,
      Icons.dining,
      Icons.bakery_dining,
      Icons.local_cafe,
      Icons.restaurant_menu,
      Icons.local_bar,
      Icons.star,
      Icons.favorite,
      Icons.celebration,
      Icons.set_meal,
      Icons.egg,
      Icons.cookie,
      Icons.ramen_dining,
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: iconOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final icon = iconOptions[index];
          final isSelected = _iconCode == icon.codePoint;
          return GestureDetector(
            onTap: () => setState(() => _iconCode = icon.codePoint),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.blueGrey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.blueGrey,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colorOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final color = colorOptions[index];
          final isSelected = _colorValue == color.value;
          return GestureDetector(
            onTap: () => setState(() => _colorValue = color.value),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveProductIngredients(int productId) async {
    try {
      // Create list with correct productId
      final ingredientsToSave = _productIngredients
          .map(
            (pi) => ProductIngredient(
              productId: productId,
              ingredientId: pi.ingredientId,
              quantity: pi.quantity,
            ),
          )
          .toList();

      await DatabaseHelper.instance.saveProductIngredients(
        productId,
        ingredientsToSave,
      );
    } catch (e) {
      debugPrint('Error saving product ingredients: $e');
      rethrow;
    }
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList();
  @override
  Widget build(BuildContext context) {
    var state = context.watch<AppState>();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        label: Text(context.l10n.addCategory),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final cat = state.categories[index];
          return ListTile(
            title: Text(cat.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showCategoryDialog(context, category: cat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCategory(context, cat),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteCategory),
        content: Text("${context.l10n.areYouSure} (${category.name})"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppState>().deleteCategory(category.id!);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final curCtrl = TextEditingController(text: category?.name ?? '');
    int? selectedPrinterId = category?.printerId;
    int? selectedIconCode = category?.iconCode;
    int? selectedColorValue = category?.colorValue;
    final printers = context.read<AppState>().availablePrinters;

    final List<IconData> iconOptions = [
      Icons.fastfood,
      Icons.coffee,
      Icons.icecream,
      Icons.lunch_dining,
      Icons.local_pizza,
      Icons.cake,
      Icons.local_drink,
      Icons.restaurant,
      Icons.dining,
      Icons.bakery_dining,
      Icons.local_cafe,
      Icons.restaurant_menu,
      Icons.local_bar,
      Icons.star,
      Icons.favorite,
    ];

    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.brown,
      Colors.blueGrey,
      Colors.cyan,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightGreen,
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            category == null
                ? context.l10n.addCategory
                : context.l10n.editCategory,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: curCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.categoryName,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedPrinterId,
                  decoration: InputDecoration(labelText: context.l10n.printers),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("None (Default)"),
                    ),
                    ...printers.map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedPrinterId = v),
                ),
                const SizedBox(height: 16),
                const Text(
                  "الأيقونة",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  width: 400,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: iconOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final icon = iconOptions[index];
                      final isSelected = selectedIconCode == icon.codePoint;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedIconCode = icon.codePoint),
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.blueGrey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "اللون",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  width: 400,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colorOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final color = colorOptions[index];
                      final isSelected = selectedColorValue == color.value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedColorValue = color.value),
                        child: Container(
                          width: 50,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (category != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text("Manage Shared Addons"),
                    onPressed: () =>
                        _showCategoryAddonsDialog(context, category),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (category != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDeleteCategory(context, category);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(context.l10n.delete),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (curCtrl.text.isNotEmpty) {
                  final newCat = Category(
                    id: category?.id,
                    name: curCtrl.text,
                    printerId: selectedPrinterId,
                    printerName: printers.any((p) => p.id == selectedPrinterId)
                        ? printers
                              .firstWhere((p) => p.id == selectedPrinterId)
                              .name
                        : null,
                    iconCode: selectedIconCode,
                    colorValue: selectedColorValue,
                  );

                  if (category == null) {
                    await DatabaseHelper.instance.insert(
                      'categories',
                      newCat.toMap(),
                    );
                  } else {
                    await DatabaseHelper.instance.update(
                      'categories',
                      newCat.toMap(),
                      where: 'id = ?',
                      whereArgs: [category.id!],
                    );
                  }
                  if (context.mounted) {
                    context.read<AppState>().refreshCategories();
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryAddonsDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Shared Addons: ${category.name}"),
            content: SizedBox(
              width: double.maxFinite,
              child: FutureBuilder<List<Addon>>(
                future: _getCategoryAddons(category.id!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final addons = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (addons.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("No shared addons."),
                        ),
                      ...addons.map(
                        (addon) => ListTile(
                          title: Text(addon.name),
                          subtitle: Text("\$${addon.price.toStringAsFixed(2)}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final db = DatabaseHelper.instance;
                              await db.delete(
                                'addons',
                                where: 'id = ?',
                                whereArgs: [addon.id],
                              );
                              setState(() {}); // Refresh
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add Shared Addon"),
                        onPressed: () => _showAddSharedAddonDialog(
                          context,
                          category,
                          () => setState(() {}),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<Addon>> _getCategoryAddons(int categoryId) async {
    final db = DatabaseHelper.instance;
    final res = await db.query(
      'addons',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return res.map((e) => Addon.fromMap(e)).toList();
  }

  void _showAddSharedAddonDialog(
    BuildContext context,
    Category category,
    VoidCallback onAdded,
  ) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("New Shared Addon"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name (e.g. Extra Cheese)",
              ),
            ),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                try {
                  final addon = Addon(
                    name: nameCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    categoryId: category.id,
                    productId: null,
                  );
                  final db = DatabaseHelper.instance;
                  await db.insert('addons', addon.toMap());
                  onAdded();
                  if (context.mounted && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  debugPrint("Shared Addon error: $e");
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  @override
  Widget build(BuildContext context) {
    final discounts = context.watch<AppState>().activeDiscounts;
    return Scaffold(
      appBar: AppBar(title: const Text("التخفيضات")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDiscountDialog(context),
        label: const Text("اضافة تخفيض جديد"),
        icon: const Icon(Icons.add),
      ),
      body: discounts.isEmpty
          ? const Center(child: Text("لا توجد تخفيضات"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discounts.length,
              itemBuilder: (c, i) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.local_offer, color: Colors.green),
                  ),
                  title: Text(discounts[i].name),
                  subtitle: Text(
                    "${discounts[i].type == 'PERCENT' ? '${discounts[i].value}%' : '\$${discounts[i].value}'} Off "
                    "${discounts[i].targetCategoryId != null
                        ? '(Category)'
                        : discounts[i].targetProductId != null
                        ? '(Product)'
                        : '(All)'}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.delete(
                        'discounts',
                        where: 'id = ?',
                        whereArgs: [discounts[i].id!],
                      );
                      if (context.mounted) {
                        context.read<AppState>().refreshDiscounts();
                      }
                    },
                  ),
                ),
              ),
            ),
    );
  }

  void _showAddDiscountDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String type = 'PERCENT'; // PERCENT or FIXED
    String scope = 'ALL'; // ALL, CATEGORY, PRODUCT
    int? selectedCatId;
    int? selectedProdId;

    final categories = context.read<AppState>().categories;
    final products = context.read<AppState>().products;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("اضافة تخفيض جديد"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "اسم التخفيض"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'PERCENT', child: Text("نسبة (%)")),
                    DropdownMenuItem(
                      value: 'FIXED',
                      child: Text("قيمة ثابتة (\$)"),
                    ),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  decoration: const InputDecoration(labelText: "Value"),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: scope,
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text("جميع الطلبات")),
                    DropdownMenuItem(
                      value: 'CATEGORY',
                      child: Text("فئة معينة"),
                    ),
                    DropdownMenuItem(
                      value: 'PRODUCT',
                      child: Text("منتج معين"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      scope = v!;
                      selectedCatId = null;
                      selectedProdId = null;
                    });
                  },
                  decoration: const InputDecoration(labelText: "تطبيق على"),
                ),
                if (scope == 'CATEGORY') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedCatId,
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedCatId = v),
                    decoration: const InputDecoration(
                      labelText: "Select Category",
                    ),
                  ),
                ],
                if (scope == 'PRODUCT') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedProdId,
                    items: products
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedProdId = v),
                    decoration: const InputDecoration(
                      labelText: "Select Product",
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && valueCtrl.text.isNotEmpty) {
                  final val = double.tryParse(valueCtrl.text) ?? 0;
                  final newDiscount = Discount(
                    name: nameCtrl.text,
                    type: type,
                    value: val,
                    startDate: DateTime.now().toIso8601String(),
                    endDate: DateTime.now()
                        .add(const Duration(days: 365))
                        .toIso8601String(),
                    targetCategoryId: selectedCatId,
                    targetProductId: selectedProdId,
                  );
                  await DatabaseHelper.instance.insert(
                    'discounts',
                    newDiscount.toMap(),
                  );
                  if (context.mounted) {
                    context.read<AppState>().refreshDiscounts();
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  int? _selectedCategoryId;
  final String _searchQuery = "";
  String _orderType = 'داخلي'; // Default order type
  String _cartTab = "Check";

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Filter Categories
    final categories = state.categories;

    // Filter Products
    List<Product> products = state.products;
    if (_selectedCategoryId != null) {
      products = products
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      products = products
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (state.currentShift == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                context.l10n.shiftClosed,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "افتح وردية لبدء البيع.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: Text(context.l10n.openShift),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _showOpenShiftDialog(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Light background
      body: Row(
        children: [
          // LEFT PANEL (65%): Menu & Catalog
          Expanded(
            flex: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        _selectedCategoryId != null
                            ? (categories.any(
                                    (c) => c.id == _selectedCategoryId,
                                  )
                                  ? categories
                                        .firstWhere(
                                          (c) => c.id == _selectedCategoryId,
                                        )
                                        .name
                                  : context.l10n.categories)
                            : context.l10n.categories,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories Grid (Scrollable)
                SizedBox(
                  height: 150, // Reduced height
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    scrollDirection: Axis.vertical,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.5, // Shorter cards
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategoryId == cat.id;
                      final Color cardColor = cat.colorValue != null
                          ? Color(cat.colorValue!)
                          : Colors.blue;

                      return InkWell(
                        onTap: () => setState(
                          () =>
                              _selectedCategoryId = isSelected ? null : cat.id,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                cat.iconCode != null
                                    ? IconData(
                                        cat.iconCode!,
                                        fontFamily: 'MaterialIcons',
                                      )
                                    : Icons.category,
                                color: Colors.white.withOpacity(0.8),
                                size: 18,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Products Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    context.l10n.products,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Products Grid
                Expanded(
                  child: products.isEmpty
                      ? Center(child: Text(context.l10n.noProducts))
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                childAspectRatio: 0.9, // Shorter cards
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              onTap: () =>
                                  _showProductDetails(context, product),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // RIGHT PANEL (35%): Cart & Checkout
          Expanded(
            flex: 35,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Cart Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.cart,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildTabChip(
                              "Check",
                              _cartTab == "Check",
                              () => setState(() => _cartTab = "Check"),
                            ),
                            const SizedBox(width: 12),
                            _buildTabChip(
                              "Actions",
                              _cartTab == "Actions",
                              () => setState(() => _cartTab = "Actions"),
                            ),
                            const SizedBox(width: 12),
                            _buildTabChip(
                              "Guest",
                              _cartTab == "Guest",
                              () => setState(() => _cartTab = "Guest"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Cart Content based on Tab
                  Expanded(child: _buildCartTabContent(state)),

                  // Cart Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          context.l10n.subtotal,
                          state.cartTotal,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(context.l10n.tax, state.taxAmount),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context.l10n.total,
                          state.totalWithTax,
                          isTotal: true,
                        ),
                        const SizedBox(height: 24),
                        // Pay Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: state.cart.isEmpty
                                ? null
                                : () => _showPaymentDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF007BFF,
                              ), // Vibrant blue
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              context.l10n.pay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartTabContent(AppState state) {
    if (_cartTab == "Actions") {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Order Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOrderTypeButton(
                  Icons.restaurant,
                  context.l10n.dineIn,
                  _orderType == "داخلي",
                  () => setState(() => _orderType = "داخلي"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOrderTypeButton(
                  Icons.shopping_bag,
                  context.l10n.takeaway,
                  _orderType == "خارجي",
                  () => setState(() => _orderType = "خارجي"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOrderTypeButton(
                  Icons.delivery_dining,
                  context.l10n.delivery,
                  _orderType == "توصيل",
                  () => setState(() => _orderType = "توصيل"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            context.l10n.quickActions,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.history,
            "History",
            () => _showOrdersDialog(context),
            Colors.grey.shade100,
            Colors.black87,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.pause_presentation,
            "Held Orders (${state.heldOrders.length})",
            () => _showSuspendedOrdersDialog(context),
            Colors.orange.shade50,
            Colors.orange.shade900,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            Icons.pause,
            "Hold Order",
            state.cart.isEmpty ? null : () => _holdOrder(context, state),
            Colors.orange.shade100,
            Colors.orange.shade900,
          ),
        ],
      );
    } else if (_cartTab == "Guest") {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 64,
                color: state.selectedCustomer != null
                    ? Colors.blue
                    : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                state.selectedCustomer != null
                    ? state.selectedCustomer!.name
                    : context.l10n.noCustomer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCustomerDialog(context),
                  icon: const Icon(Icons.person_search),
                  label: Text(context.l10n.selectCustomer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade900,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default "Check" Tab
    return state.cart.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.cartEmpty,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.cart.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = state.cart[index];
              return Slidable(
                key: ValueKey('cart_item_$index'),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => state.removeFromCart(index),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _showEditCartItemDialog(context, index, item),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${item.quantity}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.size != 'Standard')
                                Text(
                                  item.size ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          "\$${item.totalLinePrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback? onTap,
    Color bgColor,
    Color textColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildOrderTypeButton(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007BFF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrdersDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _OrdersDialog());
  }

  void _holdOrder(BuildContext context, AppState state) {
    state.suspendOrder(_orderType);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.orderHeld)));
  }

  void _showSuspendedOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Use Builder to get context with Provider if needed,
        // but watch<AppState> is usually at top of build.
        // Here we are in a new route (dialog), so we need check context again or use Consumer.
        final state = context.watch<AppState>();
        return AlertDialog(
          title: Text(context.l10n.heldOrders),
          content: SizedBox(
            width: 500,
            height: 400,
            child: state.heldOrders.isEmpty
                ? Center(child: Text(context.l10n.noHeldOrders))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.heldOrders.length,
                    itemBuilder: (context, index) {
                      final order = state.heldOrders[index];
                      final timeStr = DateFormat('h:mm a').format(order.date);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(
                            "طلب #${index + 1} - $timeStr",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${order.customer?.name ?? context.l10n.noCustomer} | ${context.l10n.total}: \$${order.total.toStringAsFixed(2)} | ${order.items.length} ${context.l10n.unit}",
                          ),
                          children: [
                            ...order.items.map(
                              (item) => ListTile(
                                dense: true,
                                title: Text(item.product.name),
                                trailing: Text("x${item.quantity}"),
                              ),
                            ),
                            ButtonBar(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  label: Text(context.l10n.delete),
                                  onPressed: () {
                                    state.deleteHeldOrder(order.id);
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.restore),
                                  label: Text(context.l10n.restore),
                                  onPressed: () {
                                    state.restoreHeldOrder(order);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.orderRestored,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        );
      },
    );
  }

  void _showCustomerDialog(BuildContext context) async {
    final appState = context.read<AppState>();
    final customers = await appState.getCustomers();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.selectCustomer),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add new customer button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showAddCustomerDialog(context);
                },
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addCustomer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Customers list
              Flexible(
                child: customers.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(context.l10n.noCustomers),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: customers.length + 1, // +1 for "بدون عميل"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "بدون عميل" option
                            return ListTile(
                              leading: const Icon(Icons.person_off),
                              title: Text(context.l10n.noCustomer),
                              onTap: () {
                                appState.setSelectedCustomer(null);
                                Navigator.pop(dialogContext);
                              },
                              selected: appState.selectedCustomer == null,
                            );
                          }
                          final customer = customers[index - 1];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                customer.name.isNotEmpty
                                    ? customer.name[0].toUpperCase()
                                    : '?',
                              ),
                            ),
                            title: Text(customer.name),
                            subtitle: customer.phone != null
                                ? Text(
                                    '${context.l10n.phone}: ${customer.phone}',
                                  )
                                : null,
                            onTap: () {
                              appState.setSelectedCustomer(customer);
                              Navigator.pop(dialogContext);
                            },
                            selected:
                                appState.selectedCustomer?.id == customer.id,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.addCustomer),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: '${context.l10n.customerName} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.phone,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.notes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                final customer = Customer(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty
                      ? null
                      : phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty
                      ? null
                      : emailCtrl.text.trim(),
                  notes: notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim(),
                );
                await context.read<AppState>().addCustomer(customer);
                // Select the newly added customer
                final customers = await context.read<AppState>().getCustomers();
                final newCustomer = customers.firstWhere(
                  (c) => c.name == customer.name,
                );
                context.read<AppState>().setSelectedCustomer(newCustomer);
                if (context.mounted && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ تم إضافة العميل واختياره'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⚠️ يرجى إدخال اسم العميل'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double val, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "${isNegative ? '-' : ''}\$${val.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 22 : 16,
            color: isNegative
                ? Colors.green
                : (isTotal ? const Color(0xFF007BFF) : Colors.black),
          ),
        ),
      ],
    );
  }

  void _showPaymentDialog(BuildContext context) async {
    // Get active payment devices
    final devices = await DatabaseHelper.instance.getPaymentDevices();
    final activeDevices = devices.where((d) => d.isActive).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.paymentMethod),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: Text(context.l10n.cash),
                onTap: () {
                  Navigator.pop(context);
                  _processCheckout(context, "نقدي");
                },
              ),
              if (activeDevices.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    context.l10n.paymentDevices,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...activeDevices.map(
                  (device) => ListTile(
                    leading: Icon(Icons.credit_card, color: Colors.blue),
                    title: Text(device.name),
                    subtitle: Text(device.type),
                    onTap: () {
                      Navigator.pop(context);
                      _processCheckout(
                        context,
                        "بطاقه",
                        paymentDeviceId: device.id,
                      );
                    },
                  ),
                ),
              ] else
                ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.blue),
                  title: Text(context.l10n.card),
                  onTap: () {
                    Navigator.pop(context);
                    _processCheckout(context, "بطاقه");
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _processCheckout(
    BuildContext context,
    String method, {
    int? paymentDeviceId,
  }) async {
    final itemsToPrint = List<CartItem>.from(context.read<AppState>().cart);
    final sale = await context.read<AppState>().processCheckout(
      method,
      _orderType,
      paymentDeviceId: paymentDeviceId,
    );

    // Send amount to payment device if selected
    if (paymentDeviceId != null) {
      await _sendAmountToPaymentDevice(
        context,
        sale?.totalAmount ?? 0.0,
        paymentDeviceId,
      );
    }

    if (mounted && sale != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.paymentComplete)));

      final appState = context.read<AppState>();

      // Print receipt first
      await PrintingService.printReceipt(
        context,
        sale,
        itemsToPrint,
        appState.currentUser!,
        appState.restaurantSettings,
      );
      // ==========================================
      // التعديل هنا: انتظر 3 ثوانٍ كاملة قبل طباعة المطبخ
      // لضمان إغلاق الاتصال السابق من نفس الطابعة
      await Future.delayed(const Duration(seconds: 2));
      // ==========================================
      // Print kitchen tickets separately to ensure they print
      final kitchenResults = await PrintingService.printKitchenTickets(
        context: context,
        invoiceId: sale.invoiceId,
        items: itemsToPrint,
      );

      // Show kitchen print results
      if (context.mounted && kitchenResults.isNotEmpty) {
        final successCount = kitchenResults.values.where((v) => v).length;
        final totalCount = kitchenResults.length;
        final failedCategories = kitchenResults.entries
            .where((e) => !e.value)
            .map((e) => e.key)
            .toList();

        String message;
        if (successCount == totalCount) {
          message =
              '✓ تم طباعة جميع تذاكر المطبخ بنجاح ($successCount/$totalCount)';
        } else if (successCount > 0) {
          message = '⚠️ تم طباعة $successCount من $totalCount تذاكر المطبخ';
          if (failedCategories.isNotEmpty) {
            message += '\nفشل: ${failedCategories.join(", ")}';
          }
        } else {
          message = '✗ فشل في طباعة جميع تذاكر المطبخ';
          if (failedCategories.isNotEmpty) {
            message += '\nالفئات: ${failedCategories.join(", ")}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: successCount == totalCount
                ? Colors.green
                : successCount > 0
                ? Colors.orange
                : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ لا توجد فئات مرتبطة بطابعات المطبخ'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showOpenShiftDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("فتح وردية جديدة"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: "القيمة الافتتاحية",
            prefixText: "\$",
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("الغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null) {
                context.read<AppState>().openShift(amount);
                Navigator.pop(context);
              }
            },
            child: const Text("فتح"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendAmountToPaymentDevice(
    BuildContext context,
    double amount,
    int deviceId,
  ) async {
    try {
      final devices = await DatabaseHelper.instance.getPaymentDevices();
      final device = devices.firstWhere((d) => d.id == deviceId);

      if (!device.isActive) {
        debugPrint('Payment device ${device.name} is not active');
        return;
      }

      debugPrint('إرسال المبلغ $amount إلى جهاز الدفع ${device.name}');

      if (device.connectionType == 'TCP' &&
          device.ipAddress != null &&
          device.port != null) {
        // Send amount via TCP
        final socket = await Socket.connect(device.ipAddress!, device.port!);
        // Format: AMOUNT:123.45\n
        final command = 'AMOUNT:${amount.toStringAsFixed(2)}\n';
        socket.add(command.codeUnits);
        await socket.flush();
        socket.destroy();
        debugPrint('✓ تم إرسال المبلغ إلى ${device.name}');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ تم إرسال المبلغ إلى ${device.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (device.connectionType == 'Serial' &&
          device.serialPort != null) {
        // For serial port, you would need a serial port package
        // This is a placeholder - implement based on your serial port library
        debugPrint('Serial port communication not yet implemented');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ الاتصال عبر Serial Port غير متاح حالياً'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('خطأ في إرسال المبلغ إلى جهاز الدفع: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ فشل إرسال المبلغ: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _ProductDetailsSheet(
          product: product,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showEditCartItemDialog(BuildContext context, int index, CartItem item) {
    int quantity = item.quantity;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item.product.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Size info
              if (item.size != null && item.size != 'Standard')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.straighten, size: 18),
                      const SizedBox(width: 8),
                      Text("الحجم: ${item.size}"),
                    ],
                  ),
                ),
              // Addons info
              if (item.addons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.addons.map((e) => e.name).join(", ")),
                      ),
                    ],
                  ),
                ),
              // Quantity editor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setDialogState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 32,
                    color: Colors.red,
                  ),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$quantity",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setDialogState(() => quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 32,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Total price
              Text(
                "الإجمالي: \$${((item.unitPrice + item.addons.fold(0.0, (sum, a) => sum + a.price)) * quantity).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                // Update quantity in cart using proper method
                dialogContext.read<AppState>().updateCartItemQuantity(
                  index,
                  quantity,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text("تحديث"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasImage = product.imagePath != null;
    final bool hasIcon = product.iconCode != null;
    final Color? cardBgColor = product.colorValue != null
        ? Color(product.colorValue!)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image or Placeholder
                if (hasImage)
                  Image.file(File(product.imagePath!), fit: BoxFit.cover)
                else
                  Container(
                    color:
                        cardBgColor?.withOpacity(0.2) ?? Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: hasIcon
                        ? Icon(
                            IconData(
                              product.iconCode!,
                              fontFamily: 'MaterialIcons',
                            ),
                            size: 40,
                            color: cardBgColor ?? Colors.blueGrey,
                          )
                        : Text(
                            product.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: cardBgColor ?? Colors.blueGrey,
                            ),
                          ),
                  ),

                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Text Content
                Padding(
                  padding: const EdgeInsets.all(8.0), // Reduced from 12
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "\$${product.sellPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends StatefulWidget {
  final Product product;
  final ScrollController scrollController;
  const _ProductDetailsSheet({
    required this.product,
    required this.scrollController,
  });

  @override
  State<_ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<_ProductDetailsSheet> {
  String _selectedSize = 'الرئيسي';
  final List<Addon> _selectedAddons = [];
  List<Addon> _availableAddons = [];
  int _quantity = 1;
  double _currentPrice = 0;

  @override
  void initState() {
    super.initState();
    // Use main sellPrice as the default price
    _selectedSize = 'الرئيسي';
    _currentPrice = widget.product.sellPrice;
    _loadAddons();
  }

  Future<void> _loadAddons() async {
    final db = DatabaseHelper.instance;
    // Current product addons
    final prodAddons = widget.product.availableAddons;

    // Category addons
    final List<Map<String, dynamic>> catRes = await db.query(
      'addons',
      where: 'categoryId = ?',
      whereArgs: [widget.product.categoryId],
    );
    final catAddons = catRes.map((e) => Addon.fromMap(e)).toList();

    if (mounted) {
      setState(() {
        _availableAddons = [...prodAddons, ...catAddons];
      });
    }
  }

  void _updatePrice() {
    double base = 0;

    // Match size names with consistent labels
    switch (_selectedSize) {
      case 'الرئيسي':
        base = widget.product.sellPrice;
        break;
      case 'صغير':
        base = widget.product.priceSmall ?? widget.product.sellPrice;
        break;
      case 'متوسط':
        base = widget.product.priceMedium ?? widget.product.sellPrice;
        break;
      case 'كبير':
        base = widget.product.priceLarge ?? widget.product.sellPrice;
        break;
      default:
        base = widget.product.sellPrice;
    }

    _currentPrice = base;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double addonTotal = _selectedAddons.fold(
      0,
      (sum, item) => sum + item.price,
    );
    double total = (_currentPrice + addonTotal) * _quantity;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                // Always show size options if product has multiple sizes OR sellPrice
                Text(
                  context.l10n.selectSize,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Always show main size with sellPrice
                    Expanded(
                      child: _buildSizeOption(
                        'الرئيسي',
                        widget.product.sellPrice,
                      ),
                    ),
                    if (widget.product.priceMedium != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizeOption(
                          'متوسط',
                          widget.product.priceMedium!,
                        ),
                      ),
                    ],
                    if (widget.product.priceLarge != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSizeOption(
                          'كبير',
                          widget.product.priceLarge!,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                if (_availableAddons.isNotEmpty) ...[
                  Text(
                    context.l10n.addons,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableAddons.map((addon) {
                      final isSelected = _selectedAddons.any(
                        (a) => a.id == addon.id,
                      );
                      return FilterChip(
                        label: Text("${addon.name} (+\$${addon.price})"),
                        selected: isSelected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedAddons.add(addon);
                            } else {
                              _selectedAddons.removeWhere(
                                (a) => a.id == addon.id,
                              );
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),

          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text(
                      "$_quantity",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AppState>().addToCart(
                        widget.product,
                        quantity: _quantity,
                        size: _selectedSize,
                        price: _currentPrice,
                        addons: _selectedAddons,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.addToOrder,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String label, double price) {
    final isSelected = _selectedSize == label;
    return InkWell(
      onTap: () {
        setState(() => _selectedSize = label);
        _updatePrice();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
            Text(
              "\$$price",
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersDialog extends StatefulWidget {
  const _OrdersDialog();
  @override
  State<_OrdersDialog> createState() => _OrdersDialogState();
}

class _OrdersDialogState extends State<_OrdersDialog> {
  List<Sale> _sales = [];
  bool _loading = true;
  String _dateFilter = 'اليوم'; // اليوم، الأسبوع، الشهر، الكل
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Filter by date
    if (_dateFilter == 'اليوم') {
      final today = DateTime.now();
      final startOfDay = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      final endOfDay = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
      ).toIso8601String();
      whereClause = 'date BETWEEN ? AND ?';
      whereArgs = [startOfDay, endOfDay];
    } else if (_dateFilter == 'الأسبوع') {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7)).toIso8601String();
      whereClause = 'date >= ?';
      whereArgs = [weekAgo];
    } else if (_dateFilter == 'الشهر') {
      final now = DateTime.now();
      final monthAgo = DateTime(
        now.year,
        now.month - 1,
        now.day,
      ).toIso8601String();
      whereClause = 'date >= ?';
      whereArgs = [monthAgo];
    } else if (_dateFilter == 'مخصص' &&
        _customStartDate != null &&
        _customEndDate != null) {
      final start = _customStartDate!.toIso8601String();
      final end = _customEndDate!
          .copyWith(hour: 23, minute: 59, second: 59)
          .toIso8601String();
      whereClause = 'date BETWEEN ? AND ?';
      whereArgs = [start, end];
    }

    final res = await db.query(
      'sales',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
      limit: 100,
    );

    if (mounted) {
      setState(() {
        _sales = res.map((e) => Sale.fromMap(e)).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(context.l10n.previousOrders)),
          // Date filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'فلتر التاريخ',
            onSelected: (value) async {
              if (value == 'مخصص') {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: DateTimeRange(
                    start:
                        _customStartDate ??
                        DateTime.now().subtract(const Duration(days: 7)),
                    end: _customEndDate ?? DateTime.now(),
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _dateFilter = 'مخصص';
                    _customStartDate = picked.start;
                    _customEndDate = picked.end;
                  });
                  _loadSales();
                }
              } else {
                setState(() {
                  _dateFilter = value;
                });
                _loadSales();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'اليوم',
                child: Row(
                  children: [
                    if (_dateFilter == 'اليوم')
                      const Icon(Icons.check, size: 16),
                    if (_dateFilter == 'اليوم') const SizedBox(width: 8),
                    const Text('اليوم'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'الأسبوع',
                child: Row(
                  children: [
                    if (_dateFilter == 'الأسبوع')
                      const Icon(Icons.check, size: 16),
                    if (_dateFilter == 'الأسبوع') const SizedBox(width: 8),
                    const Text('آخر أسبوع'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'الشهر',
                child: Row(
                  children: [
                    if (_dateFilter == 'الشهر')
                      const Icon(Icons.check, size: 16),
                    if (_dateFilter == 'الشهر') const SizedBox(width: 8),
                    const Text('آخر شهر'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'الكل',
                child: Row(
                  children: [
                    if (_dateFilter == 'الكل')
                      const Icon(Icons.check, size: 16),
                    if (_dateFilter == 'الكل') const SizedBox(width: 8),
                    const Text('الكل'),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'مخصص', child: Text('تاريخ مخصص...')),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            // Current filter indicator
            if (_dateFilter == 'مخصص' &&
                _customStartDate != null &&
                _customEndDate != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'من ${DateFormat('yyyy-MM-dd').format(_customStartDate!)} إلى ${DateFormat('yyyy-MM-dd').format(_customEndDate!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'الفلتر الحالي: $_dateFilter',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _sales.isEmpty
                  ? const Center(child: Text('لا توجد طلبات'))
                  : ListView.builder(
                      itemCount: _sales.length,
                      itemBuilder: (context, index) {
                        final sale = _sales[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ExpansionTile(
                            leading: Icon(
                              sale.isCancelled == 1
                                  ? Icons.cancel
                                  : sale.isRefunded == 1
                                  ? Icons.assignment_return
                                  : Icons.receipt,
                              color: sale.isCancelled == 1
                                  ? Colors.grey
                                  : sale.isRefunded == 1
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            title: Text(
                              "Inv: ${sale.invoiceId} | \$${sale.totalAmount.toStringAsFixed(2)}${sale.isCancelled == 1 ? ' (ملغي)' : ''}${sale.isRefunded == 1 ? ' (مرتجع)' : ''}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: sale.isCancelled == 1
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              "${sale.date.substring(0, 16).replaceFirst('T', ' ')} | ${sale.paymentMethod} | ${sale.orderType}",
                            ),
                            children: [
                              _buildSaleItemsList(sale),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Cancel button (only for non-refunded, non-cancelled orders)
                                  if (sale.isRefunded == 0 &&
                                      sale.isCancelled == 0)
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.grey,
                                      ),
                                      label: const Text(
                                        'إلغاء الطلب',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      onPressed: () => _cancelSale(sale),
                                    ),
                                  // Refund button (only for non-refunded, non-cancelled orders)
                                  if (sale.isRefunded == 0 &&
                                      sale.isCancelled == 0)
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.undo,
                                        color: Colors.orange,
                                      ),
                                      label: Text(
                                        context.l10n.refunds,
                                        style: const TextStyle(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      onPressed: () => _refundSale(sale),
                                    ),
                                  // Print receipt button
                                  TextButton.icon(
                                    icon: const Icon(Icons.print),
                                    label: Text(context.l10n.testPrint),
                                    onPressed: () => _printReceipt(sale),
                                  ),
                                  // Print kitchen receipt button
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.restaurant,
                                      color: Colors.blue,
                                    ),
                                    label: const Text(
                                      'واصل المطبخ',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    onPressed: () => _printKitchenReceipt(sale),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }

  Widget _buildSaleItemsList(Sale sale) {
    return FutureBuilder<List<SaleItem>>(
      future: DatabaseHelper.instance.getSaleItems(sale.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(context.l10n.loading),
          );
        }
        final items = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              dense: true,
              title: Text("${item.quantity}x ${item.productName}"),
              subtitle: item.addonsStr != null && item.addonsStr!.isNotEmpty
                  ? Text("  + ${item.addonsStr}")
                  : null,
              trailing: Text(
                "\$${(item.price * item.quantity).toStringAsFixed(2)}",
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelSale(Sale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد إلغاء الطلب"),
        content: const Text("هل تريد إلغاء هذا الطلب؟ (لن يحسب من الخسائر)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("لا"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text("نعم، إلغاء"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = DatabaseHelper.instance;
      await db.update(
        'sales',
        {'isCancelled': 1},
        where: 'id = ?',
        whereArgs: [sale.id],
      );
      // Don't return stock for cancelled orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم إلغاء الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSales();
      }
    }
  }

  Future<void> _refundSale(Sale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الإرجاع"),
        content: const Text("هل تريد إرجاع هذا الطلب؟ (سيتم إرجاع المخزون)"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("لا"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("نعم، إرجاع"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final db = DatabaseHelper.instance;
      await db.update(
        'sales',
        {'isRefunded': 1},
        where: 'id = ?',
        whereArgs: [sale.id],
      );
      final itemsRes = await db.query(
        'sale_items',
        where: 'saleId = ?',
        whereArgs: [sale.id],
      );
      final items = itemsRes.map((e) => SaleItem.fromMap(e)).toList();
      for (var item in items) {
        await db.rawUpdate(
          'UPDATE products SET stock = stock + ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
      if (mounted) {
        context.read<AppState>().refreshProducts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ تم إرجاع الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSales();
      }
    }
  }

  Future<void> _printReceipt(Sale sale) async {
    try {
      final items = await DatabaseHelper.instance.getSaleItems(sale.id!);
      final cartItems = items
          .map(
            (i) => CartItem(
              product: Product(
                id: i.productId,
                name: i.productName,
                categoryId: 0,
                costPrice: i.costPrice,
                sellPrice: i.price,
                laborCost: 0,
              ),
              quantity: i.quantity,
              size: i.size,
              unitPrice: i.price,
              addons: [],
            ),
          )
          .toList();

      // Reconstruct addons
      for (var i = 0; i < items.length; i++) {
        if (items[i].addonsStr != null && items[i].addonsStr!.isNotEmpty) {
          final names = items[i].addonsStr!.split(", ");
          cartItems[i].addons.addAll(
            names.map((n) => Addon(name: n, price: 0)),
          );
        }
      }

      if (context.mounted) {
        final appState = context.read<AppState>();
        await PrintingService.printReceipt(
          context,
          sale,
          cartItems,
          appState.currentUser ?? User(name: "Admin", pin: "", role: "admin"),
          appState.restaurantSettings,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ تم طباعة الفاتورة'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printKitchenReceipt(Sale sale) async {
    try {
      final items = await DatabaseHelper.instance.getSaleItems(sale.id!);
      final cartItems = items
          .map(
            (i) => CartItem(
              product: Product(
                id: i.productId,
                name: i.productName,
                categoryId: 0,
                costPrice: i.costPrice,
                sellPrice: i.price,
                laborCost: 0,
              ),
              quantity: i.quantity,
              size: i.size,
              unitPrice: i.price,
              addons: [],
            ),
          )
          .toList();

      // Reconstruct addons
      for (var i = 0; i < items.length; i++) {
        if (items[i].addonsStr != null && items[i].addonsStr!.isNotEmpty) {
          final names = items[i].addonsStr!.split(", ");
          cartItems[i].addons.addAll(
            names.map((n) => Addon(name: n, price: 0)),
          );
        }
      }

      if (context.mounted) {
        final results = await PrintingService.printKitchenTickets(
          context: context,
          invoiceId: sale.invoiceId,
          items: cartItems,
        );

        if (mounted) {
          final successCount = results.values.where((v) => v).length;
          final totalCount = results.length;

          if (successCount == totalCount) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ تم طباعة جميع واصلات المطبخ'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ تم طباعة $successCount من $totalCount'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ في طباعة واصل المطبخ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  int? _selectedEmployeeId;
  String _dateFilter = 'أسبوع'; // 'يوم', 'أسبوع', 'شهر', 'مخصص'

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reports,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${DateFormat('yyyy/MM/dd').format(_startDate)} - ${DateFormat('yyyy/MM/dd').format(_endDate)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          actions: [
            // تاريخ مخصص
            PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_today, color: Color(0xFF475569)),
              tooltip: "فلترة التاريخ",
              onSelected: (value) {
                if (value == 'مخصص') {
                  _pickDateRange();
                } else {
                  _setDateRange(value);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'اليوم', child: Text(context.l10n.today)),
                PopupMenuItem(value: 'أسبوع', child: Text(context.l10n.week)),
                PopupMenuItem(value: 'شهر', child: Text(context.l10n.month)),
                PopupMenuItem(value: 'مخصص', child: Text(context.l10n.custom)),
              ],
            ),
            // موظف
            PopupMenuButton<int>(
              icon: const Icon(Icons.person_outline, color: Color(0xFF475569)),
              tooltip: "فلترة الموظف",
              onSelected: (val) {
                setState(() {
                  _selectedEmployeeId = val == -1 ? null : val;
                });
              },
              itemBuilder: (context) {
                final users = context.read<AppState>().users;
                return [
                  PopupMenuItem(value: -1, child: Text(context.l10n.allStaff)),
                  ...users.map(
                    (u) => PopupMenuItem(value: u.id, child: Text(u.name)),
                  ),
                ];
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF3B82F6),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF3B82F6),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(
                text: context.l10n.dashboardSummary,
                icon: const Icon(Icons.dashboard, size: 20),
              ),
              Tab(
                text: context.l10n.sales,
                icon: const Icon(Icons.trending_up, size: 20),
              ),
              Tab(
                text: context.l10n.inventory,
                icon: const Icon(Icons.inventory, size: 20),
              ),
              Tab(
                text: context.l10n.customers,
                icon: const Icon(Icons.people, size: 20),
              ),
              Tab(
                text: context.l10n.staff,
                icon: const Icon(Icons.badge, size: 20),
              ),
              Tab(
                text: context.l10n.expenses,
                icon: const Icon(Icons.money_off, size: 20),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Colors.white],
            ),
          ),
          child: TabBarView(
            children: [
              _SummaryTab(
                startDate: _startDate,
                endDate: _endDate,
                employeeId: _selectedEmployeeId,
              ),
              _SalesTab(
                startDate: _startDate,
                endDate: _endDate,
                employeeId: _selectedEmployeeId,
              ),
              _InventoryTab(startDate: _startDate, endDate: _endDate),
              _CustomersTab(startDate: _startDate, endDate: _endDate),
              _StaffTab(startDate: _startDate, endDate: _endDate),
              _ExpensesReportTab(startDate: _startDate, endDate: _endDate),
            ],
          ),
        ),
      ),
    );
  }

  void _setDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      _dateFilter = range;
      switch (range) {
        case 'اليوم':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'أسبوع':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 'شهر':
          _startDate = DateTime(now.year, now.month - 1, now.day);
          _endDate = now;
          break;
      }
    });
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _dateFilter = 'مخصص';
      });
    }
  }
}

class _SummaryTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int? employeeId;

  const _SummaryTab({
    required this.startDate,
    required this.endDate,
    this.employeeId,
  });

  Future<Map<String, dynamic>> _fetchSummary() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate
        .copyWith(hour: 23, minute: 59, second: 59)
        .toIso8601String();

    String whereClause = "date BETWEEN ? AND ? AND isRefunded = 0";
    List<dynamic> args = [startStr, endStr];

    if (employeeId != null) {
      whereClause += " AND userId = ?";
      args.add(employeeId);
    }

    // الإحصائيات الرئيسية
    final salesRes = await db.rawQuery(
      "SELECT COUNT(*) as count, SUM(totalAmount) as total FROM sales WHERE $whereClause",
      args,
    );

    // المبالغ المستردة
    String refundWhere = "date BETWEEN ? AND ? AND isRefunded = 1";
    List<dynamic> refundArgs = [startStr, endStr];
    if (employeeId != null) {
      refundWhere += " AND userId = ?";
      refundArgs.add(employeeId);
    }
    final refundRes = await db.rawQuery(
      "SELECT COUNT(*) as count, SUM(totalAmount) as total FROM sales WHERE $refundWhere",
      refundArgs,
    );

    // التكلفة
    final costRes = await db.rawQuery('''
      SELECT SUM(si.costPrice * si.quantity) as totalCost 
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      WHERE $whereClause
    ''', args);

    // العملاء النشطين
    final customersRes = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT customerId) as count 
      FROM sales 
      WHERE date BETWEEN ? AND ? AND customerId IS NOT NULL
    ''',
      [startStr, endStr],
    );

    final totalSales = (salesRes.first['total'] as num?)?.toDouble() ?? 0.0;
    final ordersCount = (salesRes.first['count'] as num?)?.toInt() ?? 0;
    final refundCount = (refundRes.first['count'] as num?)?.toInt() ?? 0;
    final refundTotal = (refundRes.first['total'] as num?)?.toDouble() ?? 0.0;
    final cost = (costRes.first['totalCost'] as num?)?.toDouble() ?? 0.0;

    final activeCustomers = (customersRes.first['count'] as num?)?.toInt() ?? 0;

    // المصروفات
    final expensesRes = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date BETWEEN ? AND ?',
      [startStr, endStr],
    );
    final totalExpenses =
        (expensesRes.first['total'] as num?)?.toDouble() ?? 0.0;

    final profit = totalSales - cost - totalExpenses;

    return {
      'totalSales': totalSales,
      'ordersCount': ordersCount,
      'refundCount': refundCount,
      'refundTotal': refundTotal,
      'profit': profit,
      'cost': cost,
      'activeCustomers': activeCustomers,
      'totalExpenses': totalExpenses,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;

        final double width = MediaQuery.of(context).size.width;
        int crossAxisCount = 2;
        double childAspectRatio = 1.25;
        if (width > 1200) {
          crossAxisCount = 5;
          childAspectRatio = 1.4;
        } else if (width > 900) {
          crossAxisCount = 4;
          childAspectRatio = 1.3;
        } else if (width > 600) {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقات الإحصائيات
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _statCard(
                    context.l10n.totalSales,
                    "${data['totalSales'].toStringAsFixed(0)} دينار",
                    Icons.attach_money,
                    const Color(0xFF10B981),
                    "+12%",
                  ),
                  _statCard(
                    context.l10n.ordersCount,
                    data['ordersCount'].toString(),
                    Icons.shopping_cart,
                    const Color(0xFF3B82F6),
                    "+8%",
                  ),
                  _statCard(
                    context.l10n.netProfit,
                    "${data['profit'].toStringAsFixed(0)} دينار",
                    Icons.trending_up,
                    const Color(0xFF8B5CF6),
                    "+15%",
                  ),
                  _statCard(
                    context.l10n.activeCustomers,
                    data['activeCustomers'].toString(),
                    Icons.people,
                    const Color(0xFFF59E0B),
                    "+5%",
                  ),
                  _statCard(
                    context.l10n.expenses,
                    "${data['totalExpenses'].toStringAsFixed(0)} دينار",
                    Icons.money_off,
                    const Color(0xFFEF4444),
                    "",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // رسم بياني
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.financialPerformance,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value} دينار',
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {
                                'category': context.l10n.revenue,
                                'value': data['totalSales'],
                              },
                              {
                                'category': context.l10n.cost,
                                'value': data['cost'],
                              },
                              {
                                'category': context.l10n.expenses,
                                'value': data['totalExpenses'],
                              },
                              {
                                'category': context.l10n.profit,
                                'value': data['profit'],
                              },
                            ],
                            xValueMapper: (Map<String, dynamic> data, _) =>
                                data['category'],
                            yValueMapper: (Map<String, dynamic> data, _) =>
                                data['value'],
                            name: context.l10n.amount,
                            color: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // بطاقات إضافية
              Row(
                children: [
                  Expanded(
                    child: _miniCard(
                      context.l10n.refunds,
                      data['refundCount'].toString(),
                      Icons.replay,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _miniCard(
                      context.l10n.avgOrderValue,
                      "${(data['totalSales'] / (data['ordersCount'] == 0 ? 1 : data['ordersCount'])).toStringAsFixed(0)} دينار",
                      Icons.av_timer,
                      const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (trend.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      trend,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SalesTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int? employeeId;

  const _SalesTab({
    required this.startDate,
    required this.endDate,
    this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF3B82F6),
              tabs: [
                Tab(text: context.l10n.products),
                Tab(text: context.l10n.paymentMethods),
                Tab(text: context.l10n.analytics),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ProductsReport(
                  startDate: startDate,
                  endDate: endDate,
                  employeeId: employeeId,
                ),
                _PaymentsReport(
                  startDate: startDate,
                  endDate: endDate,
                  employeeId: employeeId,
                ),
                _AnalyticsReport(
                  startDate: startDate,
                  endDate: endDate,
                  employeeId: employeeId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsReport extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int? employeeId;

  const _ProductsReport({
    required this.startDate,
    required this.endDate,
    this.employeeId,
  });

  Future<List<Map<String, dynamic>>> _getData() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    String sql = '''
      SELECT 
        p.name, 
        SUM(si.quantity) as qty, 
        p.laborCost,
        p.costPrice, 
        p.sellPrice,
        SUM(si.price * si.quantity) as totalRevenue,
        SUM((si.price - p.costPrice) * si.quantity) as totalProfit
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      JOIN products p ON p.id = si.productId
      WHERE s.date BETWEEN ? AND ? AND s.isRefunded = 0
    ''';

    List<dynamic> args = [startStr, endStr];
    if (employeeId != null) {
      sql += " AND s.userId = ?";
      args.add(employeeId);
    }
    sql += " GROUP BY p.id ORDER BY totalRevenue DESC";

    return await db.rawQuery(sql, args);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data as List<Map<String, dynamic>>;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${context.l10n.productsCount}: ${items.length}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.l10n.filterBySales,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final e = items[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // ترتيب المنتج
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index < 3
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: index < 3
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // تفاصيل المنتج
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _infoChip(
                                    "${context.l10n.quantity}: ${e['qty']}",
                                    const Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 8),
                                  _infoChip(
                                    "${context.l10n.laborCost}: ${e['laborCost']}",
                                    const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // الأرقام المالية
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$${(e['totalRevenue'] as num).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "${context.l10n.cost}: \$${e['costPrice']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${context.l10n.sellPrice}: \$${e['sellPrice']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

class _PaymentsReport extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int? employeeId;

  const _PaymentsReport({
    required this.startDate,
    required this.endDate,
    this.employeeId,
  });

  Future<List<Map<String, dynamic>>> _getData() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    String sql = '''
      SELECT paymentMethod, 
             COUNT(*) as count,
             SUM(totalAmount) as total
      FROM sales
      WHERE date BETWEEN ? AND ? AND isRefunded = 0
    ''';

    List<dynamic> args = [startStr, endStr];
    if (employeeId != null) {
      sql += " AND userId = ?";
      args.add(employeeId);
    }
    sql += " GROUP BY paymentMethod ORDER BY total DESC";

    return await db.rawQuery(sql, args);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data as List<Map<String, dynamic>>;
        final total = data.fold(
          0.0,
          (sum, item) => sum + (item['total'] as num).toDouble(),
        );

        return Column(
          children: [
            // إحصائيات سريعة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.totalPayments,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.payment, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ),

            // قائمة طرق الدفع
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final row = data[index];
                  final percentage = total > 0
                      ? (row['total'] as num).toDouble() / total * 100
                      : 0;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getPaymentColor(
                            row['paymentMethod'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _typeIcon(row['paymentMethod']),
                          color: _getPaymentColor(row['paymentMethod']),
                        ),
                      ),
                      title: Text(
                        _getPaymentName(context, row['paymentMethod']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: _getPaymentColor(row['paymentMethod']),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${percentage.toStringAsFixed(1)}% ${context.l10n.percentageOfSales}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${(row['total'] as num).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${row['count']} ${context.l10n.operation}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getPaymentName(BuildContext context, String? type) {
    switch (type?.toLowerCase()) {
      case 'cash':
        return context.l10n.cash;
      case 'card':
        return context.l10n.creditCard;
      case 'transfer':
        return context.l10n.transfer;
      default:
        return type ?? context.l10n.unknown;
    }
  }

  Color _getPaymentColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'cash':
        return const Color(0xFF10B981);
      case 'card':
        return const Color(0xFF3B82F6);
      case 'transfer':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _typeIcon(String? type) {
    if (type == 'cash') return Icons.money;
    if (type == 'card') return Icons.credit_card;
    return Icons.payment;
  }
}

class _AnalyticsReport extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int? employeeId;

  const _AnalyticsReport({
    required this.startDate,
    required this.endDate,
    this.employeeId,
  });

  Future<Map<String, dynamic>> _getAnalytics() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    // المنتج الأكثر مبيعاً
    final bestSeller = await db.rawQuery(
      '''
      SELECT p.name, SUM(si.quantity) as totalQty
      FROM sale_items si
      JOIN sales s ON s.id = si.saleId
      JOIN products p ON p.id = si.productId
      WHERE s.date BETWEEN ? AND ? AND s.isRefunded = 0
      GROUP BY p.id
      ORDER BY totalQty DESC
      LIMIT 1
    ''',
      [startStr, endStr],
    );

    // متوسط قيمة الطلب
    final avgOrder = await db.rawQuery(
      '''
      SELECT AVG(totalAmount) as avg
      FROM sales
      WHERE date BETWEEN ? AND ? AND isRefunded = 0
    ''',
      [startStr, endStr],
    );

    // ساعات الذروة
    final peakHours = await db.rawQuery(
      '''
      SELECT strftime('%H', date) as hour, COUNT(*) as count
      FROM sales
      WHERE date BETWEEN ? AND ? AND isRefunded = 0
      GROUP BY hour
      ORDER BY count DESC
      LIMIT 3
    ''',
      [startStr, endStr],
    );

    return {
      'bestSeller': bestSeller.isNotEmpty ? bestSeller.first['name'] : null,
      'avgOrderValue': (avgOrder.first['avg'] as num?)?.toDouble() ?? 0.0,
      'peakHours': peakHours.map((e) => e['hour'] as String).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // توقعات المبيعات
            _analyticsCard(
              Icons.trending_up,
              context.l10n.salesForecast,
              context.l10n.salesForecastMsg,
              const Color(0xFF10B981),
            ),

            const SizedBox(height: 16),

            // أكثر المنتجات مبيعاً
            _analyticsCard(
              Icons.star,
              context.l10n.bestSeller,
              context.l10n.bestSellerMsg.replaceAll(
                '@product',
                data['bestSeller'] ?? context.l10n.noData,
              ),
              const Color(0xFFF59E0B),
            ),

            const SizedBox(height: 16),

            // اقتراحات
            _analyticsCard(
              Icons.lightbulb,
              context.l10n.profitTips,
              context.l10n.profitTipsMsg,
              const Color(0xFF3B82F6),
            ),

            const SizedBox(height: 16),

            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.statisticalInfo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _statItem(
                        context.l10n.avgOrderValue,
                        "\$${data['avgOrderValue'].toStringAsFixed(2)}",
                      ),
                      const SizedBox(width: 16),
                      _statItem(
                        context.l10n.peakHours,
                        data['peakHours'].join(', '),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _analyticsCard(
    IconData icon,
    String title,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTab extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _InventoryTab({required this.startDate, required this.endDate});

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  int? _selectedProductId;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final db = DatabaseHelper.instance;
    final res = await db.query('products', orderBy: 'name');
    if (mounted) {
      setState(() {
        _products = res.map((e) => Product.fromMap(e)).toList();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getIngredientsData() async {
    final db = DatabaseHelper.instance;

    // Base query for ingredients
    String sql = '''
      SELECT 
        i.id,
        i.name,
        i.unit,
        i.currentStock,
        i.costPrice
      FROM ingredients i
    ''';

    // If filtering by product, join with product_ingredients
    if (_selectedProductId != null) {
      sql = '''
        SELECT 
          i.id,
          i.name,
          i.unit,
          i.currentStock,
          i.costPrice,
          pi.quantity as quantityInfo
        FROM ingredients i
        JOIN product_ingredients pi ON pi.ingredientId = i.id
        WHERE pi.productId = ?
      ''';
      return await db.rawQuery(sql, [_selectedProductId]);
    }

    return await db.rawQuery(sql);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                '${context.l10n.filterByProduct}:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedProductId,
                      hint: Text(context.l10n.allIngredients),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(context.l10n.allIngredients),
                        ),
                        ..._products.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedProductId = val;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ingredients List
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _getIngredientsData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snapshot.data!;

              if (data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedProductId == null
                            ? context.l10n.noIngredientsFound
                            : context.l10n.noIngredientsLinked,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final row = data[index];
                  final isLowStock = (row['currentStock'] as num) <= 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isLowStock
                          ? const BorderSide(color: Colors.red, width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isLowStock
                            ? Colors.red.withOpacity(0.1)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        child: Icon(
                          Icons.kitchen,
                          color: isLowStock
                              ? Colors.red
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                      title: Text(
                        row['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          _selectedProductId != null &&
                              row['quantityInfo'] != null
                          ? Text(
                              '${context.l10n.quantityInProduct}: ${row['quantityInfo']} ${row['unit'] ?? ''}',
                            )
                          : null,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${row['currentStock']} ${row['unit'] ?? ''}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isLowStock
                                  ? Colors.red
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "${context.l10n.cost}: \$${(row['costPrice'] as num).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomersTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _CustomersTab({required this.startDate, required this.endDate});

  Future<List<Map<String, dynamic>>> _getCustomerData() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    // Get all customers first
    final allCustomers = await db.query('customers');

    // For each customer, get their sales stats in the date range
    final List<Map<String, dynamic>> result = [];

    for (final customer in allCustomers) {
      final customerId = customer['id'] as int;

      // Get sales for this customer in the date range
      final salesRes = await db.rawQuery(
        '''
        SELECT 
          s.id,
          s.totalAmount,
          s.date
        FROM sales s
        WHERE s.customerId = ? AND s.date BETWEEN ? AND ?
        ''',
        [customerId, startStr, endStr],
      );

      // Calculate stats
      final ordersCount = salesRes.length;
      final totalSpent = salesRes.fold<double>(
        0.0,
        (sum, sale) => sum + ((sale['totalAmount'] as num?)?.toDouble() ?? 0.0),
      );
      final avgOrderValue = ordersCount > 0 ? totalSpent / ordersCount : 0.0;
      final lastOrderDate = salesRes.isNotEmpty
          ? salesRes
                .map((s) => s['date'] as String)
                .reduce((a, b) => a.compareTo(b) > 0 ? a : b)
          : null;

      // Get top products for this customer
      final topProductsRes = await db.rawQuery(
        '''
        SELECT DISTINCT p.name
        FROM sale_items si
        JOIN sales s ON si.saleId = s.id
        JOIN products p ON si.productId = p.id
        WHERE s.customerId = ? AND s.date BETWEEN ? AND ?
        LIMIT 5
        ''',
        [customerId, startStr, endStr],
      );
      final topProducts = topProductsRes
          .map((p) => p['name'] as String)
          .join(' | ');

      result.add({
        'id': customerId,
        'name': customer['name'],
        'phone': customer['phone'],
        'email': customer['email'],
        'notes': customer['notes'],
        'ordersCount': ordersCount,
        'totalSpent': totalSpent,
        'avgOrderValue': avgOrderValue,
        'lastOrderDate': lastOrderDate,
        'topProducts': topProducts.isNotEmpty ? topProducts : null,
      });
    }

    // Sort by totalSpent DESC, then ordersCount DESC
    result.sort((a, b) {
      final spentA = (a['totalSpent'] as num).toDouble();
      final spentB = (b['totalSpent'] as num).toDouble();
      if (spentA != spentB) {
        return spentB.compareTo(spentA);
      }
      final ordersA = a['ordersCount'] as int;
      final ordersB = b['ordersCount'] as int;
      return ordersB.compareTo(ordersA);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getCustomerData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final customers = snapshot.data!;

        return Column(
          children: [
            // إحصائيات العملاء
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _customerStatCard(
                    context.l10n.totalCustomers,
                    customers.length.toString(),
                    Icons.people,
                    const Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 12),
                  _customerStatCard(
                    context.l10n.totalSpent,
                    "\$${customers.fold(0.0, (sum, c) => sum + (c['totalSpent'] as num).toDouble()).toStringAsFixed(0)}",
                    Icons.shopping_cart,
                    const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            // قائمة العملاء
            Expanded(
              child: customers.isEmpty
                  ? Center(child: Text(context.l10n.noCustomersInPeriod))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        final initials =
                            customer['name']
                                ?.toString()
                                .split(' ')
                                .map((w) => w.isNotEmpty ? w[0] : '')
                                .take(2)
                                .join()
                                .toUpperCase() ??
                            '?';

                        final totalSpent =
                            (customer['totalSpent'] as num?)?.toDouble() ?? 0.0;
                        final ordersCount = customer['ordersCount'] ?? 0;
                        final avgOrderValue =
                            (customer['avgOrderValue'] as num?)?.toDouble() ??
                            0.0;
                        final lastOrderDate =
                            customer['lastOrderDate'] as String?;

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCustomerColor(index),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              customer['name'] ?? context.l10n.unknownCustomer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customer['phone'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          customer['phone'],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (lastOrderDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${context.l10n.lastOrder}: ${lastOrderDate.substring(0, 10)}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\$${totalSpent.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                Text(
                                  "$ordersCount ${context.l10n.order}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          context.l10n.avgOrderValue,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          "\$${avgOrderValue.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (customer['email'] != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            size: 14,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              customer['email'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (customer['notes'] != null &&
                                        customer['notes']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.note,
                                            size: 14,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              customer['notes'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (customer['topProducts'] != null &&
                                        customer['topProducts']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        "أكثر المنتجات:",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        customer['topProducts'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _customerStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCustomerColor(int index) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    return colors[index % colors.length];
  }
}

class _StaffTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _StaffTab({required this.startDate, required this.endDate});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF3B82F6),
              tabs: [
                Tab(text: context.l10n.staffPerformance),
                Tab(text: context.l10n.shifts),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _StaffPerformanceTab(startDate: startDate, endDate: endDate),
                _ShiftsTab(startDate: startDate, endDate: endDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffPerformanceTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _StaffPerformanceTab({required this.startDate, required this.endDate});

  Future<List<Map<String, dynamic>>> _getData() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    return await db.rawQuery(
      '''
      SELECT 
        u.id,
        u.name,
        u.role,
        COUNT(s.id) as salesCount,
        SUM(s.totalAmount) as salesTotal,
        AVG(s.totalAmount) as avgSale
      FROM users u
      LEFT JOIN sales s ON u.id = s.userId AND s.date BETWEEN ? AND ? AND s.isRefunded = 0
      GROUP BY u.id
      ORDER BY salesTotal DESC
    ''',
      [startStr, endStr],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final staffList = snapshot.data!;

        return Column(
          children: [
            // ترتيب الموظفين
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: staffList.take(3).map((staff) {
                  final rank = staffList.indexOf(staff) + 1;
                  return _staffRankCard(staff, rank);
                }).toList(),
              ),
            ),

            // قائمة كاملة
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final staff = staffList[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStaffColor(staff['role']),
                        child: Text(
                          staff['name'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        staff['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        staff['role'] == 'admin'
                            ? context.l10n.admin
                            : context.l10n.cashier,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${(staff['salesTotal'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${staff['salesCount'] ?? 0} ${context.l10n.operation}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _staffRankCard(Map<String, dynamic> staff, int rank) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1
                  ? const Color(0xFFFFD700)
                  : rank == 2
                  ? const Color(0xFFC0C0C0)
                  : const Color(0xFFCD7F32),
              shape: BoxShape.circle,
            ),
            child: Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            staff['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "\$${(staff['salesTotal'] as num?)?.toStringAsFixed(0) ?? '0'}",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStaffColor(String? role) {
    return role == 'admin' ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6);
  }
}

class _ShiftsTab extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _ShiftsTab({required this.startDate, required this.endDate});

  Future<List<Map<String, dynamic>>> _getShiftsData() async {
    final db = DatabaseHelper.instance;
    final startStr = startDate.toIso8601String();
    final endStr = endDate.copyWith(hour: 23, minute: 59).toIso8601String();

    return await db.rawQuery(
      '''
      SELECT 
        u.name,
        sh.startTime,
        sh.endTime,
        sh.startCash,
        sh.endCash,
        sh.salesTotal,
        sh.refundsTotal
      FROM shifts sh
      JOIN users u ON sh.userId = u.id
      WHERE sh.startTime BETWEEN ? AND ?
      ORDER BY sh.startTime DESC
    ''',
      [startStr, endStr],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getShiftsData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final shifts = snapshot.data!;

        return shifts.isEmpty
            ? Center(child: Text(context.l10n.noShiftsFound))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  final startTime = DateTime.parse(shift['startTime']);
                  final endTime = shift['endTime'] != null
                      ? DateTime.parse(shift['endTime'])
                      : null;

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                shift['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: endTime != null
                                      ? const Color(0xFF10B981).withOpacity(0.1)
                                      : const Color(
                                          0xFFF59E0B,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  endTime != null
                                      ? context.l10n.shiftClosed
                                      : context.l10n.shiftOpen,
                                  style: TextStyle(
                                    color: endTime != null
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _shiftInfoItem(
                                Icons.access_time,
                                DateFormat('HH:mm').format(startTime),
                              ),
                              const SizedBox(width: 16),
                              _shiftInfoItem(
                                Icons.timer_off,
                                endTime != null
                                    ? DateFormat('HH:mm').format(endTime)
                                    : context.l10n.ongoing,
                              ),
                              const SizedBox(width: 16),
                              _shiftInfoItem(
                                Icons.access_time,
                                endTime != null
                                    ? _formatDuration(
                                        context,
                                        endTime.difference(startTime),
                                      )
                                    : '--',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _shiftStatItem(
                                context.l10n.sales,
                                "\$${shift['salesTotal']?.toStringAsFixed(2) ?? '0.00'}",
                                Icons.shopping_cart,
                                const Color(0xFF10B981),
                              ),
                              _shiftStatItem(
                                context.l10n.cash,
                                "\$${shift['endCash']?.toStringAsFixed(2) ?? '0.00'}",
                                Icons.money,
                                const Color(0xFF3B82F6),
                              ),
                              _shiftStatItem(
                                context.l10n.refunds,
                                "\$${shift['refundsTotal']?.toStringAsFixed(2) ?? '0.00'}",
                                Icons.replay,
                                const Color(0xFFEF4444),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
      },
    );
  }

  Widget _shiftInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  Widget _shiftStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '$hours${context.l10n.hourShort} $minutes${context.l10n.minuteShort}';
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settings),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: context.l10n.general),
              Tab(text: context.l10n.connection),
              const Tab(
                text: "مزامنه",
              ), // Hardcoded for now or add to l10n later
              Tab(text: context.l10n.staff),
              Tab(text: context.l10n.tools),
              Tab(text: context.l10n.more),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _GeneralSettings(),
            const _ConnectionSettings(),
            const SyncSettings(),
            const _StaffSettings(),
            _ToolsSettings(),
            _MoreSettings(),
          ],
        ),
      ),
    );
  }
}

class _ConnectionSettings extends StatefulWidget {
  const _ConnectionSettings();
  @override
  State<_ConnectionSettings> createState() => _ConnectionSettingsState();
}

class _ConnectionSettingsState extends State<_ConnectionSettings> {
  bool _usePostgres = false;
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _dbCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _usePostgres = prefs.getBool('use_postgres') ?? false;
        _hostCtrl.text = prefs.getString('pg_host') ?? 'localhost';
        _portCtrl.text = (prefs.getInt('pg_port') ?? 5432).toString();
        _dbCtrl.text = prefs.getString('pg_db') ?? 'kpos';
        _userCtrl.text = prefs.getString('pg_user') ?? 'postgres';
        _passCtrl.text = prefs.getString('pg_pass') ?? '';
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_postgres', _usePostgres);
    await prefs.setString('pg_host', _hostCtrl.text);
    await prefs.setInt('pg_port', int.tryParse(_portCtrl.text) ?? 5432);
    await prefs.setString('pg_db', _dbCtrl.text);
    await prefs.setString('pg_user', _userCtrl.text);
    await prefs.setString('pg_pass', _passCtrl.text);

    await DatabaseHelper.instance.resetConnection();
    if (mounted) {
      // Force reload of app state data
      // We don't have a direct reset method on AppState shown,
      // but we can at least notify user to restart or implement a reload.
      // Ideally call something like:
      // await context.read<AppState>().reloadAllData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.saveSettings,
          ), // Or a better success message
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    try {
      final service = PostgresService(
        host: _hostCtrl.text,
        port: int.tryParse(_portCtrl.text) ?? 5432,
        databaseName: _dbCtrl.text,
        username: _userCtrl.text,
        password: _passCtrl.text,
      );
      await service.init();
      await service.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection Successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 800;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Connection Form
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildConnectionForm(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right: DB Info Card
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: _buildDatabaseInfoCard(context),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildConnectionForm(context),
          );
        }
      },
    );
  }

  Widget _buildConnectionForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.database,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.usePostgres),
          subtitle: const Text(
            "Use an external PostgreSQL database instead of local SQLite",
          ),
          value: _usePostgres,
          onChanged: (val) => setState(() => _usePostgres = val),
        ),
        const Divider(height: 32),
        TextField(
          controller: _hostCtrl,
          decoration: const InputDecoration(
            labelText: 'Host',
            prefixIcon: Icon(Icons.dns),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _portCtrl,
          decoration: const InputDecoration(
            labelText: 'Port',
            prefixIcon: Icon(Icons.tag),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dbCtrl,
          decoration: const InputDecoration(
            labelText: 'Database Name',
            prefixIcon: Icon(Icons.storage),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _userCtrl,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.sync_alt),
                onPressed: _isLoading ? null : _testConnection,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.testConnection),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: Text(context.l10n.saveSettings),
          ),
        ),
      ],
    );
  }

  Widget _buildDatabaseInfoCard(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade800),
                    const SizedBox(width: 8),
                    Text(
                      "لماذا تستخدم PostgreSQL؟",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "تسمح لك قاعدة البيانات الخارجية بمشاركة البيانات بين أجهزة متعددة في نفس الوقت وضمان استمرارية العمل حتى في حال فقدان الجهاز المحلي.",
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.orange.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "تحذير هام",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "تأكد من أن الخادم (Server) يعمل ومتاح عبر الشبكة قبل تفعيل هذا الخيار، وإلا قد لا يتمكن التطبيق من الفتح.",
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneralSettings extends StatefulWidget {
  const _GeneralSettings();
  @override
  State<_GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<_GeneralSettings> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addrCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _taxCtrl;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppState>().restaurantSettings;
    _nameCtrl = TextEditingController(text: settings['name']);
    _addrCtrl = TextEditingController(text: settings['address']);
    _phoneCtrl = TextEditingController(text: settings['phone']);
    _taxCtrl = TextEditingController(text: settings['tax'] ?? '0.0');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 800;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Restaurant Info
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildRestaurantInfoSection(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right: Branch Management
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          elevation: 1,
                          color: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.store,
                                      color: Colors.blue.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "إدارة الفروع / Branches",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildBranchSelector(context),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBranchInfoCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRestaurantInfoSection(context),
                const Divider(height: 48),
                Text(
                  "إدارة الفروع / Branches",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildBranchSelector(context),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildRestaurantInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Restaurant Information (Receipt Header)",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "This information will appear at the top of your printed receipts.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: "Restaurant Name",
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _addrCtrl,
          decoration: const InputDecoration(
            labelText: "Address",
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneCtrl,
          decoration: const InputDecoration(
            labelText: "Phone",
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _taxCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Tax Percentage (%)",
            prefixIcon: Icon(Icons.percent),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            onPressed: () {
              context.read<AppState>().updateRestaurantInfo(
                _nameCtrl.text,
                _addrCtrl.text,
                _phoneCtrl.text,
                double.tryParse(_taxCtrl.text) ?? 0.0,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Settings Saved")));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text("Save General Settings"),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.blueGrey, size: 32),
            SizedBox(height: 12),
            Text(
              "نصيحة: الفروع تساعدك على تنظيم المبيعات والمخزون لكل موقع بشكل منفصل.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSelector(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Current Branch (Select to switch)",
                  border: OutlineInputBorder(),
                ),
                value: appState.activeBranch?.id,
                items: appState.availableBranches.map((branch) {
                  return DropdownMenuItem(
                    value: branch.id,
                    child: Text(branch.name),
                  );
                }).toList(),
                onChanged: (branchId) {
                  if (branchId != null) {
                    try {
                      final branch = appState.availableBranches.firstWhere(
                        (b) => b.id == branchId,
                      );
                      appState.setActiveBranch(branch);
                    } catch (e) {
                      // ignore
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Add New Branch",
              onPressed: () => _showAddBranchDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: "Fetch Branches from Cloud",
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fetching branches...")),
                  );

                  final service = FirestoreSyncService();
                  final branches = await service.fetchBranches();

                  int added = 0;
                  if (branches.isNotEmpty) {
                    // We don't have direct access to check DB for duplicates easily here without context.read<AppState> logic expansion
                    // But we can just use addBranch from AppState if we modify it or just add logic here.
                    // AppState.addBranch takes 'name'.

                    final appState = context.read<AppState>();

                    for (var bData in branches) {
                      final name = bData['name'] as String;
                      final exists = appState.availableBranches.any(
                        (b) => b.name == name,
                      );
                      if (!exists) {
                        await appState.addBranch(name);
                        added++;
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Fetched & Added $added new branches"),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No branches found in Cloud"),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error fetching branches: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddBranchDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Branch"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Branch Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await context.read<AppState>().addBranch(ctrl.text);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _StaffSettings extends StatefulWidget {
  const _StaffSettings();
  @override
  State<_StaffSettings> createState() => _StaffSettingsState();
}

class _StaffSettingsState extends State<_StaffSettings> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: context.read<AppState>().getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 800;

            if (isTablet) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: User List
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.l10n.users,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.person_add),
                                    onPressed: () => _showUserDialog(context),
                                    label: Text(context.l10n.addUser),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(child: _buildUserList(users)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right: Role Info
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildSecurityCard(),
                            const SizedBox(height: 16),
                            _buildRoleDescriptionCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.person_add),
                  onPressed: () => _showUserDialog(context),
                ),
                body: _buildUserList(users),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserList(List<User> users) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: user.role == 'admin'
                ? Colors.red.shade100
                : Colors.blue.shade100,
            child: Text(
              user.role[0].toUpperCase(),
              style: TextStyle(
                color: user.role == 'admin' ? Colors.red : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("PIN: ${user.pin} | Role: ${user.role}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showUserDialog(context, user: user),
              ),
              if (user.id != context.read<AppState>().currentUser?.id)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete User"),
                        content: Text(
                          "Are you sure you want to delete ${user.name}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await context.read<AppState>().deleteUser(user.id!);
                      setState(() {});
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityCard() {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade100),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.security, color: Colors.green, size: 32),
            SizedBox(height: 12),
            Text(
              "أمن البيانات: تأكد من اختيار رموز PIN فريدة لكل موظف وعدم مشاركتها لضمان دقة التقارير.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDescriptionCard() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "نظرة على الصلاحيات:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _RoleItem(
              role: "مدير / Admin",
              desc: "وصول كامل لجميع ميزات التطبيق والتقارير والإعدادات.",
              icon: Icons.admin_panel_settings,
            ),
            _RoleItem(
              role: "كاشير / Cashier",
              desc: "القيام بعمليات البيع وفتح الفواتير فقط.",
              icon: Icons.point_of_sale,
            ),
            _RoleItem(
              role: "طباخ / Chef",
              desc: "إدارة طلبات المطبخ والمخزون المتعلق بالمكونات.",
              icon: Icons.restaurant,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDialog(BuildContext context, {User? user}) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final pinCtrl = TextEditingController(text: user?.pin ?? '');
    String role = user?.role ?? 'cashier';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? "Add User" : "Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: pinCtrl,
                decoration: const InputDecoration(labelText: "PIN (4 digits)"),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text("Admin")),
                  DropdownMenuItem(value: 'cashier', child: Text("Cashier")),
                  DropdownMenuItem(value: 'chef', child: Text("Chef")),
                ],
                onChanged: (v) => setState(() => role = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && pinCtrl.text.isNotEmpty) {
                  final newUser = User(
                    id: user?.id,
                    name: nameCtrl.text,
                    pin: pinCtrl.text,
                    role: role,
                  );
                  if (user == null) {
                    await context.read<AppState>().addUser(newUser);
                  } else {
                    await context.read<AppState>().updateUser(newUser);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    this.setState(() {}); // Refresh list
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  final String role;
  final String desc;
  final IconData icon;

  const _RoleItem({required this.role, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsSettings extends StatefulWidget {
  const _ToolsSettings();

  @override
  State<_ToolsSettings> createState() => _ToolsSettingsState();
}

class _ToolsSettingsState extends State<_ToolsSettings> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 800;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Devices Management
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildDevicesList(context, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right: Help & Reset
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTroubleshootingCard(),
                        const SizedBox(height: 16),
                        _buildFactoryResetCard(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildDevicesList(context, state),
                const Divider(height: 48),
                _buildFactoryResetCard(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDevicesList(BuildContext context, AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "إدارة الأجهزة / Devices",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                ),
                onPressed: () => _showPrinterDialog(context),
                label: const Text("Add Printer"),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            "الطابعات المتاحة",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        if (state.availablePrinters.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "No printers configured.",
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...state.availablePrinters.map(
            (printer) => _buildPrinterItem(context, printer),
          ),
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "أجهزة الدفع",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () => _showPaymentDeviceDialog(context),
                label: const Text("إضافة جهاز"),
              ),
            ],
          ),
        ),
        FutureBuilder<List<PaymentDevice>>(
          future: DatabaseHelper.instance.getPaymentDevices(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final devices = snapshot.data!;
            if (devices.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "لا توجد أجهزة دفع مُعدة.",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return Column(
              children: devices
                  .map((device) => _buildPaymentDeviceItem(context, device))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrinterItem(BuildContext context, Printer printer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: printer.isReceipt
              ? Colors.green.shade100
              : Colors.grey.shade200,
          child: Icon(
            printer.isReceipt ? Icons.receipt_long : Icons.print,
            color: printer.isReceipt ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          printer.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${printer.ipAddress}:${printer.port}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.print_outlined, color: Colors.blue),
              onPressed: () => PrintingService.testPrint(context, printer),
              tooltip: 'اختبار الطباعة',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showPrinterDialog(context, printer: printer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDeviceItem(BuildContext context, PaymentDevice device) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: device.isActive
          ? Colors.blue.withOpacity(0.05)
          : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: device.isActive ? Colors.blue.shade100 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.isActive
              ? Colors.blue.shade100
              : Colors.grey.shade200,
          child: Icon(
            Icons.credit_card,
            color: device.isActive ? Colors.blue : Colors.grey,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          device.connectionType == 'TCP'
              ? "${device.ipAddress}:${device.port}"
              : device.serialPort ?? 'Serial',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: device.isActive,
              onChanged: (val) async {
                final updated = PaymentDevice(
                  id: device.id,
                  name: device.name,
                  type: device.type,
                  connectionType: device.connectionType,
                  ipAddress: device.ipAddress,
                  port: device.port,
                  serialPort: device.serialPort,
                  baudRate: device.baudRate,
                  isActive: val,
                );
                await DatabaseHelper.instance.updatePaymentDevice(updated);
                setState(() {});
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  _showPaymentDeviceDialog(context, device: device),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "حل المشكلات",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "• تأكد من أن الطابعة واللمتصلبن على نفس الشبكة.\n"
              "• جرب اختبار الطباعة بعد كل تعديل للـ IP.\n"
              "• أجهزة الدفع تتطلب مفعول السحابة للعمل بشكل صحيح.",
              style: TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactoryResetCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  context.l10n.factoryReset,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "هذا الإجراء سيقوم بحذف جميع البيانات المحلية والعودة للإعدادات الافتراضية. لا يمكن التراجع عن هذا القرار.",
              style: TextStyle(fontSize: 13, color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(context.l10n.factoryReset),
                      content: Text(context.l10n.factoryResetConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(context.l10n.cancel),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(context.l10n.confirm),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await DatabaseHelper.instance.clearAllData();
                    if (context.mounted) {
                      context.read<AppState>().login("1234");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data reset complete.")),
                      );
                    }
                  }
                },
                child: Text(context.l10n.factoryReset),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrinterDialog(BuildContext context, {Printer? printer}) {
    final nameCtrl = TextEditingController(text: printer?.name ?? '');
    final ipCtrl = TextEditingController(text: printer?.ipAddress ?? '');
    final portCtrl = TextEditingController(
      text: printer?.port.toString() ?? '9100',
    );
    bool isReceipt = printer?.isReceipt ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(printer == null ? "Add Printer" : "Edit Printer"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Printer Name (e.g. Kitchen)",
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ipCtrl,
                    decoration: const InputDecoration(labelText: "IP Address"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: portCtrl,
                    decoration: const InputDecoration(labelText: "Port"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text("Main Receipt Printer"),
                    value: isReceipt,
                    onChanged: (v) => setState(() => isReceipt = v),
                  ),
                  const Divider(),
                  const Text(
                    "Routed Categories (Items print here):",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Consumer<AppState>(
                    builder: (context, appState, _) {
                      return Column(
                        children: appState.categories.map((cat) {
                          return CheckboxListTile(
                            title: Text(cat.name),
                            value:
                                printer != null && cat.printerId == printer.id,
                            onChanged: null,
                            subtitle:
                                cat.printerId != null &&
                                    (printer == null ||
                                        cat.printerId != printer.id)
                                ? Text(
                                    "Assigned to another printer",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Note: Manage Category routing in the Category settings for precise control.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && ipCtrl.text.isNotEmpty) {
                    final newPrinter = Printer(
                      id: printer?.id,
                      name: nameCtrl.text,
                      ipAddress: ipCtrl.text,
                      port: int.tryParse(portCtrl.text) ?? 9100,
                      isReceipt: isReceipt,
                    );

                    if (printer == null) {
                      await context.read<AppState>().addPrinter(newPrinter);
                    } else {
                      await context.read<AppState>().updatePrinter(newPrinter);
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Save"),
              ),
              if (printer != null)
                TextButton(
                  onPressed: () async {
                    await context.read<AppState>().deletePrinter(printer.id!);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentDeviceDialog(BuildContext context, {PaymentDevice? device}) {
    final nameCtrl = TextEditingController(text: device?.name ?? '');
    String selectedType = device?.type ?? 'POS';
    String selectedConnectionType = device?.connectionType ?? 'TCP';
    final ipCtrl = TextEditingController(text: device?.ipAddress ?? '');
    final portCtrl = TextEditingController(
      text: device?.port?.toString() ?? '9100',
    );
    final serialCtrl = TextEditingController(text: device?.serialPort ?? '');
    final baudCtrl = TextEditingController(
      text: device?.baudRate?.toString() ?? '9600',
    );
    bool isActive = device?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(device == null ? "إضافة جهاز دفع" : "تعديل جهاز دفع"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "اسم الجهاز"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: "نوع الجهاز"),
                    items: const [
                      DropdownMenuItem(
                        value: 'POS',
                        child: Text('نقطة بيع (POS)'),
                      ),
                      DropdownMenuItem(
                        value: 'CardReader',
                        child: Text('قارئ بطاقات'),
                      ),
                      DropdownMenuItem(
                        value: 'CashDrawer',
                        child: Text('درج نقدي'),
                      ),
                    ],
                    onChanged: (v) => setState(() => selectedType = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedConnectionType,
                    decoration: const InputDecoration(labelText: "نوع الاتصال"),
                    items: const [
                      DropdownMenuItem(value: 'TCP', child: Text('TCP/IP')),
                      DropdownMenuItem(
                        value: 'Serial',
                        child: Text('Serial Port'),
                      ),
                      DropdownMenuItem(value: 'USB', child: Text('USB')),
                    ],
                    onChanged: (v) =>
                        setState(() => selectedConnectionType = v!),
                  ),
                  if (selectedConnectionType == 'TCP') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: ipCtrl,
                      decoration: const InputDecoration(labelText: "عنوان IP"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: portCtrl,
                      decoration: const InputDecoration(labelText: "المنفذ"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  if (selectedConnectionType == 'Serial') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: serialCtrl,
                      decoration: const InputDecoration(
                        labelText: "منفذ Serial (مثال: COM1)",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baudCtrl,
                      decoration: const InputDecoration(
                        labelText: "سرعة Baud Rate",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text("نشط"),
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty) {
                    final newDevice = PaymentDevice(
                      id: device?.id,
                      name: nameCtrl.text,
                      type: selectedType,
                      connectionType: selectedConnectionType,
                      ipAddress: selectedConnectionType == 'TCP'
                          ? ipCtrl.text
                          : null,
                      port: selectedConnectionType == 'TCP'
                          ? int.tryParse(portCtrl.text)
                          : null,
                      serialPort: selectedConnectionType == 'Serial'
                          ? serialCtrl.text
                          : null,
                      baudRate: selectedConnectionType == 'Serial'
                          ? int.tryParse(baudCtrl.text)
                          : null,
                      isActive: isActive,
                    );

                    if (device == null) {
                      await DatabaseHelper.instance.addPaymentDevice(newDevice);
                    } else {
                      await DatabaseHelper.instance.updatePaymentDevice(
                        newDevice,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      this.setState(() {}); // Refresh list
                    }
                  }
                },
                child: const Text("حفظ"),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MoreSettings extends StatefulWidget {
  const _MoreSettings();

  @override
  State<_MoreSettings> createState() => _MoreSettingsState();
}

class _MoreSettingsState extends State<_MoreSettings> {
  String _currentTheme = 'material';
  String _currentLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentTheme = prefs.getString('app_theme') ?? 'material';
      _currentLanguage = prefs.getString('app_language') ?? 'ar';
    });
  }

  Future<void> _setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);
    setState(() {
      _currentLanguage = lang;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'تم تغيير اللغة إلى العربية. أعد تشغيل التطبيق.'
                : 'Language changed to English. Please restart the app.',
          ),
        ),
      );
    }
  }

  Future<void> _setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme', theme);
    setState(() {
      _currentTheme = theme;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تغيير السمة إلى ${_getThemeName(theme)}. أعد تشغيل التطبيق لتطبيق التغييرات.',
          ),
        ),
      );
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'material':
        return 'Material Design';
      case 'ios6':
        return 'iOS 6';
      case 'cupertino':
        return 'Cupertino';
      default:
        return theme;
    }
  }

  Future<void> _resetInvoiceCounter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير ترقيم الفاتورة'),
        content: const Text(
          'هل أنت متأكد من إعادة تصفير ترقيم الفواتير؟ ستبدأ الفواتير من الرقم 1.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تصفير', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('invoice_counter', 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تصفير ترقيم الفواتير. ستبدأ الفاتورة القادمة من INV-00001',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 800;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Preferences (Theme & Language)
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildPreferencesSection(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right: Management & Debug
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildInvoiceManagementCard(context),
                        const SizedBox(height: 16),
                        _buildSettingsInfoNote(context),
                        if (kDebugMode) ...[
                          const SizedBox(height: 16),
                          _buildDebugSection(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreferencesSection(context),
                const Divider(height: 48),
                _buildInvoiceManagementCard(context),
                const SizedBox(height: 24),
                _buildSettingsInfoNote(context),
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  _buildDebugSection(context),
                ],
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفضيلات المظهر واللغة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text(
          'سمة التطبيق / App Theme',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemeCard(
                'material',
                'Material',
                Colors.blue,
                Icons.android,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildThemeCard(
                'ios6',
                'Classic',
                Colors.grey.shade600,
                Icons.phone_iphone,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildThemeCard(
                'cupertino',
                'Modern',
                Colors.blueGrey,
                Icons.apple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'اللغة / Language',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLanguageCard('ar', 'العربية', Icons.language),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLanguageCard('en', 'English', Icons.translate),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInvoiceManagementCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.receipt_long, color: Colors.orange.shade800),
        ),
        title: const Text(
          'تصفير ترقيم الفواتير',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('إعادة بدء العد من الرقم 1'),
        trailing: ElevatedButton(
          onPressed: _resetInvoiceCounter,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('تصفير'),
        ),
      ),
    );
  }

  Widget _buildDebugSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خيارات المطور (Debug)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade100),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.bug_report, color: Colors.white),
            ),
            title: const Text('إضافة بيانات تجريبية'),
            subtitle: const Text('إضافة فئات ومنتجات تجريبية'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.red),
              onPressed: () async {
                final appState = context.read<AppState>();
                await appState.seedTestData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إضافة البيانات التجريبية'),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsInfoNote(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              'يتطلب تغيير السمة أو اللغة إعادة تشغيل التطبيق لتطبيق التغييرات.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String langCode, String name, IconData icon) {
    final isSelected = _currentLanguage == langCode;
    final color = langCode == 'ar' ? Colors.green : Colors.purple;
    return GestureDetector(
      onTap: () => _setLanguage(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
                fontSize: 16,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    String themeId,
    String name,
    Color color,
    IconData icon,
  ) {
    final isSelected = _currentTheme == themeId;
    return GestureDetector(
      onTap: () => _setTheme(themeId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(Icons.check_circle, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Inventory Module UI ---

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المخزن والمشتريات'), // Inventory & Purchasing
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.receipt_long),
                text: 'فاتورة المشتريات',
              ), // Purchase Invoices
              Tab(
                icon: Icon(Icons.inventory_2),
                text: 'المكونات (الأصناف)',
              ), // Ingredients/Items
            ],
          ),
        ),
        body: const TabBarView(children: [PurchaseInvoicesTab(), ItemsTab()]),
      ),
    );
  }
}

class PurchaseInvoicesTab extends StatefulWidget {
  const PurchaseInvoicesTab({super.key});

  @override
  State<PurchaseInvoicesTab> createState() => _PurchaseInvoicesTabState();
}

class _PurchaseInvoicesTabState extends State<PurchaseInvoicesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePurchaseInvoiceScreen(),
            ),
          );
          setState(() {}); // Refresh list after returning
        },
        label: const Text('فاتورة جديدة'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getInvoicesWithSuppliers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد فواتير مشتريات',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          final invoices = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final inv = invoices[index];
              final date =
                  DateTime.tryParse(inv['date'] ?? '') ?? DateTime.now();
              final formattedDate = DateFormat('yyyy/MM/dd').format(date);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt, color: Colors.blue),
                  ),
                  title: Text(
                    'فاتورة #${inv['invoiceNumber'] ?? inv['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('المورد: ${inv['supplierName'] ?? 'غير محدد'}'),
                      Text('التاريخ: $formattedDate'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(inv['total'] as num).toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'الإجمالي',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PurchaseInvoiceDetailsScreen(invoiceId: inv['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getInvoicesWithSuppliers() async {
    final db = DatabaseHelper.instance;
    return await db.rawQuery('''
      SELECT pi.*, s.name as supplierName
      FROM purchase_invoices pi
      LEFT JOIN suppliers s ON pi.supplierId = s.id
      ORDER BY pi.date DESC
    ''');
  }
}

// --- Purchase Invoice Details Screen ---
class PurchaseInvoiceDetailsScreen extends StatelessWidget {
  final int invoiceId;

  const PurchaseInvoiceDetailsScreen({super.key, required this.invoiceId});

  Future<Map<String, dynamic>> _getInvoiceDetails() async {
    final db = DatabaseHelper.instance;

    // Get invoice with supplier
    final invoiceResult = await db.rawQuery(
      '''
      SELECT pi.*, s.name as supplierName
      FROM purchase_invoices pi
      LEFT JOIN suppliers s ON pi.supplierId = s.id
      WHERE pi.id = ?
    ''',
      [invoiceId],
    );

    // Get invoice items with ingredient names
    final items = await db.rawQuery(
      '''
      SELECT pii.*, i.name as ingredientName, i.unit as ingredientUnit
      FROM purchase_invoice_items pii
      LEFT JOIN ingredients i ON pii.itemId = i.id
      WHERE pii.invoiceId = ?
    ''',
      [invoiceId],
    );

    return {
      'invoice': invoiceResult.isNotEmpty ? invoiceResult.first : null,
      'items': items,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فاتورة #$invoiceId')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getInvoiceDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!['invoice'] == null) {
            return const Center(child: Text('لم يتم العثور على الفاتورة'));
          }

          final invoice = snapshot.data!['invoice'] as Map<String, dynamic>;
          final items = snapshot.data!['items'] as List<Map<String, dynamic>>;
          final date =
              DateTime.tryParse(invoice['date'] ?? '') ?? DateTime.now();
          final formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(date);

          return Column(
            children: [
              // Invoice Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فاتورة #${invoice['invoiceNumber'] ?? invoice['id']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المورد: ${invoice['supplierName'] ?? 'غير محدد'}',
                            ),
                            Text('التاريخ: $formattedDate'),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'الإجمالي',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                '${(invoice['total'] as num).toStringAsFixed(2)} ر.س',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (invoice['notes'] != null &&
                        invoice['notes'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('ملاحظات: ${invoice['notes']}'),
                    ],
                  ],
                ),
              ),

              // Items Header
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[200],
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'المكون',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'الكمية',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'السعر',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'الإجمالي',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final qty = (item['qtyTotal'] as num).toDouble();
                    final cost = (item['costPrice'] as num).toDouble();
                    final total = qty * cost;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['ingredientName'] ??
                                  'مكون #${item['itemId']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${qty.toStringAsFixed(1)} ${item['ingredientUnit'] ?? item['unit'] ?? ''}',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${cost.toStringAsFixed(2)} ر.س'),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${total.toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final ingredients = appState.ingredients;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIngredientDialog(context),
        label: const Text('مكون جديد'),
        icon: const Icon(Icons.add),
      ),
      body: ingredients.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد مكونات',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اضغط على + لإضافة مكون جديد',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                final isLowStock =
                    ingredient.currentStock <= ingredient.minStock;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isLowStock
                        ? const BorderSide(color: Colors.red, width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLowStock ? Icons.warning : Icons.inventory_2,
                        color: isLowStock ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      ingredient.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTag(
                              'المخزون: ${ingredient.currentStock.toStringAsFixed(1)} ${ingredient.unit ?? ''}',
                              isLowStock ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            _buildTag(
                              'الحد الأدنى: ${ingredient.minStock.toStringAsFixed(1)}',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ingredient.costPrice.toStringAsFixed(2)} ر.س',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'سعر التكلفة',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showIngredientDialog(context, ingredient: ingredient),
                    onLongPress: () => _confirmDelete(context, ingredient),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  void _showIngredientDialog(BuildContext context, {Ingredient? ingredient}) {
    final nameController = TextEditingController(text: ingredient?.name ?? '');
    final unitController = TextEditingController(text: ingredient?.unit ?? '');
    final stockController = TextEditingController(
      text: ingredient?.currentStock.toString() ?? '0',
    );
    final minStockController = TextEditingController(
      text: ingredient?.minStock.toString() ?? '0',
    );
    final costController = TextEditingController(
      text: ingredient?.costPrice.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          ingredient == null ? 'إضافة مكون جديد' : 'تعديل ${ingredient.name}',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المكون *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'الوحدة (مثال: كجم، لتر، قطعة)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'المخزون الحالي',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minStockController,
                decoration: const InputDecoration(
                  labelText: 'الحد الأدنى للمخزون',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'سعر التكلفة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              final appState = context.read<AppState>();
              final newIngredient = Ingredient(
                id: ingredient?.id,
                name: nameController.text,
                unit: unitController.text.isNotEmpty
                    ? unitController.text
                    : null,
                currentStock: double.tryParse(stockController.text) ?? 0,
                minStock: double.tryParse(minStockController.text) ?? 0,
                costPrice: double.tryParse(costController.text) ?? 0,
              );

              if (ingredient == null) {
                await appState.addIngredient(newIngredient);
              } else {
                await appState.updateIngredient(newIngredient);
              }

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المكون'),
        content: Text('هل أنت متأكد من حذف "${ingredient.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<AppState>().deleteIngredient(ingredient.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class CreatePurchaseInvoiceScreen extends StatefulWidget {
  const CreatePurchaseInvoiceScreen({super.key});

  @override
  State<CreatePurchaseInvoiceScreen> createState() =>
      _CreatePurchaseInvoiceScreenState();
}

class _CreatePurchaseInvoiceScreenState
    extends State<CreatePurchaseInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoiceNoController = TextEditingController();

  int? _selectedSupplierId;
  DateTime _selectedDate = DateTime.now();

  // Temporary list to hold UI state before creating the model items
  List<Map<String, dynamic>> _uiItems = [];

  @override
  Widget build(BuildContext context) {
    // We need suppliers list
    return Scaffold(
      appBar: AppBar(title: const Text('فاتورة مشتريات جديدة')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildItemsList()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceNoController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الفاتورة',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDate: _selectedDate,
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'التاريخ'),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Supplier Dropdown (Would need to fetch suppliers)
            _buildSupplierDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.queryAll('suppliers'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final suppliers = snapshot.data!
            .map((e) => Supplier.fromMap(e))
            .toList();
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedSupplierId,
                items: suppliers
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedSupplierId = val),
                decoration: const InputDecoration(labelText: 'المورد'),
                validator: (val) => val == null ? 'مطلوب' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddSupplierDialog();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemsList() {
    // List of added items
    return ListView.separated(
      itemCount: _uiItems.length + 1, // +1 for "Add Item" row
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        if (index == _uiItems.length) {
          return ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.green),
            title: const Text('إضافة صنف للفاتورة'),
            onTap: _showAddItemDialog,
          );
        }
        final item = _uiItems[index];
        return ListTile(
          title: Text(item['itemName'] ?? 'Unknown'),
          subtitle: Text(
            '${item['unitsCount']} ${item['unit']} x ${item['costPrice']}',
          ),
          trailing: Text(
            (item['qtyTotal'] * item['costPrice']).toStringAsFixed(2),
          ),
          onLongPress: () {
            setState(() => _uiItems.removeAt(index));
          },
        );
      },
    );
  }

  Widget _buildFooter() {
    double total = _uiItems.fold(
      0,
      (sum, item) => sum + (item['qtyTotal'] * item['costPrice']),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الإجمالي: ${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: _saveInvoice,
            child: const Text('حفظ الفاتورة'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    // Shows dialog to select ingredient, unit, qty, cost
    final appState = context.read<AppState>();
    Ingredient? selectedIngredient;
    final qtyController = TextEditingController(text: '1');
    final costController = TextEditingController();
    final unitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مكون للفاتورة'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Ingredient>(
                    items: appState.ingredients
                        .map(
                          (i) =>
                              DropdownMenuItem(value: i, child: Text(i.name)),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedIngredient = val;
                        costController.text = val?.costPrice.toString() ?? '';
                        unitController.text = val?.unit ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'المكون',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    decoration: const InputDecoration(
                      labelText: 'سعر التكلفة (للوحدة)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedIngredient != null) {
                this.setState(() {
                  _uiItems.add({
                    'itemId': selectedIngredient!.id,
                    'itemName': selectedIngredient!.name,
                    'unitsCount': double.tryParse(qtyController.text) ?? 1,
                    'qtyTotal': double.tryParse(qtyController.text) ?? 1,
                    'costPrice': double.tryParse(costController.text) ?? 0,
                    'unit': unitController.text.isNotEmpty
                        ? unitController.text
                        : 'وحدة',
                    'isIngredient': true, // Flag to identify as ingredient
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مورد'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'اسم المورد'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await DatabaseHelper.instance.insert(
                  'suppliers',
                  Supplier(
                    name: nameController.text,
                    createdAt: DateTime.now().toString(),
                  ).toMap(),
                );
                setState(() {}); // Refresh dropdown
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _uiItems.isEmpty) return;

    try {
      final invoice = PurchaseInvoice(
        invoiceNumber: _invoiceNoController.text,
        supplierId: _selectedSupplierId, // Allow null supplier
        date: _selectedDate.toIso8601String(),
        total: _uiItems.fold(
          0,
          (sum, item) => sum + (item['qtyTotal'] * item['costPrice']),
        ),
        createdAt: DateTime.now().toString(),
      );

      final db = DatabaseHelper.instance;
      final invoiceId = await db.insert('purchase_invoices', invoice.toMap());

      for (var item in _uiItems) {
        // Insert Item
        final invItem = PurchaseInvoiceItem(
          invoiceId: invoiceId,
          itemId: item['itemId'],
          qtyTotal: item['qtyTotal'],
          costPrice: item['costPrice'],
          unitsCount: item['unitsCount'],
          unit: item['unit'],
          sellingPrice: item['sellingPrice'] ?? 0.0,
          expiryDate: item['expiryDate'],
        );
        final invItemId = await db.insert(
          'purchase_invoice_items',
          invItem.toMap(),
        );

        // Insert Stock Batch
        final batch = StockBatch(
          itemId: item['itemId'],
          qty: item['qtyTotal'],
          originalQty: item['qtyTotal'],
          costPrice: item['costPrice'],
          purchaseInvoiceItemId: invItemId,
          receivedDate: DateTime.now().toIso8601String(),
        );
        await db.insert('stock_batches', batch.toMap());

        // Update Ingredient Stock
        await db.rawUpdate(
          'UPDATE ingredients SET currentStock = currentStock + ? WHERE id = ?',
          [item['qtyTotal'], item['itemId']],
        );
      }

      // Refresh ingredients in app state
      if (mounted) {
        context.read<AppState>().refreshIngredients();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ فاتورة المشتريات بنجاح')),
        );
      }
    } catch (e) {
      debugPrint('Error saving invoice: $e');
    }
  }
}

// --- Expenses Module UI ---

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _expenseDateFilter = '';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  late List<String> _categories;
  late String _selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categories = [
      context.l10n.allCategories,
      context.l10n.rent,
      context.l10n.electricity,
      context.l10n.water,
      context.l10n.salaries,
      context.l10n.maintenance,
      context.l10n.marketing,
      context.l10n.others,
    ];
    _selectedCategory = context.l10n.allCategories;
  }

  @override
  void initState() {
    super.initState();
    _expenseDateFilter =
        'week'; // Use a key to track state, or init in didChangeDependencies if localized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set initial filter text if needed, effectively handled by defaults
      _loadData();
    });
  }

  void _loadData() {
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    context.read<AppState>().loadExpenses(
      _startDate,
      end,
      category: _selectedCategory == context.l10n.allCategories
          ? null
          : _selectedCategory,
    );
  }

  void _setDateRange(String range) {
    final now = DateTime.now();
    setState(() {
      _expenseDateFilter = range;
      switch (range) {
        case 'اليوم':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'أسبوع':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 'شهر':
          _startDate = DateTime(now.year, now.month - 1, now.day);
          _endDate = now;
          break;
        case 'ثلاثة أشهر':
          _startDate = now.subtract(const Duration(days: 90));
          _endDate = now;
          break;
      }
    });
    _loadData();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFEF4444)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _expenseDateFilter = context.l10n.custom;
      });
      _loadData();
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return ChoiceChip(
            label: Text(category),
            selected: _selectedCategory == category,
            selectedColor: const Color(0xFFEF4444),
            labelStyle: TextStyle(
              color: _selectedCategory == category
                  ? Colors.white
                  : Colors.black,
            ),
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
              _loadData();
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(List<Expense> expenses) {
    final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final average = expenses.isNotEmpty ? total / expenses.length : 0;
    final maxExpense = expenses.isNotEmpty
        ? expenses.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context.l10n.total,
                '\$${total.toStringAsFixed(2)}',
              ),
              _buildStatItem(
                context.l10n.avg,
                '\$${average.toStringAsFixed(2)}',
              ),
              _buildStatItem(context.l10n.count, expenses.length.toString()),
            ],
          ),
          const SizedBox(height: 12),
          if (maxExpense != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${context.l10n.highestExpense}: ${maxExpense.title} - \$${maxExpense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<Expense> expenses) {
    final categoryMap = <String, double>{};

    for (final expense in expenses) {
      final category = expense.category ?? context.l10n.uncategorized;
      categoryMap.update(
        category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final chartData = categoryMap.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCircularChart(
        margin: EdgeInsets.zero,
        series: <CircularSeries>[
          DoughnutSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.amount,
            dataLabelMapper: (ChartData data, _) =>
                '\$${data.amount.toStringAsFixed(0)}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
            radius: '80%',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          context.l10n.expenses,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF475569),
            ),
            tooltip: context.l10n.filter,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return _buildFilterSheet();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final expenses = appState.expenses;
          final isLoading = appState.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildFilterChips(),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildStatsCard(expenses),
                            const SizedBox(height: 16),
                            if (expenses.isNotEmpty) _buildChart(expenses),
                            const SizedBox(height: 16),
                            if (expenses.isEmpty) _buildEmptyState(),
                          ],
                        ),
                      ),
                      if (expenses.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final expense = expenses[index];
                              return _buildExpenseItem(expense, context);
                            }, childCount: expenses.length),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          ).then((saved) {
            if (saved == true) _loadData();
          });
        },
        label: Text(context.l10n.addExpense),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFEF4444),
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.filterExpenses,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.timePeriod,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(context.l10n.daily, 'daily'),
              _buildFilterChip(context.l10n.weekly, 'weekly'),
              _buildFilterChip(context.l10n.monthly, 'monthly'),
              _buildFilterChip(context.l10n.threeMonths, 'three_months'),
              _buildFilterChip(context.l10n.custom, 'custom'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.expenseCategory,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
              _loadData();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.l10n.applyFilter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _expenseDateFilter == value,
      selectedColor: const Color(0xFFEF4444),
      onSelected: (selected) {
        if (value == 'custom') {
          _pickDateRange();
        } else {
          _setDateRange(value);
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildExpenseItem(Expense expense, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editExpense(context, expense),
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: context.l10n.edit,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (context) => _confirmDelete(context, expense),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: context.l10n.delete,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'yyyy/MM/dd - HH:mm',
                ).format(DateTime.parse(expense.date)),
                style: const TextStyle(fontSize: 12),
              ),
              if (expense.notes != null && expense.notes!.isNotEmpty)
                Text(
                  expense.notes!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFEF4444),
                ),
              ),
              if (expense.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(expense.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.category!,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(expense.category),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'لا توجد مصروفات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اضغط على زر + لإضافة مصروف جديد',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'إيجار':
        return const Color(0xFF3B82F6);
      case 'كهرباء':
        return const Color(0xFFF59E0B);
      case 'ماء':
        return const Color(0xFF10B981);
      case 'رواتب':
        return const Color(0xFF8B5CF6);
      case 'صيانة':
        return const Color(0xFFEF4444);
      case 'تسويق':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'إيجار':
        return Icons.home;
      case 'كهرباء':
        return Icons.bolt;
      case 'ماء':
        return Icons.water_drop;
      case 'رواتب':
        return Icons.people;
      case 'صيانة':
        return Icons.build;
      case 'تسويق':
        return Icons.public;
      default:
        return Icons.category;
    }
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expenseToEdit: expense),
      ),
    ).then((saved) {
      if (saved == true) _loadData();
    });
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المصروف'),
        content: Text('هل أنت متأكد من حذف "${expense.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteExpense(expense.id!);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم حذف المصروف بنجاح'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.amount);
  final String category;
  final double amount;
}

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;
  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _category;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'إيجار', 'icon': Icons.home, 'color': Color(0xFF3B82F6)},
    {'name': 'كهرباء', 'icon': Icons.bolt, 'color': Color(0xFFF59E0B)},
    {'name': 'ماء', 'icon': Icons.water_drop, 'color': Color(0xFF10B981)},
    {'name': 'رواتب', 'icon': Icons.people, 'color': Color(0xFF8B5CF6)},
    {'name': 'صيانة', 'icon': Icons.build, 'color': Color(0xFFEF4444)},
    {'name': 'تسويق', 'icon': Icons.public, 'color': Color(0xFFEC4899)},
    {'name': 'أخرى', 'icon': Icons.category, 'color': Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _notesController.text = widget.expenseToEdit!.notes ?? '';
      final date = DateTime.parse(widget.expenseToEdit!.date);
      _selectedDate = date;
      _selectedTime = TimeOfDay.fromDateTime(date);
      _category = widget.expenseToEdit!.category;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final expense = Expense(
      id: widget.expenseToEdit?.id,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: dateTime.toIso8601String(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      category: _category,
    );

    try {
      if (widget.expenseToEdit == null) {
        await context.read<AppState>().addExpense(expense);
      } else {
        await context.read<AppState>().updateExpense(expense);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.error}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFEF4444)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFEF4444)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expenseToEdit == null
              ? context.l10n.addNewExpense
              : context.l10n.editExpense,
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          if (widget.expenseToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // بطاقة المبلغ
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.l10n.amount,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF4444),
                          ),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            prefix: Text('\$'),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return context.l10n.requiredField;
                            }
                            final parsed = double.tryParse(val);
                            if (parsed == null || parsed <= 0) {
                              return context.l10n.requiredFieldZero;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  // التصنيفات
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      context.l10n.expenseCategory,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _category == cat['name'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _category = cat['name'] as String),
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cat['color'] as Color
                                  : (cat['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: cat['color'] as Color,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : cat['color'] as Color,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat['name'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white
                                        : cat['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // العنوان
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: context.l10n.expenseTitle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? context.l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // التاريخ والوقت
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[50],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat(
                                    'yyyy/MM/dd',
                                  ).format(_selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[50],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // الملاحظات
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isLoading
                            ? 'جاري الحفظ...'
                            : widget.expenseToEdit == null
                            ? 'حفظ المصروف'
                            : 'تحديث المصروف',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المصروف'),
        content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteExpense(widget.expenseToEdit!.id!);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _ExpensesReportTab extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _ExpensesReportTab({required this.startDate, required this.endDate});

  @override
  State<_ExpensesReportTab> createState() => _ExpensesReportTabState();
}

class _ExpensesReportTabState extends State<_ExpensesReportTab> {
  Future<Map<String, dynamic>> _fetchExpenses() async {
    final db = DatabaseHelper.instance;
    final startStr = widget.startDate.toIso8601String();
    final endStr = widget.endDate
        .copyWith(hour: 23, minute: 59)
        .toIso8601String();

    final expenses = await db.rawQuery(
      'SELECT * FROM expenses WHERE date BETWEEN ? AND ? ORDER BY date DESC',
      [startStr, endStr],
    );

    double totalAmount = 0;
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      final amount = (expense['amount'] as num).toDouble();
      final category = expense['category'] as String;
      totalAmount += amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    final categoryData = categoryTotals.entries
        .map((e) => {'category': e.key, 'total': e.value})
        .toList();

    // Sort categories by total descending
    categoryData.sort(
      (a, b) => (b['total'] as double).compareTo(a['total'] as double),
    );

    return {
      'expenses': expenses,
      'totalAmount': totalAmount,
      'count': expenses.length,
      'categoryData': categoryData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchExpenses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final expenses = data['expenses'] as List<Map<String, dynamic>>;
        final totalAmount = data['totalAmount'] as double;
        final count = data['count'] as int;
        final categoryData = data['categoryData'] as List<Map<String, dynamic>>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ملخص البطاقات
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      context.l10n.totalExpenses,
                      '${totalAmount.toStringAsFixed(2)} دينار',
                      Icons.money_off,
                      const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      context.l10n.expensesCount,
                      '$count',
                      Icons.receipt_long,
                      const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (categoryData.isNotEmpty) ...[
                // رسم بياني حسب الفئة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.expensesDistribution,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: SfCircularChart(
                          legend: Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            position: LegendPosition.right,
                          ),
                          series: <CircularSeries>[
                            PieSeries<Map<String, dynamic>, String>(
                              dataSource: categoryData,
                              xValueMapper: (Map<String, dynamic> data, _) =>
                                  data['category'],
                              yValueMapper: (Map<String, dynamic> data, _) =>
                                  data['total'],
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                              ),
                              enableTooltip: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // قائمة المصروفات
              Text(
                context.l10n.expensesLog,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              if (expenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(context.l10n.noExpensesFound),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(
                            0xFFEF4444,
                          ).withOpacity(0.1),
                          child: const Icon(
                            Icons.money_off,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        title: Text(
                          expense['category'] ?? context.l10n.uncategorized,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (expense['note'] != null &&
                                expense['note'].toString().isNotEmpty)
                              Text(expense['note']),
                            Text(
                              expense['date'].toString().substring(0, 16),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${(expense['amount'] as num).toStringAsFixed(2)} دينار',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SyncSettings extends StatefulWidget {
  const SyncSettings({Key? key}) : super(key: key);

  @override
  State<SyncSettings> createState() => _SyncSettingsState();
}

class _SyncSettingsState extends State<SyncSettings> {
  final _syncService = FirestoreSyncService();
  bool _isSyncing = false;
  double _progress = 0.0;
  String _status = "Ready to sync";
  String _lastSyncDetail = "";

  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _status = "Starting sync...";
      _lastSyncDetail = "";
    });

    try {
      final results = await _syncService.syncAll(
        onProgress: (table, progress) {
          if (mounted) {
            setState(() {
              _status = "Syncing $table...";
              _progress = progress;
            });
          }
        },
      );

      if (mounted) {
        int total = 0;
        int errors = 0;
        final details = StringBuffer();

        results.forEach((table, count) {
          if (count >= 0) {
            total += count;
            if (count > 0) details.writeln("$table: $count items");
          } else {
            errors++;
            details.writeln("$table: Error");
          }
        });

        setState(() {
          _isSyncing = false;
          _progress = 1.0;
          _status = errors > 0
              ? "Completed with $errors errors. Uploaded $total items."
              : "Sync Completed! Uploaded $total items.";
          _lastSyncDetail = details.toString();
        });

        if (errors == 0) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Sync Successful ✅")));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _status = "Error: $e";
        });
      }
    }
  }

  Future<void> _importData(String table, String label) async {
    final l10n = context.l10n;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.importOptions),
        content: Text(l10n.importModeDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, false), // Append
            child: Text(l10n.appendLocalData),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), // Overwrite
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.overwriteLocalData),
          ),
        ],
      ),
    );

    if (result == null) return; // User cancelled

    setState(() {
      _isSyncing = true;
      _progress = 0.0;
      _status = "Importing $label...";
      _lastSyncDetail = "";
    });

    try {
      final count = await _syncService.importTable(table, clearFirst: result);
      // Refresh AppState data if needed
      if (mounted) {
        final appState = context.read<AppState>();
        if (table == 'products') await appState.refreshProducts();
        if (table == 'categories') await appState.refreshCategories();
        if (table == 'ingredients') await appState.refreshIngredients();
        if (table == 'addons') await appState.refreshProducts();

        setState(() {
          _isSyncing = false;
          _progress = 1.0;
          _status = "Imported $count $label items successfully";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Imported $count $label ✅")));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _status = "Error importing $label: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // نستخدم LayoutBuilder لتحديد إذا كنا على جهاز لوحي عريض أم هاتف
    return LayoutBuilder(
      builder: (context, constraints) {
        // نعتبر الجهاز "لوحي" إذا كان العرض أكبر من 700 بيكسل
        final isTablet = constraints.maxWidth > 700;

        if (isTablet) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === الجانب الأيسر: للتفاعل (Action Side) ===
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildActionSection(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // === الجانب الأيمن: للتوضيح والحالة (Info Side) ===
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      _buildStatusSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // === تصميم الموبايل (الوضع العمودي القديم) ===
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  if (_isSyncing) ...[
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 8),
                    Text(
                      "${(_progress * 100).toInt()}% - $_status",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildActionSection(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // --- Helper Widgets to keep code clean ---

  Widget _buildHeaderCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.cloud_upload, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              "Cloud Sync / المزامنة السحابية",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Upload local data to Firebase Firestore for backup and remote access.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isSyncing) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            "${(_progress * 100).toInt()}% - $_status",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _status.contains("Error")
                          ? Icons.error_outline
                          : Icons.info_outline,
                      color: _status.contains("Error")
                          ? Colors.red
                          : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Status: $_status",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _status.contains("Error")
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_lastSyncDetail.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    "Details:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _lastSyncDetail,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Upload Section
        const Text(
          "Local -> Cloud (Upload)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isSyncing ? null : _startSync,
          icon: const Icon(Icons.cloud_upload),
          label: const Text("Start Upload / بدء الرفع"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Divider(),
        ),

        // Import Section
        const Text(
          "Cloud -> Local (Import)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        // نستخدم Wrap ليقوم بترتيب الأزرار بشكل تلقائي
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: [
            _buildImportButton("Products", "products"),
            _buildImportButton("Categories", "categories"),
            _buildImportButton("Ingredients", "ingredients"),
            _buildImportButton("Addons", "addons"),
          ],
        ),
      ],
    );
  }

  Widget _buildImportButton(String label, String table) {
    return SizedBox(
      width: 140, // عرض ثابت مناسب للأزرار
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : () => _importData(table, label),
        icon: const Icon(Icons.cloud_download, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade50,
          foregroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
