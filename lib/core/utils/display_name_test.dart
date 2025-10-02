import 'package:flutter_test/flutter_test.dart';
import '../../features/auth/data/user_model.dart';
import 'display_name_utils.dart';

void main() {
  group('DisplayNameUtils Tests', () {
    test('should return name when available', () {
      final user = UserModel(
        id: 'test-id',
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getDisplayName(user), equals('John Doe'));
    });
    
    test('should return @username when name is not available', () {
      final user = UserModel(
        id: 'test-id',
        name: null,
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getDisplayName(user), equals('@johndoe'));
    });
    
    test('should return @username when name is empty', () {
      final user = UserModel(
        id: 'test-id',
        name: '',
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getDisplayName(user), equals('@johndoe'));
    });
    
    test('should return fallback when neither name nor username available', () {
      final user = UserModel(
        id: 'test-id12345',
        name: null,
        username: null,
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getDisplayName(user), equals('User_test-id1'));
    });
    
    test('should return fallback when both name and username are empty', () {
      final user = UserModel(
        id: 'test-id12345',
        name: '',
        username: '',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getDisplayName(user), equals('User_test-id1'));
    });
    
    test('should detect email addresses correctly', () {
      expect(DisplayNameUtils.isEmail('john@example.com'), isTrue);
      expect(DisplayNameUtils.isEmail('user.name@domain.co.uk'), isTrue);
      expect(DisplayNameUtils.isEmail('notanemail'), isFalse);
      expect(DisplayNameUtils.isEmail('john@'), isFalse);
      expect(DisplayNameUtils.isEmail('@example.com'), isFalse);
      expect(DisplayNameUtils.isEmail('testid'), isFalse);
    });
    
    test('should sanitize email addresses', () {
      expect(DisplayNameUtils.sanitizeDisplayName('john@example.com'), equals('john'));
      expect(DisplayNameUtils.sanitizeDisplayName('user.name@domain.com'), equals('user.name'));
      expect(DisplayNameUtils.sanitizeDisplayName('@example.com'), equals('example.com'));
      expect(DisplayNameUtils.sanitizeDisplayName('John Doe'), equals('John Doe'));
    });
    
    test('should get short display name correctly', () {
      final user = UserModel(
        id: 'test-id',
        name: 'John Doe Smith',
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getShortDisplayName(user), equals('John'));
    });
    
    test('should get initials correctly', () {
      final user = UserModel(
        id: 'test-id',
        name: 'John Doe',
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getInitials(user), equals('JD'));
    });
    
    test('should get single initial for single name', () {
      final user = UserModel(
        id: 'test-id',
        name: 'John',
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getInitials(user), equals('J'));
    });
    
    test('should get username initial when no name', () {
      final user = UserModel(
        id: 'test-id',
        name: null,
        username: 'johndoe',
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getInitials(user), equals('J'));
    });
    
    test('should get fallback initial when no name or username', () {
      final user = UserModel(
        id: 'test-id',
        name: null,
        username: null,
        email: 'john@example.com',
      );
      
      expect(DisplayNameUtils.getInitials(user), equals('U'));
    });
  });
} 