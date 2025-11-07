import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/screens/customer/customer_home.dart';
import 'package:sahakorn3/src/screens/customer/customer_transaction.dart';
import 'package:sahakorn3/src/screens/customer/customer_credit.dart';
import 'package:sahakorn3/src/screens/customer/customer_setting.dart';
import 'package:sahakorn3/src/screens/customer/customer_pay.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:sahakorn3/src/screens/intermediary/intermediary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahakorn3/src/widgets/shop_navbar.dart';

class NavbarCustomer extends StatefulWidget {
  const NavbarCustomer({super.key});

  @override
  State<NavbarCustomer> createState() => _NavbarCustomerState();
}

class _NavbarCustomerState extends State<NavbarCustomer> {
  int selected = 0;
  bool paying = false;
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            "assets/icon/sahakorn_no_blackground.png",
            height: 50,
            width: 50,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              // allow developer to open intermediary screen manually
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IntermediaryScreen()));
            },
            child: const Text(
              "SahaKorn Project",
              style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
              ),
            ),
          ),
        ],
          ),
          backgroundColor: const Color(0xFF34495e),
          elevation: 4,
          actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            // Handle notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.change_circle_outlined, color: Colors.white),
          onPressed: () async {
            // Toggle stored user role and navigate with an animated replacement.
            final prefs = await SharedPreferences.getInstance();
            final role = prefs.getString('user_role');
            Widget target;
            if (role == 'customer') {
              await prefs.setString('user_role', 'shop');
              target = const NavbarShop();
            } else {
              await prefs.setString('user_role', 'customer');
              target = const NavbarCustomer();
            }

            Navigator.of(context).pushReplacement(PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 380),
              pageBuilder: (context, animation, secondaryAnimation) => target,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                final slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(fade);
                return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
              },
            ));
          },
        ),
          ],
        ),
      ),
      
      extendBody: true,
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: const Color(0xFF34495e),
        option: AnimatedBarOptions(
          iconStyle: IconStyle.Default,
          ),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            selectedColor: Color(0xFFCCFF00),
            unSelectedColor: Colors.white,
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            badge: const Text(''),
            showBadge: false,
          ),
          BottomBarItem(
            icon: const Icon(Icons.swap_horiz),
            selectedIcon: const Icon(Icons.swap_horiz),
            selectedColor: Color(0xFFCCFF00),
            unSelectedColor: Colors.white,
            title: const Text('Transactions', style: TextStyle(color: Colors.white)),
          ),
          BottomBarItem(
            icon: const Icon(Icons.credit_card_outlined),
            selectedIcon: const Icon(Icons.credit_card),
            selectedColor: Color(0xFFCCFF00),
            unSelectedColor: Colors.white,
            title: const Text('Credit', style: TextStyle(color: Colors.white)),
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            selectedColor: Color(0xFFCCFF00),
            unSelectedColor: Colors.white,
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: selected,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          if (index == selected) return;
          controller.jumpToPage(index);
          setState(() {
            selected = index;
          });
        },
      ),

      //creadit buttom
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CustomerPay()),
          );
          setState(() {
            paying = !paying;
          });
        },
        backgroundColor: const Color(0xFFCCFF00),
        child: Icon(
          paying ? CupertinoIcons.money_dollar : CupertinoIcons.money_dollar,
          color: Colors.black,
        ),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: const [
            CustomerHome(),
            CustomerTransaction(),
            CustomerCredit(),
            CustomerSetting(),
          ],
        ),
      ),
    );
  }
}

