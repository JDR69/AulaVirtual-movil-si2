import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../services/api_service.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  bool _isLoading = true;
  List<dynamic> _notificaciones = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      setState(() => _isLoading = true);

      // Obtener ID del usuario desde el provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null || !userProvider.user!.containsKey('id')) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se pudo obtener el ID del usuario';
        });
        return;
      }

      final userId = userProvider.user!['id'];
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'ID de usuario no válido';
        });
        return;
      }

      // Obtener notificaciones desde la API
      final response = await ApiService.getNotifications(userId);
      if (response != null) {
        // Imprimir la respuesta para depuración
        print('Respuesta de notificaciones: $response');

        List<dynamic> notificacionesList = [];

        // Si la respuesta ya es una lista, usarla directamente
        if (response is List) {
          notificacionesList = response;
        }
        // Si la respuesta es un único objeto de notificación
        else if (response is Map) {
          notificacionesList.add(response);
        }

        setState(() {
          _notificaciones = notificacionesList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se pudieron cargar las notificaciones';
        });
      }
    } catch (e) {
      print('Error al cargar notificaciones: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarNotificaciones,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _buildNotificacionesList(),
    );
  }

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
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarNotificaciones,
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

  Widget _buildNotificacionesList() {
    if (_notificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 70, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes notificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarNotificaciones,
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: _notificaciones.length,
        itemBuilder: (context, index) {
          final notificacion = _notificaciones[index];
          return _buildNotificacionCard(notificacion);
        },
      ),
    );
  }

  Widget _buildNotificacionCard(dynamic notificacion) {
    // Obtener el objeto de notificación interno
    final notificacionData = notificacion['notificaciones'];

    if (notificacionData == null) {
      print('Error: no hay datos de notificación en: $notificacion');
      return SizedBox.shrink(); // Si no hay datos, no mostramos nada
    }

    // Obtener los valores del objeto interno
    final String titulo = notificacionData['titulo'] ?? 'Notificación';
    final String mensaje = notificacionData['mensaje'] ?? 'Sin contenido';
    final String fechaStr =
        notificacionData['fecha'] ?? DateTime.now().toString();

    // Formatear la fecha
    DateTime fecha;
    try {
      fecha = DateTime.parse(fechaStr);
    } catch (e) {
      print('Error al parsear fecha: $e para fecha: $fechaStr');
      fecha = DateTime.now();
    }

    final String fechaFormateada = "${fecha.day}/${fecha.month}/${fecha.year}";

    // Mostrar una tarjeta más atractiva
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(mensaje, style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            Text(
              fechaFormateada,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
