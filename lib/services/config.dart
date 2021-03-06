class Config {
  static const appName = String.fromEnvironment('APP_NAME', defaultValue: 'App name missing');
  static const device = String.fromEnvironment('DEVICE', defaultValue: '');
  static const os = String.fromEnvironment('OS', defaultValue: '');
  static const _backendThemeUrl = String.fromEnvironment('backendThemeUrl', defaultValue: null);

  static String get backendThemeUrl {
    if (_backendThemeUrl != null) return _backendThemeUrl;
    return 'https://api.nalia.kr/v3';
  }

  static final String passCallbackUrl =
      "https://id.passlogin.com/oauth2/authorize?client_id=gvC47PHoY7kS3DfpGfff&redirect_uri=https%3A%2F%2Fapi.nalia.kr%2Fv3%2Fvar%2Fpass%2Fpass_login_callback.php&response_type=code&state=apple_banana_cherry&isHybrid=Y";

  static final String galleryCategory = 'gallery';
}

String apiUrl = Config.backendThemeUrl + '/api/index.php';
