class Endpoints {
  //static const String ipBackend = 'URL';
  static const String ipBackend = String.fromEnvironment('ipBackend',
      defaultValue: 'http://localhost:9090'); //Local
      //defaultValue: 'http://147.83.7.157:9090'); //Production
}
