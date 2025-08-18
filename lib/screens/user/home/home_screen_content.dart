import 'package:flutter/material.dart';
import '../product/product_screen.dart';
import 'search_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../address/address_screen.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentAddress = prefs.getString('shipping_address') ?? '';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Thêm một Container với màu nền xám nhạt để áp dụng cho toàn bộ màn hình
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar with Title, Location, and Search
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.redAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chào mừng đến với My Shop App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bạn muốn mua gì hôm nay',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Feature icons section
            // Địa chỉ giao hàng
FadeInLeft(
  duration: const Duration(milliseconds: 500),
  child: GestureDetector(
    onTap: () async {
      final newAddress = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressScreen()),
      );
      if (newAddress != null) {
        setState(() {
          _currentAddress = newAddress;
        });
      }
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentAddress.isEmpty
                  ? 'Nhập địa chỉ giao hàng của bạn...'
                  : _currentAddress,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    ),
  ),
),


            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildCategoryImage(context, "Điện thoại", 'lib/assets/phone.png'),
                    _buildCategoryImage(context, "Laptop", 'lib/assets/laptop.png'),
                    _buildCategoryImage(context, "Đồng hồ", 'lib/assets/watch.png'),
                    _buildCategoryImage(context, "Âm thanh", 'lib/assets/earphone.png'),
                    _buildCategoryImage(context, "Màn hình", 'lib/assets/screen.png'),
                    _buildCategoryImage(context, "Máy tính bảng", 'lib/assets/ipad.png'),
                    _buildCategoryImage(context, "Phụ kiện", 'lib/assets/accessories.png'),
                    _buildCategoryImage(context, "PC", 'lib/assets/card.png'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Promo Banner
            FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 60/ 5,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://cdn2.cellphones.com.vn/insecure/rs:fill:1200:75/q:90/plain/https://dashboard.cellphones.com.vn/storage/special-b2s-dday2-desk.gif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(label: const Text('Apple'), onSelected: (_) {}),
                    FilterChip(label: const Text('Samsung'), onSelected: (_) {}),
                    FilterChip(label: const Text('Xiaomi'), onSelected: (_) {}),
                    FilterChip(label: const Text('Oppo'), onSelected: (_) {}),
                    FilterChip(label: const Text('Realme'), onSelected: (_) {}),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            
          ],
        ),
      ),
    );
  }



  Widget _buildCategoryImage(BuildContext context, String label, String assetPath, {bool highlight = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductScreen(category: label)),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: highlight
                  ? Border.all(color: Colors.red, width: 100)
                  : Border.all(color: Colors.transparent),
              image: DecorationImage(
                image: AssetImage(assetPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}