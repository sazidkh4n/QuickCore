import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class S3Config {
  final String accessKey;
  final String secretKey;
  final String bucketName;
  final String region;
  final String? endpoint; // For custom endpoints like DigitalOcean Spaces

  const S3Config({
    required this.accessKey,
    required this.secretKey,
    required this.bucketName,
    required this.region,
    this.endpoint,
  });
}

class S3Service {
  final S3Config config;
  
  S3Service(this.config);

  /// Upload file to S3 and return the public URL
  Future<String> uploadFile({
    required String key,
    required dynamic data, // Can be File, Uint8List, or String path
    required String contentType,
    Function(double)? onProgress,
  }) async {
    try {
      Uint8List bytes;
      
      if (data is File) {
        // Mobile file upload - read file to bytes
        bytes = await data.readAsBytes();
      } else if (data is Uint8List) {
        // Web bytes upload or mobile bytes
        bytes = data;
      } else if (data is String) {
        // File path string
        final file = File(data);
        bytes = await file.readAsBytes();
      } else {
        throw ArgumentError('Unsupported data type: ${data.runtimeType}');
      }

      // Upload bytes to S3
      final result = await _uploadBytes(
        key: key,
        bytes: bytes,
        contentType: contentType,
        onProgress: onProgress,
      );

      return result;
    } catch (e) {
      print('S3 Upload Error: $e');
      rethrow;
    }
  }

