import 'package:get/get.dart';

class LocaleString extends Translations{
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
         //SPANISH LANGUAGE
    'es':{
      'correo': 'Correo electrónico',
      'contraseña':'Contraseña',
      'forgetPassword': '¿Has olvidado tu contraseña?',
      'login':'Iniciar Sesión',
      'authMethods':'Otros métodos de autenticación ',
      'changelang': 'Cambia de idioma'
    },
    //K
     //ENGLISH LANGUAGE
    'en':{
      'correo':'Email',
      'contraseña':'Password',
      'forgetPassword': 'Did you forget your password?',
      'login':'Log in',
      'authMethods':' Other authentication methods ',
      'changelang': 'Change language'
    }
  };

}