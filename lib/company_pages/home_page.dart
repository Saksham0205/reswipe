import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reswipe/company_pages/favourite_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';




class ClothingItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;

  ClothingItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
  };

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<ClothingItem> clothes = [];
  List<ClothingItem> favoriteClothes = [];
  late CardSwiperController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = CardSwiperController();
    _loadFavorites();
    _fetchTrendingClothes();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrendingClothes() async {
    await Future.delayed(Duration(seconds: 2));

    final List<Map<String, dynamic>> apiResponse = [
      {
        'id': '1',
        'name': 'Summer Floral Dress',
        'description': 'Light and breezy floral print dress perfect for summer days.',
        'imageUrl': 'https://n.nordstrommedia.com/id/sr3/ace4ea89-5c80-4558-9c17-aca91c122d48.jpeg?crop=pad&pad_color=FFF&format=jpeg&w=780&h=1196',
        'price': 59.99,
      },
      {
        'id': '2',
        'name': 'Denim Jacket',
        'description': 'Classic denim jacket with a modern twist.',
        'imageUrl': 'https://th.bing.com/th/id/OIP.lzcnwqWBuWtVLbX9QmquOAHaK0?w=206&h=302&c=7&r=0&o=5&dpr=1.3&pid=1.7',
        'price': 79.99,
      },
      {
        'id': '3',
        'name': 'Slim Fit Chinos',
        'description': 'Comfortable and stylish chinos for a casual look.',
        'imageUrl': 'https://th.bing.com/th/id/OIP.bjW9hz0cxrVYTOj1dV-wVwAAAA?w=208&h=265&c=7&r=0&o=5&dpr=1.3&pid=1.7',
        'price': 49.99,
      },
      {
        'id': '4',
        'name': 'Graphic T-Shirt',
        'description': 'Eye-catching graphic tee for a bold statement.',
        'imageUrl': 'https://i-teez.com/wp-content/uploads/2016/02/graphic-designer-tee-shirt-t-men.jpg',
        'price': 24.99,
      },
      {
        'id': '5',
        'name': 'Leather Sneakers',
        'description': 'Sleek leather sneakers for a touch of sophistication.',
        'imageUrl': 'https://th.bing.com/th/id/OIP.jgEjFPJWZ3bfb55RAaFY0QHaJ4?rs=1&pid=ImgDetMain',
        'price': 89.99,
      },
    ];

    setState(() {
      clothes = apiResponse.map((item) => ClothingItem.fromJson(item)).toList();
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<dynamic> decodedJson = jsonDecode(favoritesJson);
      setState(() {
        favoriteClothes = decodedJson.map((item) => ClothingItem.fromJson(item)).toList();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedJson = jsonEncode(favoriteClothes.map((e) => e.toJson()).toList());
    await prefs.setString('favorites', encodedJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: clothes.isEmpty
                  ? _buildLoadingShimmer()
                  : _buildCardSwiper(),
            ),
            _buildSwipeActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reswipe',
            style: GoogleFonts.pacifico(
              fontSize: 28,
              color: Colors.deepPurple,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(
                    favoriteClothes: favoriteClothes,
                    onFavoritesUpdated: (updatedFavorites) {
                      setState(() {
                        favoriteClothes = updatedFavorites;
                      });
                    },
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.favorite, color: Colors.deepPurple, size: 32),
                if (favoriteClothes.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${favoriteClothes.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildCardSwiper() {
    return FadeTransition(
      opacity: _animation,
      child: CardSwiper(
        controller: controller,
        cardsCount: clothes.length,
        onSwipe: _onSwipe,
        padding: const EdgeInsets.all(24.0),
        cardBuilder: (context, index, _, __) => _buildCard(clothes[index]),
      ),
    );
  }

  Widget _buildCard(ClothingItem item) {
    return Hero(
      tag: 'clothing_${item.id}',
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade50, Colors.white],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.error, size: 50, color: Colors.red),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Add to cart functionality
                            },
                            child: Text('Add to Cart',style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      setState(() {
        favoriteClothes.add(clothes[previousIndex]);
        _saveFavorites();
      });
    }
    if (currentIndex == null) {
      _fetchTrendingClothes();
      return false;
    }
    return true;
  }

  Widget _buildSwipeActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.left);
            },
            icon: Icons.close,
            color: Colors.red,
          ),
          _buildActionButton(
            onPressed: () {
              controller.swipe(CardSwiperDirection.right);
            },
            icon: Icons.favorite,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: color),
        onPressed: onPressed,
      ),
    );
  }
}