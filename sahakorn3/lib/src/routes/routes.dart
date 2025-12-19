import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';

class Routes {
  static const String root = '/';
  static const String createShop = '/create_shop';
  static const String createCustomerProfile = '/create_customer_profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/customer_home';
  static const String shopHome = '/shop_home';
  static const String intermediary = '/intermediary';
  static const String notification = '/notification';
  static const String selectRole = '/select_role';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      root: (context) => const AuthGate(),
      createShop: (context) => const CreateShopScreen(),
      createCustomerProfile: (context) => const CreateCustomerScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      customerHome: (context) => const NavbarCustomer(),
      shopHome: (context) => const NavbarShop(),
      intermediary: (context) => const SelectRole(),
      notification: (context) => const NotificationScreen(),
      selectRole: (context) => const SelectRole(),
    };
  }
}
