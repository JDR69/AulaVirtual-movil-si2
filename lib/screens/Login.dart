import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String ci = '';
  String password = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Debug - Mostrar datos antes de enviar
        print("Intentando login con CI: '$ci' y password: '$password'");

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final fcmToken = userProvider.fcmToken ?? '';
        // Llamar al endpoint de login
        final userData = await ApiService.login(ci, password, fcmToken);

        if (userData != null) {
          print("✅ Login exitoso, respuesta");

          // Verificar estructura de la respuesta
          if (userData.containsKey('usuario')) {
            print("✅ Datos de usuario encontrados en la respuesta");
            final userInfo = userData['usuario'];

            Provider.of<UserProvider>(context, listen: false).setUser(userInfo);

            if (userData.containsKey('permisos')) {
              print("✅ Permisos encontrados");
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).setPermisos(userData['permisos']);
            } else {
              print("⚠️ No se encontraron permisos en la respuesta");
            }

            // Antes de la redirección, asegurar que el usuario está guardado
            print(
              "✅ Usuario guardado en Provider: ${Provider.of<UserProvider>(context, listen: false).user}",
            );

            // Redirección al dashboard
            print("✅ Redireccionando al dashboard");
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            print("❌ No se encontró el objeto 'usuario' en la respuesta");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'La respuesta del servidor no contiene datos de usuario',
                ),
              ),
            );
          }
        } else {
          print("❌ Login fallido, respuesta nula");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales incorrectas')),
          );
        }
      } catch (e, stackTrace) {
        print("❌ Excepción durante login: $e");
        print("Stack trace: $stackTrace");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("❌ Validación de formulario fallida");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                Text(
                  'Aula Virtual',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 24),
                // Icono
                Icon(Icons.school, size: 80, color: Colors.blue),
                SizedBox(height: 40),
                // Campo de CI
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        ci = value.trim(); // Trimming para evitar espacios
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'CI',
                      prefixIcon: Icon(Icons.person),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su CI';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Campo de contraseña
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        password = value
                            .trim(); // Trimming para evitar espacios
                      });
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 24),
                // Botón de inicio de sesión
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              3,
                              172,
                              250,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
