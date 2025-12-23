class CloudinaryUploadResponseDto {
  final String publicId;
  final String secureUrl;
  final String url;
  final int width;
  final int height;
  final String format;
  final String resourceType;
  final int bytes;
  final String createdAt;

  CloudinaryUploadResponseDto({
    required this.publicId,
    required this.secureUrl,
    required this.url,
    required this.width,
    required this.height,
    required this.format,
    required this.resourceType,
    required this.bytes,
    required this.createdAt,
  });

  factory CloudinaryUploadResponseDto.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResponseDto(
      publicId: json['public_id'] ?? '',
      secureUrl: json['secure_url'] ?? '',
      url: json['url'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      format: json['format'] ?? '',
      resourceType: json['resource_type'] ?? '',
      bytes: json['bytes'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'secure_url': secureUrl,
      'url': url,
      'width': width,
      'height': height,
      'format': format,
      'resource_type': resourceType,
      'bytes': bytes,
      'created_at': createdAt,
    };
  }
}

