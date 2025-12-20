import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:sahakorn3/src/screens/user/customer/screens_layer2/editscreen.dart';

class Routes {
  static const String root = '/';
  static const String createShop = '/create_shop';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/customer_home';
  static const String shopHome = '/shop_home';
  static const String intermediary = '/intermediary';
  static const String notification = '/notification';
  static const String selectRole = '/select_role';
  static const String createCustomerProfile = '/create_customer_profile';
  static const String giveLoan = '/give_loan';
  static const String customers = '/customers';
  static const String repayment = '/repayment';
  static const String history = '/history';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      root: (context) => const AuthGate(),
      createCustomerProfile: (context) => const EditProfileScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      customerHome: (context) => const NavbarCustomer(),
      shopHome: (context) => const NavbarShop(),
      intermediary: (context) => const SelectRole(),
      notification: (context) => const NotificationScreen(),
      selectRole: (context) => const SelectRole(),
      giveLoan: (context) => const GiveLoanScreen(),
      customers: (context) => const CustomersScreen(),
      repayment: (context) => const RepaymentScreen(),
      history: (context) => const HistoryScreen(),
    };
  }
}
