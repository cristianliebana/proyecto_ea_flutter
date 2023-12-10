class Endpoints {
  //static const String ipBackend = 'URL';
  static const String ipBackend = String.fromEnvironment('ipBackend',
  defaultValue: 'http://localhost:9090'); //Local
  //defaultValue: 'http://km0-api:9090'); //Production
}
