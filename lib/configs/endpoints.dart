class Endpoints {
  //static const String ipBackend = 'URL';
  static const String ipBackend = String.fromEnvironment('ipBackend',
      defaultValue: 'http://localhost:9090');
}
