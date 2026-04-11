import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class CompanyInfo {
  static String _read(String key, [String fallback = ""]) {
    final value = MySharedPreferences.getString(key).trim();
    return value.isEmpty ? fallback : value;
  }

  static String _trimLeadingDecorators(String value) => value.replaceFirst(
      RegExp(r'^[\s\.\u2022\u2023\u25E6\u2043\u2219\-–—]+'), '');

  static String _digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  static String get whatsApp => _digitsOnly(_read(companyWhatsappKey));
  static String get instagram => _read(companyInstagramKey);
  static String get facebook => _read(companyFacebookKey);
  static String get website => _read(companyWebsiteKey);
  static String get websiteNews => _read(companyNewsUrlKey);
  static String get companyAddress => _read(companyAddressKey);
  static String get companyGmail => _read(companySupportEmailKey);
  static String get companyPhone => _read(companyPhoneKey);
  static String get privacyPolicy => _read(companyPrivacyUrlKey);
  static String get termAndCondition => _read(companyTermsUrlKey);
  static String get companyName =>
      _trimLeadingDecorators(_read(companyNameKey));
}
