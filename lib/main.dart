import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Main Function
void main() {
  runApp(const MyApp());
}

class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
  });

  // Factory method to create a Product instance from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['thumbnail'],
      price: json['price'].toDouble(),
    );
  }
}

// API service class to fetch products
class ApiService {
  static const String apiUrl = "https://dummyjson.com/products";

  // Function to fetch product data
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> productsJson = data['products'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}

// MyApp widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Product List',
      theme: ThemeData(
        brightness: Brightness.dark, // Set brightness to dark
        primaryColor: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // Dark greyish black
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1C1E), // Dark greyish black
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF2C2C2E), // Slightly lighter dark grey
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark().copyWith(
          primary: Colors.red,
          secondary: Colors.redAccent,
          background: const Color(0xFF1C1C1E), // Dark greyish black
        ),
      ),
      initialRoute: '/', // Initial route
      routes: {
        '/': (context) => const ProductListScreen(), // Main screen
        '/product-details': (context) => const ProductDetailsScreen(), // Product details screen
      },
    );
  }
}

// ProductListScreen widget to display products
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.redAccent,
            ));
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 3, // Subtle shadow for card
                  color: const Color(0xFF2C2C2E), // Dark grey for cards
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Image.network(
                      product.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      product.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Navigate to product details screen
                      Navigator.pushNamed(
                        context,
                        '/product-details',
                        arguments: product,
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                'No Products found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }
}

// ProductDetailsScreen widget for displaying details of a product
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the product object passed as an argument
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                product.image,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
