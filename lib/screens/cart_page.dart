import 'package:demo_commerce/screens/payment_page.dart';
import 'package:demo_commerce/screens/product_page.dart';
import 'package:demo_commerce/services/firebase_services.dart';
import 'package:demo_commerce/services/stripe_payment.dart';
import 'package:demo_commerce/widgets/custom_action_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  FirebaseServices _firebaseServices = FirebaseServices();
  int itemno = 0;
  var listprice = [];
  int pricesum = 0;

  double priceint = 0;

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<QuerySnapshot>(
            future: _firebaseServices.usersRef
                .doc(_firebaseServices.getUserId())
                .collection("Cart")
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              // Collection Data ready to display
              if (snapshot.connectionState == ConnectionState.done) {
                // Display the data inside a list view
                return ListView(
                  padding: EdgeInsets.only(
                    top: 108.0,
                    bottom: 12.0,
                  ),
                  children: snapshot.data.docs.map((document) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                productId: document.id,
                              ),
                            ));
                      },
                      child: FutureBuilder(
                        future: _firebaseServices.productsRef
                            .doc(document.id)
                            .get(),
                        builder: (context, productSnap) {
                          if (productSnap.hasError) {
                            return Container(
                              child: Center(
                                child: Text("${productSnap.error}"),
                              ),
                            );
                          }

                          if (productSnap.connectionState ==
                              ConnectionState.done) {
                            Map _productMap = productSnap.data.data();
                            listprice[itemno] = _productMap['price'];
                            print(listprice);
                            print(itemno);
                            priceint = double.parse(listprice[itemno]) * 100;
                            pricesum += priceint.toInt();
                            print(pricesum);
                            itemno++;

                            // Calculation(_productMap['price']);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 24.0,
                              ),
                              child: Stack(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            "${_productMap['images'][0]}",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 16.0,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${_productMap['name']}",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 4.0,
                                              ),
                                              child: Text(
                                                "MYR${_productMap['price']}",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Text(
                                              "ProductCode - ${document.data()['productcode']}",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 90,
                                        width: 90,
                                        color: Colors.transparent,
                                        //alignment: ,

                                        child: Stack(children: [
                                          Positioned(
                                            top: 35,
                                            right: 20,
                                            child: IconButton(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  _firebaseServices.usersRef
                                                      .doc(_firebaseServices
                                                          .getUserId())
                                                      .collection("Cart")
                                                      .doc(document.id)
                                                      .delete();

                                                  priceint = double.parse(
                                                          _productMap[
                                                              'price']) *
                                                      100;
                                                  pricesum = 0;
                                                  // pricesum -= priceint.toInt();
                                                  print(priceint);
                                                  print(pricesum);
                                                });
                                              },
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              }

              // Loading State
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
          CustomActionBar(
            hasBackArrrow: true,
            title: "Cart",
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  String totalprice = pricesum.toString();
                  print(pricesum);
                  if (totalprice == '0') {
                    _showMyDialog();
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PaymentPage(totalprice: totalprice)));
                  }
                  //payWithNewCard(context, pricesum);
                },
                child: Container(
                  height: 65.0,
                  margin: EdgeInsets.all(
                    16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Proceed to Checkout",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'There is no item in cart.\nPlease select some item to proceed.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

//void Calculation(productMap) {
// list double _productprice = productmap.data;
//}

/*class Payment extends StatefulWidget {
  Payment({
    Key key,
  }) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PaymentPage()));
          },
          child: Container(
            height: 65.0,
            margin: EdgeInsets.all(
              16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Text(
              "Proceed to Checkout",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
        )
      ],
    );
  }
}*/
