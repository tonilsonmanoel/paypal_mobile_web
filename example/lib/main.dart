import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paypal_mobile_web/paypal_mobile_web.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _launchURL() async {
    Map resultPaypal = await PaypalCheckout().getMapCheckout(
        clientId:
            "AXs_4ClaWWjkdXbcD7mzGwvcs7Z8sXRuPL_OnQvE8p-3EI4F-uq5iSupvSYAafEXXGLjv9GCv2pK1Oqn",
        secretKey:
            "EGRlbRFxz8dXke-wrRxN0RMITZZtSb6R9l_SBp-G7xl_guT1jZTYl5wXUsJkhiApYAO986bhaFGG7_3L",
        note: "Contact us for any questions on your order",
        transactions: [
          {
            "amount": {
              "total": '100',
              "currency": "BRL",
              "details": {
                "subtotal": '100',
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "The payment transaction description.",
            // "payment_options": {
            //   "allowed_payment_method":
            //       "INSTANT_FUNDING_SOURCE"
            // },
            "item_list": {
              "items": [
                {
                  "name": "Apple",
                  "quantity": 4,
                  "price": '10',
                  "currency": "BRL"
                },
                {
                  "name": "Pineapple",
                  "quantity": 5,
                  "price": '12',
                  "currency": "BRL"
                }
              ],

              // Optional
              //   "shipping_address": {
              //     "recipient_name": "Tharwat samy",
              //     "line1": "tharwat",
              //     "line2": "",
              //     "city": "tharwat",
              //     "country_code": "EG",
              //     "postal_code": "25025",
              //     "phone": "+00000000",
              //     "state": "ALex"
              //  },
            }
          }
        ],
        sandboxMode: true,
        returnURL: "http://localhost:60560/aprov?id=605656",
        cancelURL: "http://localhost:60560/cancelpag?id=05404");

    print("url Aproval: ${resultPaypal['approvalUrl']}");
    print("url execute: ${resultPaypal['executeUrl']}");
    print("MMap: ${resultPaypal}");

    if (await canLaunchUrlString(resultPaypal['approvalUrl'])) {
      await launchUrlString(resultPaypal['approvalUrl'],
          mode: LaunchMode.inAppBrowserView);
    } else {
      throw 'Could not launch ${resultPaypal['approvalUrl']}';
    }

    // se site retorna par returnUrl que dizer pagamento  aprovafo
    // var urlTest = Uri.parse("http://localhost:60560/aprov?id=605656&paymentId=PAYID-MZPVHII4SR58490MY497621F&token=EC-8D738479TE801835X&PayerID=ZQBVQPM2B6AVJ");

    // mostrar paramentos  print("paramentros: ${urlTest.queryParameters}");
    // mostrar paramentos Especifico print("paramentros: ${urlTest.queryParameters['id']}") resultado = 605656;
    // example url pagamento aprovado http://localhost:60560/aprov?id=605656&paymentId=PAYID-MZPVHII4SR58490MY497621F&token=EC-8D738479TE801835X&PayerID=ZQBVQPM2B6AVJ;

    /*  Paramentos para executar pagamento 
       String url = resultPaypal['executeUrl'];
       String payerId = resultPaypal['PayerID'];
       String accessToken = resultPaypal['token'];
    */
    //PaypalCheckout().executePayment(url, payerId, accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ElevatedButton(
                onPressed: _launchURL, child: const Text("LauchDeepLink")),
          ],
        ),
      ),
    );
  }
}
