import React, { useState, useEffect } from 'react';
import { useAuth } from '../../../context/AuthContext';
import "../../css/PerfilUsuarioPage.css";
import { obtenerUsuarioRequest } from '../../../api/auth';

const PerfilUsuarioPage = () => {
  const { user: authUser } = useAuth(); // Obtener el usuario autenticado del contexto
  const [isEditing, setIsEditing] = useState(false);
  const [user, setUser] = useState({
    nombre: '',
    ci: '',
    fechaNacimiento: '',
    sexo: '',
    telefono: '',
    estado: '',
    rol_nombre: '',
    matricula: '',
    especialidad: ''
  });
  const [loading, setLoading] = useState(true);

  // Este efecto se ejecutará cuando cambie el usuario autenticado
  useEffect(() => {
    const fetchUser = async () => {
      if (!authUser || !authUser.id) {
        console.log("No hay usuario autenticado o falta ID");
        setLoading(false);
        return;
      }

      try {
        setLoading(true);
        console.log("Obteniendo datos del usuario:", authUser.id);
        
        // Obtenemos todos los usuarios
        const res = await obtenerUsuarioRequest();
        const allUsers = Array.isArray(res.data) ? res.data : [res.data];
        
        // Filtramos para encontrar el usuario con el ID que buscamos
        const userData = allUsers.find(u => u.id === authUser.id);
        
        if (!userData) {
          console.error("Usuario no encontrado");
          setLoading(false);
          return;
        }
        
        console.log("Datos obtenidos:", userData);
        
        setUser({
          nombre: userData.nombre || '',
          ci: userData.ci || '',
          fechaNacimiento: userData.fecha_nacimiento || '',
          sexo: userData.sexo || '',
          estado: userData.estado ? 'Activo' : 'Inactivo',
          rol_nombre: userData.rol_nombre || '',
          matricula: userData.alumno?.matricula || '',
          telefono: userData.telefono || '',
          especialidad: userData.profesor?.especialidad || ''
        });
        setLoading(false);
      } catch (error) {
        console.error('Error al obtener usuario:', error);
        setLoading(false);
      }
    };
    
    fetchUser();
  }, [authUser]); // Ejecutar cuando cambie el usuario autenticado

  const handleChange = (e) => {
    const { name, value } = e.target;
    setUser({ ...user, [name]: value });
  };

  const handleEdit = () => {
    if (isEditing) {
      // Lógica para guardar los cambios
      // Aquí se implementaría la llamada a la API para actualizar los datos
      console.log("Guardando cambios:", user);
      // Por ahora solo cambiamos el modo
    }
    
    setIsEditing(!isEditing);
  };

  return (
    <div className='contenedor-principal'>
      <div className='contenedor-secundario'>
        <h1>Perfil de Usuario</h1>
        
        {loading ? (
          <div className="d-flex justify-content-center">
            <div className="spinner-border text-primary" role="status">
              <span className="visually-hidden">Cargando...</span>
            </div>
          </div>
        ) : (
          <>
            <div className='contenedor-perfil'>
              <div className="mb-3">
                <label>Nombre:</label>
                <input
                  type="text"
                  className="form-control"
                  name="nombre"
                  value={user.nombre}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
              <div className="mb-3">
                <label>Rol:</label>
                <input
                  type="text"
                  className="form-control"
                  name="rol_nombre"
                  value={user.rol_nombre}
                  onChange={handleChange}
                  disabled={true} // El rol no se puede cambiar
                />
              </div>
              <div className="mb-3">
                <label>CI:</label>
                <input
                  type="text"
                  className="form-control"
                  name="ci"
                  value={user.ci}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
              <div className="mb-3">
                <label>Teléfono:</label>
                <input
                  type="text"
                  className="form-control"
                  name="telefono"
                  value={user.telefono}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
              {/* Solo mostrar matrícula si es alumno */}
              {user.rol_nombre === "Alumno" && (
                <div className="mb-3">
                  <label>Matricula:</label>
                  <input
                    type="text"
                    className="form-control"
                    name="matricula"
                    value={user.matricula}
                    onChange={handleChange}
                    disabled={!isEditing}
                  />
                </div>
              )}
              <div className="mb-3">
                <label>Fecha de Nacimiento:</label>
                <input
                  type="date"
                  className="form-control"
                  name="fechaNacimiento"
                  value={user.fechaNacimiento}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
              <div className="mb-3">
                <label>Sexo:</label>
                <input
                  type="text"
                  className="form-control"
                  name="sexo"
                  value={user.sexo}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
              {/* Solo mostrar especialidad si es profesor */}
              {user.rol_nombre === "Profesor" && (
                <div className="mb-3">
                  <label>Especialidad:</label>
                  <input
                    type="text"
                    className="form-control"
                    name="especialidad"
                    value={user.especialidad}
                    onChange={handleChange}
                    disabled={!isEditing}
                  />
                </div>
              )}
              <div className="mb-3">
                <label>Estado:</label>
                <input
                  type="text"
                  className="form-control"
                  name="estado"
                  value={user.estado}
                  onChange={handleChange}
                  disabled={!isEditing}
                />
              </div>
            </div>
            <div className='contenedor-button'>
              <button
                type="button"
                className="btn btn-primary"
                onClick={handleEdit}
              >
                {isEditing ? 'Guardar' : 'Editar'}
              </button>
              {isEditing && (
                <button
                  type="button"
                  className="btn btn-warning"
                  onClick={() => setIsEditing(false)}
                >
                  Cancelar
                </button>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default PerfilUsuarioPage;