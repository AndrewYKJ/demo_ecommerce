import 'package:demo_commerce/screens/product_page.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final Function onPressed;
  final String imageUrl;
  final String title;
  final String price;
  ProductCard(
      {this.onPressed, this.imageUrl, this.title, this.price, this.productId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductPage(
                  productId: productId,
                ),
              ));
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          height: 350.0,
          margin: EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 280.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36.0),
                  child: Image.network(
                    "$imageUrl",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 15.0,
                      // color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w300),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15.0, right: 15),
                child: Text(
                  "$price",
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