  /// Upload bytes directly using HTTP PUT request with progress tracking
  Future<String> _uploadBytes({
    required String key,
    required Uint8List bytes,
    required String contentType,
    Function(double)? onProgress,
  }) async {
    final host = config.endpoint != null 
        ? Uri.parse(config.endpoint!).host
        : '${config.bucketName}.s3.${config.region}.amazonaws.com';
    
    final url = config.endpoint != null
        ? '${config.endpoint}/${config.bucketName}/$key'
        : 'https://${config.bucketName}.s3.${config.region}.amazonaws.com/$key';
    
    // Generate AWS signature v4
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDate(now);
    final amzDate = _formatDateTime(now);
    final payloadHash = sha256.convert(bytes).toString();
    
    final canonicalHeaders = {
      'host': host,
      'x-amz-content-sha256': payloadHash,
      'x-amz-date': amzDate,
    };
    
    // Create canonical request
    final canonicalRequest = _createCanonicalRequest(
      method: 'PUT',
      uri: '/$key',
      queryString: '',
      headers: canonicalHeaders,
      payloadHash: payloadHash,
    );
    
    // Create string to sign
    final credentialScope = '$dateStamp/${config.region}/s3/aws4_request';
    final stringToSign = _createStringToSign(
      amzDate: amzDate,
      credentialScope: credentialScope,
      canonicalRequest: canonicalRequest,
    );
    
    // Calculate signature
    final signature = await _calculateSignature(
      secretKey: config.secretKey,
      dateStamp: dateStamp,
      region: config.region,
      service: 's3',
      stringToSign: stringToSign,
    );
    
    // Create authorization header
    final authorization = 'AWS4-HMAC-SHA256 '
        'Credential=${config.accessKey}/$credentialScope, '
        'SignedHeaders=host;x-amz-content-sha256;x-amz-date, '
        'Signature=$signature';

    final headers = {
      'Host': host,
      'Content-Type': contentType,
      'Content-Length': bytes.length.toString(),
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
      'Authorization': authorization,
    };

    final request = http.Request('PUT', Uri.parse(url));
    request.headers.addAll(headers);
    request.bodyBytes = bytes;

    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 204) {
      return getPublicUrl(key);
    } else {
      final responseBody = await streamedResponse.stream.bytesToString();
      throw Exception('S3 upload failed: ${streamedResponse.statusCode} - $responseBody');
    }
  }

  String _createCanonicalRequest({
    required String method,
    required String uri,
    required String queryString,
    required Map<String, String> headers,
    required String payloadHash,
  }) {
    final sortedHeaders = Map.fromEntries(
      headers.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    final canonicalHeaders = sortedHeaders.entries
        .map((e) => '${e.key.toLowerCase()}:${e.value.trim()}')
        .join('\n');
    
    final signedHeaders = sortedHeaders.keys
        .map((k) => k.toLowerCase())
        .join(';');
    
    return '$method\n$uri\n$queryString\n$canonicalHeaders\n\n$signedHeaders\n$payloadHash';
  }
  
  String _createStringToSign({
    required String amzDate,
    required String credentialScope,
    required String canonicalRequest,
  }) {
    final hashedCanonicalRequest = sha256.convert(utf8.encode(canonicalRequest)).toString();
    return 'AWS4-HMAC-SHA256\n$amzDate\n$credentialScope\n$hashedCanonicalRequest';
  }
  
  Future<String> _calculateSignature({
    required String secretKey,
    required String dateStamp,
    required String region,
    required String service,
    required String stringToSign,
  }) async {
    final kDate = await _hmacSha256(utf8.encode('AWS4$secretKey'), dateStamp);
    final kRegion = await _hmacSha256(kDate, region);
    final kService = await _hmacSha256(kRegion, service);
    final kSigning = await _hmacSha256(kService, 'aws4_request');
    final signature = await _hmacSha256(kSigning, stringToSign);
    
    return hex.encode(signature);
  }
  
  Future<List<int>> _hmacSha256(List<int> key, String data) async {
    final hmac = Hmac(sha256, key);
    return hmac.convert(utf8.encode(data)).bytes;
  }
  
  String _formatDate(DateTime dateTime) {
    return dateTime.toIso8601String().substring(0, 10).replaceAll('-', '');
  }
  
  String _formatDateTime(DateTime dateTime) {
    return dateTime.toIso8601String().replaceAll(RegExp(r'[:\-]'), '').substring(0, 15) + 'Z';
  }

  /// Generate a presigned URL for direct upload from client
  Future<String> generatePresignedUrl({
    required String key,
    required String contentType,
    Duration expiration = const Duration(hours: 1),
  }) async {
    // This would generate a presigned URL for direct client uploads
    // Implementation depends on your specific needs
    throw UnimplementedError('Presigned URLs not implemented yet');
  }

  /// Delete file from S3
  Future<bool> deleteFile(String key) async {
    try {
      final host = config.endpoint != null 
          ? Uri.parse(config.endpoint!).host
          : '${config.bucketName}.s3.${config.region}.amazonaws.com';
      
      final url = config.endpoint != null
          ? '${config.endpoint}/${config.bucketName}/$key'
          : 'https://${config.bucketName}.s3.${config.region}.amazonaws.com/$key';
      
      // Generate AWS signature for DELETE request
      final now = DateTime.now().toUtc();
      final dateStamp = _formatDate(now);
      final amzDate = _formatDateTime(now);
      
      final canonicalHeaders = {
        'host': host,
        'x-amz-date': amzDate,
      };
      
      final canonicalRequest = _createCanonicalRequest(
        method: 'DELETE',
        uri: '/$key',
        queryString: '',
        headers: canonicalHeaders,
        payloadHash: sha256.convert([]).toString(),
      );
      
      final credentialScope = '$dateStamp/${config.region}/s3/aws4_request';
      final stringToSign = _createStringToSign(
        amzDate: amzDate,
        credentialScope: credentialScope,
        canonicalRequest: canonicalRequest,
      );
      
      final signature = await _calculateSignature(
        secretKey: config.secretKey,
        dateStamp: dateStamp,
        region: config.region,
        service: 's3',
        stringToSign: stringToSign,
      );
      
      final authorization = 'AWS4-HMAC-SHA256 '
          'Credential=${config.accessKey}/$credentialScope, '
          'SignedHeaders=host;x-amz-date, '
          'Signature=$signature';

      final headers = {
        'Host': host,
        'x-amz-date': amzDate,
        'Authorization': authorization,
      };

      final response = await http.delete(Uri.parse(url), headers: headers);
      return response.statusCode == 204;
    } catch (e) {
      print('S3 Delete Error: $e');
      return false;
    }
  }

  /// Get public URL for a file
  String getPublicUrl(String key) {
    if (config.endpoint != null) {
      // Custom endpoint (like DigitalOcean Spaces)
      return '${config.endpoint}/${config.bucketName}/$key';
    } else {
      // Standard AWS S3 - use virtual-hosted-style URL for better performance
      return 'https://${config.bucketName}.s3.${config.region}.amazonaws.com/$key';
    }
  }
}