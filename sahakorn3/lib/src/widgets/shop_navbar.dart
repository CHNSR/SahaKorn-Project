import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahakorn3/src/routes/exports.dart';
import 'package:provider/provider.dart';
import 'package:sahakorn3/src/providers/shop_provider.dart';
import 'package:sahakorn3/src/providers/user_infomation.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavbarShop extends StatefulWidget {
  const NavbarShop({super.key});

  @override
  State<NavbarShop> createState() => _NavbarShopState();
}

class _NavbarShopState extends State<NavbarShop> {
  int _selectedIndex = 0;
  bool creadit = false;
  final controller = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<UserInformationProvider>().uid;
      if (uid != null) {
        context.read<ShopProvider>().loadShops(uid);
      }
    });
  }

  // 2. ตรวจสอบให้แน่ใจว่า List นี้เรียกใช้หน้าจอของ Shop ทั้งหมด

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
          backgroundColor: const Color(0xFF1E293B),
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                // Handle notifications
                Navigator.of(context).pushNamed(Routes.notification);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.change_circle_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // 2. แค่สลับ Role ใน SharedPreferences
                await prefs.setString('user_role', 'customer');

                // 3. สั่งให้แอปเริ่มต้นใหม่จาก Root widget
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthGate()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      extendBody: true,
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: const Color(0xFF1E293B),
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.house_outlined),
            selectedIcon: const Icon(Icons.house_rounded),
            selectedColor: Color(0xFFBAFFF5),
            unSelectedColor: Colors.white70,
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            badge: const Text('9+'),
            showBadge: true,
            badgeColor: Colors.purple,
            badgePadding: const EdgeInsets.only(left: 4, right: 4),
          ),
          BottomBarItem(
            icon: const Icon(Icons.transform),
            selectedIcon: const Icon(Icons.transform_outlined),
            selectedColor: Color(0xFFBAFFF5),
            unSelectedColor: Colors.white70,
            title: const Text(
              'Transaction',
              style: TextStyle(color: Colors.white),
            ),
          ),
          BottomBarItem(
            icon: const Icon(Icons.money_outlined),
            selectedIcon: const Icon(Icons.money),
            selectedColor: Color(0xFFBAFFF5),
            unSelectedColor: Colors.white70,
            title: const Text('Loan', style: TextStyle(color: Colors.white)),
          ),
          BottomBarItem(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            selectedColor: Color(0xFFBAFFF5),
            unSelectedColor: Colors.white70,
            title: const Text('Setting', style: TextStyle(color: Colors.white)),
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: _selectedIndex,
        notchStyle: NotchStyle.square,
        onTap: (index) {
          if (index == _selectedIndex) return;
          controller.jumpToPage(index);
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      //creadit buttom
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ShopQrGeneratePage()),
          );
          setState(() {
            creadit = !creadit;
          });
        },
        backgroundColor: const Color(0xFFBAFFF5),
        child: Icon(
          creadit ? CupertinoIcons.qrcode : CupertinoIcons.qrcode_viewfinder,
          color: Colors.black,
          size: 45,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: const [
            ShopHomepage(),
            ShopTransaction(),
            ShopCredit(),
            ShopSettingpage(),
          ],
        ),
      ),
    );
  }
}
