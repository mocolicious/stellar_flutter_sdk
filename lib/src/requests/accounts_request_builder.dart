// Copyright 2020 The Stellar Flutter SDK Authors. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

import "package:eventsource/eventsource.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../responses/response.dart';
import '../responses/account_response.dart';
import 'request_builder.dart';


/// Builds requests connected to accounts.
/// See <a href="https://www.stellar.org/developers/horizon/reference/accounts-single.html">Account Details</a>
class AccountsRequestBuilder extends RequestBuilder {
  AccountsRequestBuilder(http.Client httpClient, Uri serverURI)
      : super(httpClient, serverURI, ["accounts"]);

  /// Requests specific [uri] and returns AccountResponse.
  /// This method is helpful for getting the links.
  Future<AccountResponse> accountURI(Uri uri) async {
    TypeToken type = new TypeToken<AccountResponse>();
    ResponseHandler<AccountResponse> responseHandler =
    ResponseHandler<AccountResponse>(type);

    return await httpClient.get(uri).then((response) {
      return responseHandler.handleResponse(response);
    });
  }

  /// Requests details about the [account] to fetch
  /// See <a href="https://www.stellar.org/developers/horizon/reference/accounts-single.html">Account Details</a>
  Future<AccountResponse> account(String accountId) {
    this.setSegments(["accounts", accountId]);
    return this.accountURI(this.buildUri());
  }

  /// Requests specific uri and returns Page of AccountResponse.
  /// This method is helpful for getting the next set of results.
  static Future<Page<AccountResponse>> requestExecute(
      http.Client httpClient, Uri uri) async {
    TypeToken type = new TypeToken<Page<AccountResponse>>();
    ResponseHandler<Page<AccountResponse>> responseHandler =
    new ResponseHandler<Page<AccountResponse>>(type);

    return await httpClient.get(uri).then((response) {
      return responseHandler.handleResponse(response);
    });
  }

  /// Allows to stream SSE events from horizon.
  /// Certain endpoints in Horizon can be called in streaming mode using Server-Sent Events.
  /// This mode will keep the connection to horizon open and horizon will continue to return
  /// responses as ledgers close.
  Stream<AccountResponse> stream() {
    StreamController<AccountResponse> listener =
    new StreamController.broadcast();
    EventSource.connect(this.buildUri()).then((eventSource) {
      eventSource.listen((Event event) {
        if (event.data == "\"hello\"" || event.event == "close") {
          return null;
        }
        AccountResponse accountResponse =
        AccountResponse.fromJson(json.decode(event.data));
        listener.add(accountResponse);
      });
    });
    return listener.stream;
  }

  /// Build and execute request. AccountResponses in Page will contain only [keypair] field.
  Future<Page<AccountResponse>> execute() {
    return AccountsRequestBuilder.requestExecute(
        this.httpClient, this.buildUri());
  }

  @override
  AccountsRequestBuilder cursor(String token) {
    super.cursor(token);
    return this;
  }

  @override
  AccountsRequestBuilder limit(int number) {
    super.limit(number);
    return this;
  }

  @override
  AccountsRequestBuilder order(RequestBuilderOrder direction) {
    super.order(direction);
    return this;
  }
}