class AppConfig {
  // AWS S3 Configuration
  static const String awsAccessKey = String.fromEnvironment(
    'AWS_ACCESS_KEY',
    defaultValue: 'YOUR_AWS_ACCESS_KEY',
  );
  
  static const String awsSecretKey = String.fromEnvironment(
    'AWS_SECRET_KEY',
    defaultValue: 'YOUR_AWS_ACCESS_KEY/+s/YOUR_AWS_SECRET_KEY',
  );
  
  static const String awsBucketName = String.fromEnvironment(
    'AWS_BUCKET_NAME',
    defaultValue: 'quickcore-videos',
  );
  
  static const String awsRegion = String.fromEnvironment(
    'AWS_REGION',
    defaultValue: 'ap-south-1',
  );
  
  // For DigitalOcean Spaces, Wasabi, or other S3-compatible services
  static const String? awsEndpoint = String.fromEnvironment(
    'AWS_ENDPOINT',
    defaultValue: '', // Leave empty for standard AWS S3
  );
  
  // Storage Strategy Configuration
  static const bool useHybridStorage = bool.fromEnvironment(
    'USE_HYBRID_STORAGE',
    defaultValue: true,
  );
  
  static const bool useS3ForVideos = bool.fromEnvironment(
    'USE_S3_FOR_VIDEOS',
    defaultValue: true,
  );
  
  // Supabase Configuration (existing)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Helper methods
  static bool get isAwsConfigured => 
      awsAccessKey.isNotEmpty && 
      awsSecretKey.isNotEmpty &&
      awsBucketName.isNotEmpty;
  
  static String? get effectiveAwsEndpoint => 
      awsEndpoint?.isEmpty == true ? null : awsEndpoint;
}