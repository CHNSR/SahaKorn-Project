import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:sahakorn3/src/screens/user/shop/setting/myqrcode/my_qr_code.dart';
import 'package:sahakorn3/src/screens/user/customer/screens/search_shop.dart';

class Routes {
  static const String root = '/';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';

  // Roles & Intermediary
  static const String selectRole = '/select_role';
  static const String intermediary = '/intermediary';

  // Customer Routes
  static const String customerHome = '/customer_home';
  static const String createCustomerProfile = '/create_customer_profile';
  static const String customerShop = '/customer_shop';
  static const String customerCredit = '/customer_credit';
  static const String customerSetting = '/customer_setting';
  static const String customerPay = '/customer_pay';
  static const String searchShop = '/search_shop';

  // Shop Routes
  static const String shopHome = '/shop_home';
  static const String createShop = '/create_shop';
  static const String shopTransaction = '/shop_transaction';
  static const String shopLoan = '/shop_loan';
  static const String shopSetting = '/shop_setting';
  static const String shopQrGenerate = '/shop_qr_generate';

  // Shop Settings Layer 2
  static const String editShopProfile = '/edit_shop_profile';
  static const String editPersonalProfile = '/edit_personal_profile';
  static const String changePassword = '/change_password';
  static const String switchShop = '/switch_shop';
  static const String helpSupport = '/help_support';
  static const String myQrCode = '/my_qr_code';

  // Loan Management
  static const String giveLoan = '/give_loan';
  static const String customers = '/customers';
  static const String repayment = '/repayment';
  static const String history = '/history';
  static const String manageTotalCredit = '/manage_total_credit';

  // Feature Screens
  static const String notification = '/notification';
  static const String advanceSearch = '/advance_search';
  static const String configTransaction = '/config_transaction';
  static const String digitalReceipt = '/digital_receipt';
  static const String exportTransaction = '/export_transaction';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      root: (context) => const AuthGate(),

      // Auth
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),

      // Roles
      selectRole: (context) => const SelectRole(),
      intermediary: (context) => const SelectRole(),

      // Customer
      customerHome: (context) => const NavbarCustomer(),
      createCustomerProfile: (context) => const EditProfileScreen(),
      searchShop: (context) => const SearchShopScreen(),

      // Shop
      shopHome: (context) => const NavbarShop(),
      createShop: (context) => const CreateShopScreen(),
      shopQrGenerate: (context) => const ShopQrGeneratePage(),
      myQrCode: (context) => const MyQrCodeScreen(),

      // Shop Settings Layer 2
      editShopProfile: (context) => const EditShopProfileScreen(),
      editPersonalProfile: (context) => const EditPersonalProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      switchShop: (context) => const SwitchShopScreen(),
      helpSupport: (context) => const HelpSupportScreen(),

      // Loan Management
      giveLoan: (context) => const GiveLoanUserScreen(),
      customers: (context) => const CustomersScreen(),
      repayment: (context) => const RepaymentScreen(),
      history: (context) => const HistoryScreen(),
      manageTotalCredit: (context) => const ManageTotalCredit(),

      // Features
      notification: (context) => const NotificationScreen(),
      digitalReceipt: (context) => const DigitalReceipt(),
      // exportTransaction is handled in getRoutes if no args, but can also be in onGenerateRoute if needed.
      // Since it has an optional argument, we can leave it here for default case.
      exportTransaction: (context) => const ExportTransaction(),

      // Note: ConfigTransaction and AdvanceSearch are handled in onGenerateRoute
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case customerShop:
        final shop = settings.arguments as Shop;
        return MaterialPageRoute(
          builder: (_) => CustomerShop(shop: shop),
          settings: settings,
        );

      case configTransaction:
        final transaction = settings.arguments as AppTransaction;
        return MaterialPageRoute(
          builder: (_) => ConfigTransaction(transaction: transaction),
          settings: settings,
        );

      case advanceSearch:
        final repository = settings.arguments as TransactionRepository;
        return MaterialPageRoute(
          builder: (_) => AdvanceSearch(repository: repository),
          settings: settings,
        );

      case exportTransaction:
        // Handle case where repository might be passed
        if (settings.arguments is TransactionRepository) {
          final repository = settings.arguments as TransactionRepository;
          return MaterialPageRoute(
            builder: (_) => ExportTransaction(repository: repository),
            settings: settings,
          );
        }
        // Fallback to default route defined in getRoutes if no arg or wrong arg
        return null;

      default:
        // By returning null, we let MaterialApp use the 'routes' map (getRoutes)
        return null;
    }
  }
}
