import 'dart:convert';

import 'package:dio/dio.dart';

import 'dart:async';
import 'dart:convert' as convert;

class PaypalServices {
  getAccessToken(bool sandboxMode, String clientId, String secretKey) async {
    String baseUrl = sandboxMode!
        ? "https://api-m.sandbox.paypal.com"
        : "https://api.paypal.com";

    try {
      var authToken = base64.encode(
        utf8.encode("$clientId:$secretKey"),
      );
      final response = await Dio()
          .post('$baseUrl/v1/oauth2/token?grant_type=client_credentials',
              options: Options(
                headers: {
                  'Authorization': 'Basic $authToken',
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
              ));
      final body = response.data;
      return {
        'error': false,
        'message': "Success",
        'token': body["access_token"]
      };
    } on DioException {
      return {
        'error': true,
        'message': "Your PayPal credentials seems incorrect"
      };
    } catch (e) {
      return {
        'error': true,
        'message': "Unable to proceed, check your internet connection."
      };
    }
  }

  Future<Map> createPaypalPayment(
      transactions, accessToken, sandboxMode) async {
    String domain = sandboxMode
        ? "https://api.sandbox.paypal.com"
        : "https://api.paypal.com";

    try {
      final response = await Dio().post('$domain/v1/payments/payment',
          data: jsonEncode(transactions),
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json'
            },
          ));

      final body = response.data;
      if (body["links"] != null && body["links"].length > 0) {
        List links = body["links"];

        String executeUrl = "";
        String approvalUrl = "";
        final item = links.firstWhere((o) => o["rel"] == "approval_url",
            orElse: () => null);
        if (item != null) {
          approvalUrl = item["href"];
        }
        final item1 =
            links.firstWhere((o) => o["rel"] == "execute", orElse: () => null);
        if (item1 != null) {
          executeUrl = item1["href"];
        }
        return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
      }
      return {};
    } on DioException catch (e) {
      return {
        'error': true,
        'message': "Payment Failed.",
        'data': e.response?.data,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> getMapCheckoutServices({
    required String clientId,
    required String secretKey,
    required String note,
    required List transactions,
    required bool sandboxMode,
    required String returnURL,
    required String cancelURL,
  }) async {
    Map mapCheckout = {};
    Map getOrderParams() {
      Map<String, dynamic> temp = {
        "intent": "sale",
        "payer": {"payment_method": "paypal"},
        "transactions": transactions,
        "note_to_payer": note,
        "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
      };

      return temp;
    }

    try {
      String accessToken = '';
      Map getToken = await getAccessToken(sandboxMode, clientId, secretKey);

      if (getToken['token'] != null) {
        accessToken = getToken['token'];
        final body = getOrderParams();
        final res = await createPaypalPayment(body, accessToken, sandboxMode);

        if (res["approvalUrl"] != null) {
          return mapCheckout = {
            'approvalUrl': res["approvalUrl"],
            'executeUrl': res["executeUrl"],
            'erro': null
          };
        } else {
          return mapCheckout = {
            'approvalUrl': null,
            'executeUrl': null,
            'erro': res,
          };
        }
      } else {
        return mapCheckout = {
          'approvalUrl': null,
          'executeUrl': null,
          'erro': getToken['message'],
        };
      }
    } catch (e) {
      return mapCheckout = {
        'approvalUrl': null,
        'executeUrl': null,
        'erro': e,
      };
    }
  }

  Future<Map> executePayment(
    url,
    payerId,
    accessToken,
  ) async {
    try {
      final response = await Dio().post(url,
          data: convert.jsonEncode({"payer_id": payerId}),
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json'
            },
          ));

      final body = response.data;
      return {'error': false, 'message': "Success", 'data': body};
    } on DioException catch (e) {
      return {
        'error': true,
        'message': "Payment Failed.",
        'data': e.response?.data,
      };
    } catch (e) {
      return {'error': true, 'message': e, 'exception': true, 'data': null};
    }
  }
}
