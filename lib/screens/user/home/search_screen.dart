import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final allProducts = Provider.of<ProductProvider>(context, listen: false).products;

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<ProductProvider>(context).isLoading;

    Widget bodyContent;

    if (isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (_searchController.text.isEmpty) {
      bodyContent = const Center(child: Text('Hãy nhập từ khóa để tìm kiếm sản phẩm.'));
    } else if (_filteredProducts.isEmpty) {
      bodyContent = const Center(child: Text('Không tìm thấy sản phẩm nào.'));
    } else {
      bodyContent = ListView.builder(
        key: ValueKey(_filteredProducts.length),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.name),
              subtitle: Text('${product.price.toStringAsFixed(0)} đ'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetail(product: product),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
          )
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: bodyContent,
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/product.dart';
// import '../../providers/product_provider.dart';
// import '../product/product_detail_screen.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   List<Product> _filteredProducts = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     // Gọi sau frame đầu tiên để tránh lỗi "setState during build"
//     Future.delayed(Duration.zero, () async {
//       await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
//     });

//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.toLowerCase();
//     final allProducts = Provider.of<ProductProvider>(context, listen: false).products;

//     setState(() {
//       if (query.isEmpty) {
//         _filteredProducts = [];
//       } else {
//         _filteredProducts = allProducts.where((product) {
//           return product.name.toLowerCase().contains(query);
//         }).toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLoading = Provider.of<ProductProvider>(context).isLoading;

//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'Tìm kiếm sản phẩm...',
//             border: InputBorder.none,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: () {
//               _searchController.clear();
//               FocusScope.of(context).unfocus();
//             },
//           )
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _searchController.text.isEmpty
//               ? const Center(child: Text('Hãy nhập từ khóa để tìm kiếm sản phẩm.'))
//               : _filteredProducts.isEmpty
//                   ? const Center(child: Text('Không tìm thấy sản phẩm nào.'))
//                   : ListView.builder(
//                       itemCount: _filteredProducts.length,
//                       itemBuilder: (context, index) {
//                         final product = _filteredProducts[index];
//                         return ListTile(
//                           leading: Image.network(
//                             product.imageUrl,
//                             width: 50,
//                             height: 50,
//                             fit: BoxFit.cover,
//                           ),
//                           title: Text(product.name),
//                           subtitle: Text('${product.price.toStringAsFixed(0)} đ'),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => ProductDetail(product: product),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//     );
//   }
// }
