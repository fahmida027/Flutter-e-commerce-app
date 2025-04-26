import 'dart:convert';
import 'package:api/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'api_service/api.dart';
import 'model/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Product>> getProducts() async {
    List<Product> products = [];

    try {
      final url = Uri.parse(Api.getAllProducts);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        for (var eachRecord in (responseData as List)) {
          products.add(Product.fromJson(eachRecord));
        }
      } else {
        Fluttertoast.showToast(msg: "Error loading products");
      }
    } catch (errorMsg) {
      Fluttertoast.showToast(msg: "Error fetching products");
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
title: Text(
  'Happy Shopping',
  style: GoogleFonts.pacifico(
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 26,
      shadows: [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: Colors.black45,
        ),
      ],
    ),
  ),
),

        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: FutureBuilder(
        future: getProducts(),
        builder: (context, AsyncSnapshot<List<Product>> dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dataSnapshot.hasError) {
            return const Center(child: Text("Error occurred!"));
          }

          if (dataSnapshot.data == null || dataSnapshot.data!.isEmpty) {
            return const Center(child: Text("No Product found"));
          }

          return Expanded(
            child: GridView.builder(
              itemCount: dataSnapshot.data!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                Product eachProduct = dataSnapshot.data![index];

                return GestureDetector(
                  onTap: () {
                    Get.to(ProductDetails(productInfo: eachProduct));
                  },
                  child: Column(
                    children: [
                      Container(
                        child: Card(
                          elevation: 2,
                          color: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: eachProduct.image!,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        eachProduct.title ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      Text("Tk ${eachProduct.price}"),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(30),
                          backgroundColor:  Color.fromARGB(255, 85, 98, 108),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Add to card" ,
                        style: TextStyle (color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
