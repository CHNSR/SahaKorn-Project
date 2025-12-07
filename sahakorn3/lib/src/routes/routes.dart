import 'package:flutter/material.dart';
import 'package:sahakorn3/src/screens/create/create_customer.dart';
import 'package:sahakorn3/src/screens/create/create_shop.dart';
import 'package:sahakorn3/src/screens/root.dart';

class Routes {
  static const String root = '/';
  static const String createShop = '/create_shop';
  static const String createCustomerProfile = '/create_customer_profile';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      root: (context) => const Root(),
      createShop: (context) => const CreateShopScreen(),
      createCustomerProfile: (context) => const CreateCustomerScreen(),
    };
  }
}
