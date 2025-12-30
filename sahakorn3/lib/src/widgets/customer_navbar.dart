import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
                  Navigator.of(context).pushNamed(Routes.selectRole);
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
                Navigator.of(context).pushNamed(Routes.notification);
              },
            ),
            StreamBuilder<List<Shop>>(
              stream: FireShopReadService().watchShopsByOwner(
                FirebaseAuth.instance.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(
                      Icons.change_circle_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      // 2. แค่สลับ Role ใน SharedPreferences
                      await prefs.setString('user_role', 'shop');

                      // 3. สั่งให้แอปเริ่มต้นใหม่จาก Root widget
                      // นี่จะทำให้ StreamBuilder ใน main.dart ทำงานอีกครั้งและสร้าง NavbarShop ที่ถูกต้อง
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(Routes.root, (route) => false);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),

      extendBody: true,
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: const Color(0xFF34495e),
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
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
            icon: const Icon(Icons.shop_2_outlined),
            selectedIcon: const Icon(Icons.shop_2),
            selectedColor: Color(0xFFCCFF00),
            unSelectedColor: Colors.white,
            title: const Text('Shop', style: TextStyle(color: Colors.white)),
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
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
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
          Navigator.of(context).pushNamed(Routes.customerPay);
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
            CustomerShop(),
            CustomerCredit(),
            CustomerSetting(),
          ],
        ),
      ),
    );
  }
}
