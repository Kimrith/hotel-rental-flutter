import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_preview/device_preview.dart';
import 'package:hotel_rental/main.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Hotel rental app launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      DevicePreview(
        enabled: false,
        builder: (context) => const HotelRentalApp(),
      ),
    );

    // Verify that our app shows the welcome text.
    expect(find.text('Find your\nperfect sanctuary.'), findsOneWidget);

    // Verify that the navigation bar elements are present.
    expect(find.text('Explore'), findsOneWidget);
  });
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future.value(MockHttpClientRequest());
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('get', url);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() {
    return Future.value(MockHttpClientResponse());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  static final List<int> _imageBytes = [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0,
    1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65,
    84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73,
    69, 78, 68, 174, 66, 96, 130
  ];

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_imageBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _imageBytes.length;

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
