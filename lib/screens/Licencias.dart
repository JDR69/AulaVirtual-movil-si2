import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class LicenciasScreen extends StatefulWidget {
  @override
  _LicenciasScreenState createState() => _LicenciasScreenState();
}

class _LicenciasScreenState extends State<LicenciasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _fechaController = TextEditingController();
  final _urlImagenController = TextEditingController();

  // URL de imagen predeterminada
  final String _defaultImageUrl = "http://hola.mundo";

  bool _isLoading = false;
  String _mensaje = '';
  bool _exito = false;
  Map<String, dynamic>? _userData;
  String? _selectedImagePath;
  bool _usingDefaultImage = false;

  @override
  void initState() {
    super.initState();
    // Verificar si hay token disponible
    if (ApiService.token == null) {
      setState(() {
        _exito = false;
        _mensaje = 'No hay sesión activa. Por favor inicie sesión nuevamente.';
      });
      // Considerar redirigir al login
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    // Cargar datos del usuario desde el Provider
    _cargarDatosUsuario();
    
    // Establecer URL predeterminada
    _urlImagenController.text = _defaultImageUrl;
    _usingDefaultImage = true;

    // Establecer fecha actual por defecto
    final hoy = DateTime.now();
    _fechaController.text = "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);

    try {
      // Obtener datos del usuario desde el Provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Verificar que el provider tenga datos de usuario
      if (userProvider.user != null &&
          userProvider.user!.containsKey('id') &&
          userProvider.user!.containsKey('nombre')) {
        setState(() {
          _userData = userProvider.user;
        });
      } else {
        setState(() {
          _exito = false;
          _mensaje =
              'No se pudieron cargar los datos del usuario correctamente';
        });
      }
    } catch (e) {
      setState(() {
        _exito = false;
        _mensaje = 'Error al cargar datos: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaController.text =
            "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Método para seleccionar imagen de la galería
  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? imagen = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (imagen != null) {
        setState(() {
          _selectedImagePath = imagen.path;
          _urlImagenController.text =
              imagen.path; // Guardamos la ruta como referencia
          _usingDefaultImage = false;
        });
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      setState(() {
        _mensaje = 'No se pudo seleccionar la imagen';
        _exito = false;
      });
    }
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar si userData está disponible
    if (_userData == null) {
      setState(() {
        _exito = false;
        _mensaje = 'Error: Información de usuario no disponible';
      });
      return;
    }

    // Verificar si las claves necesarias existen
    if (!_userData!.containsKey('id') || !_userData!.containsKey('nombre')) {
      setState(() {
        _exito = false;
        _mensaje = 'Error: Datos de usuario incompletos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _mensaje = '';
    });

    try {
      // Si no se seleccionó imagen o hubo problemas, usamos la URL por defecto
      final String imagenUrl = _usingDefaultImage
          ? _defaultImageUrl
          : _urlImagenController.text;

      final resultado = await ApiService.crearLicencia(
        descripcion: _descripcionController.text,
        fecha: _fechaController.text,
        imagen: imagenUrl,
        alumno: _userData!['id'],
        nombreUsuario: _userData!['nombre'],
      );

      if (resultado != null) {
        setState(() {
          _exito = true;
          _mensaje = '¡Licencia creada exitosamente!';
          // Limpiar campos
          _descripcionController.clear();
          // Restablecer URL por defecto
          _urlImagenController.text = _defaultImageUrl;
          _usingDefaultImage = true;
          _selectedImagePath = null;
        });
      } else {
        setState(() {
          _exito = false;
          _mensaje = 'No se pudo crear la licencia';
        });
      }
    } catch (e) {
      setState(() {
        _exito = false;
        _mensaje = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _fechaController.dispose();
    _urlImagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Licencias Médicas'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_userData == null)
          ? _buildErrorView() // Nueva vista para errores
          : _buildBody(),
    );
  }

  // Nuevo método para mostrar errores
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red),
            SizedBox(height: 20),
            Text(
              _mensaje.isNotEmpty
                  ? _mensaje
                  : 'No se pudieron cargar los datos del usuario',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarDatosUsuario,
              icon: Icon(Icons.refresh),
              label: Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildFormCard(),
    );
  }

  // Método actualizado para construir el formulario
  Widget _buildFormCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Nueva Solicitud de Licencia',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Divider(height: 32),

              // Campo de descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Motivo de la licencia',
                  hintText: 'Ej: Enfermedad crónica, consulta médica...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el motivo de la licencia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo de fecha
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: _seleccionarFecha,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una fecha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Reemplazo del campo URL de imagen con un selector de imagen
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Documento/Imagen',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),

                  // Previsualización de la imagen seleccionada
                  if (_selectedImagePath != null) ...[
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _selectedImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error cargando imagen: $error");
                            return Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],

                  // Botón para seleccionar imagen
                  ElevatedButton.icon(
                    onPressed: _seleccionarImagen,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.photo_library),
                    label: Text(
                      _selectedImagePath == null
                          ? 'SELECCIONAR IMAGEN'
                          : 'CAMBIAR IMAGEN',
                    ),
                  ),

                  // Texto informativo
                  if (_usingDefaultImage)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Se usará una URL predeterminada si no seleccionas una imagen',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),

              // Botón enviar
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _enviarSolicitud,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                icon: Icon(Icons.send),
                label: Text(
                  'ENVIAR SOLICITUD',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Mensaje de estado
              if (_mensaje.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _exito ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _exito ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _exito ? Icons.check_circle : Icons.error,
                        color: _exito ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(_mensaje)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
