import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:http/src/io_streamed_response.dart';

/**
 * @author : jixiaoyong
 * @description ： TODO
 * @email : jixiaoyong1995@gmail.com
 * @date : 9/21/2022
 */

/// [CancelableHttpFileService] is the most common file service and the default for
/// [WebHelper]. One can easily adapt it to use dio or any other http client.
class CancelableHttpFileService extends FileService {
  final HttpClient _httpClient;
  final Map<String, HttpClientRequest?> _cachedHttpRequest = {};

  // key:timeInMs
  final Map<String, int> _abortHttpRequest = {};

  CancelableHttpFileService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  abortRequest(String url, {Map<String, String>? headers, String? requestKey}) {
    var key = requestKey ?? _genKey(url, headers);
    var request = _cachedHttpRequest.remove(key);
    Future.delayed(Duration(seconds: 0), () {
      cacheLogger.log("try request abort initiative:${key}  request:$request",
          CacheManagerLogLevel.debug);
      request?.abort(Exception("request abort initiative"));
      cacheLogger.log("request abort initiative:${key}  request:$request",
          CacheManagerLogLevel.debug);
    });
    var timeInMs = DateTime.now().millisecondsSinceEpoch;
    _abortHttpRequest[key] = timeInMs;
  }

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers, String? requestKey}) async {
    var key = requestKey ?? _genKey(url, headers);
    HttpClientRequest req;
    if (_cachedHttpRequest.containsKey(key) &&
        _cachedHttpRequest[key] != null) {
      req = _cachedHttpRequest[key]!;
    } else {
      req = await _httpClient.openUrl('GET', Uri.parse(url));
    }

    if (headers != null) {
      headers.forEach((key, value) {
        req.headers.set(key, value);
      });
    }

    IOStreamedResponse? httpResponse;
    try {
      var stream = const ByteStream(Stream.empty());
      var response = await stream.pipe(req) as HttpClientResponse;

      var _headers = <String, String>{};
      response.headers.forEach((key, values) {
        _headers[key] = values.join(',');
      });

      var request = Request("GET", Uri.parse(url));
      httpResponse = IOStreamedResponse(
          response.handleError((error) {
            final httpException = error as HttpException;
            throw ClientException(httpException.message, httpException.uri);
          }, test: (error) => error is HttpException),
          response.statusCode,
          contentLength:
              response.contentLength == -1 ? null : response.contentLength,
          request: request,
          headers: _headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          inner: response);
    } on HttpException catch (error) {
      throw ClientException(error.message, error.uri);
    } finally {
      _cachedHttpRequest.remove(key);
      cacheLogger.log(
          "_cachedHttpRequest.remove$key", CacheManagerLogLevel.debug);
    }

    return HttpGetResponse(httpResponse);
  }

  String _genKey(String uri, Map<String, String>? headers) {
    String mapString =
        (headers?.keys.join() ?? "") + (headers?.values.join() ?? "");
    var uriHeader = uri + mapString;
    return uriHeader.toLowerCase();
  }
}
