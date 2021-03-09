import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_commerce/screens/cart_page.dart';
import 'package:demo_commerce/screens/home_page.dart';
import 'package:demo_commerce/services/firebase_services.dart';
import 'package:demo_commerce/services/stripe_payment.dart';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class PaymentPage extends StatefulWidget {
  final String totalprice;
  PaymentPage({Key key, this.totalprice}) : super(key: key);
  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  FirebaseServices _firebaseServices = FirebaseServices();
  onItemPress(BuildContext context, int index, String totalprice) async {
    String price1 = totalprice;
    print('swtich');
    switch (index) {
      case 0:
        // setState(() {
        //ClearAllCart();
        //});
        payViaNewCard(context, price1);

        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CartPage()));
        break;
    }
  }

  payViaNewCard(BuildContext context, String totalprice) async {
    var price = totalprice;
    print(price);
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
        await StripeService.payWithNewCard(amount: price, currency: 'MYR');
    await dialog.hide();
    if (response.message == 'Transaction successful') {
      print('success');
      setState(() {
        _firebaseServices.usersRef
            .doc(_firebaseServices.getUserId())
            .collection("Cart")
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    // print(totalprice);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Icon icon;
              Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: theme.primaryColor);
                  text = Text('Pay via new card');
                  break;
                case 1:
                  icon = Icon(Icons.credit_card, color: theme.primaryColor);
                  text = Text('Cancel');
                  break;
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index, widget.totalprice);
                  print('ink');
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: theme.primaryColor,
                ),
            itemCount: 2),
      ),
    );
  }
}

/*class PaymentPage extends StatefulWidget {
  final String totalprice;

  PaymentPage(
    this.totalprice, {
    Key key,
  }) : super(key: key);

  @override
  PaymentPageState createState() => PaymentPageState();
}
setState(() {
          _firebaseServices.usersRef
              .doc(_firebaseServices.getUserId())
              .collection("Cart")
              .get()
              .then((snapshot) {
            for (DocumentSnapshot doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
        });
        Navigator.pop(
            context, MaterialPageRoute(builder: (context) => HomeTab()));
class PaymentPageState extends State<PaymentPage> {
  onItemPress(BuildContext context, int index, String totalprice) async {
    switch (index) {
      case 0:
        payViaNewCard(context, totalprice);
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeTab()));
        break;
    }
  }

  payViaNewCard(BuildContext context, String totalprice) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
        await StripeService.payWithNewCard(amount: totalprice, currency: 'USD');
    await dialog.hide();
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(response.message),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
            itemBuilder: (context, index) {
              Icon icon;
              Text text;

              switch (index) {
                case 0:
                  icon = Icon(Icons.add_circle, color: theme.primaryColor);
                  text = Text('Pay via new card');
                  break;
                case 1:
                  icon = Icon(Icons.cancel, color: theme.primaryColor);
                  text = Text('Cancel');
                  break;
              }

              return InkWell(
                onTap: () {
                  onItemPress(context, index, widget.totalprice);
                },
                child: ListTile(
                  title: text,
                  leading: icon,
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(
                  color: theme.primaryColor,
                ),
            itemCount: 2),
      ),
    );
  }
}
*/
