import 'package:flutter/material.dart';
import 'package:paypal_mobile_web/paypal_mobile_web.dart';
import 'package:paypal_mobile_web/src/paypal_service.dart';

class PaypalCheckout {
  Future<Map> getMapCheckout({
    required String clientId,
    required String secretKey,
    required String note,
    required List transactions,
    required bool sandboxMode,
    required String returnURL,
    required String cancelURL,
  }) async {
    Map result = await PaypalServices().getMapCheckoutServices(
        clientId: clientId,
        secretKey: secretKey,
        note: note,
        transactions: transactions,
        sandboxMode: sandboxMode,
        returnURL: returnURL,
        cancelURL: cancelURL);
    return result;
  }

  Future<Map> executePayment(
    url,
    payerId,
    accessToken,
  ) async {
    try {
      Map result =
          await PaypalServices().executePayment(url, payerId, accessToken);
      return result;
    } catch (e) {
      return {'error': true, 'message': e, 'exception': true, 'data': null};
    }
  }
}
