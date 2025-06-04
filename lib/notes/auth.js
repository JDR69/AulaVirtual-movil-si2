import instance from "./axios";

const tiempoEspera = 10000;

//Login usuario
export const login_request = data => instance.post(`/api/usuario/login/`, data, {
  headers: {
    "Content-Type": "application/json"
  }
})

//USARIOS
export const crearNuevoUsuarioRequest = (data) => instance.post(`/api/usuario/crearUsuario/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const actualizarUsuarioRequest = (data, id) => instance.put(`/api/usuario/actualizarUsuario/${id}/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const obtenerUsuarioRequest = () => {
  return instance.get(`/api/usuario/obtenerUsuario/`,
    { timeout: tiempoEspera }
  )
}

//ROL
export const crearNuevoRolRequest = (data) => instance.post(`/api/usuario/crearRol/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)

export const obtenerRolesRequest = () => { return instance.get(`/api/usuario/obtenerRoles/`, { timeout: tiempoEspera }) }

export const actualizarRolRequest = (data, id) => instance.put(`/api/usuario/actualizarRol/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)

export const eliminarRolRequest = (id) => instance.delete(`/api/usuario/eliminarRol/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})

//RUTAS PRIVILEGIOS
export const nuevoPrivilegioRequest = (data) => instance.post(`/api/usuario/crearPrivilegio/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    },
    withCredentials: true
  }
)

export const obtenerPrivilegiosRequest = () => { return instance.get(`/api/usuario/obtenerPrivilegio/`, { timeout: tiempoEspera }) }

export const actualizarPrivilegioRequest = (data, id) => instance.put(`/api/usuario/actualizarPrivilegio/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)

export const eliminarPrivilegioRequest = (id) => instance.delete(`/api/usuario/eliminarPrivilegio/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})

//RUTAS DE PERMISOS
export const obtenerPermisosRequest = () => { return instance.get(`/api/usuario/obtenerRolesAgrupados/`, { timeout: tiempoEspera }) }

export const actualizarPermisosRequest = (data) => instance.put(`/api/usuario/actualizarEstadoPermiso/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})

//RUTAS DE CURSOS
export const nuevoCursoRequest = (data) => instance.post(`/api/academia/crear-curso/`, data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const actualizarCursoRequest = (data, id) => instance.put(`/api/academia/actualizar-curso/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const eliminarCursoRequest = (id) => instance.delete(`/api/academia/eliminar-curso/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const obtenerCursosRequest = () => { return instance.get(`/api/academia/obtener-cursos/`, { timeout: tiempoEspera }) }

//RUTAS DE NIVELES
export const nuevoNivelRequest = (data) => instance.post(`/api/academia/crear-nivel/`, data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const actualizarNivelRequest = (data, id) => instance.put(`/api/academia/actualizar-nivel/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const eliminarNivelRequest = (id) => instance.delete(`/api/academia/eliminar-nivel/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const obtenerNivelesRequest = () => { return instance.get(`/api/academia/obtener-niveles/`, { timeout: tiempoEspera }) }

//RUTAS DE PARALELOS
export const nuevoParaleloRequest = (data) => instance.post(`/api/academia/crear-paralelo/`, data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const actualizarParaleloRequest = (data, id) => instance.put(`/api/academia/actualizar-paralelo/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const eliminarParaleloRequest = (id) => instance.delete(`/api/academia/eliminar-paralelo/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const obtenerParalelosRequest = () => { return instance.get(`/api/academia/obtener-paralelos/`, { timeout: tiempoEspera }) }

//RUTAS DE MATERIAS
export const nuevoMateriaRequest = (data) => instance.post(`/api/academia/crear-materia/`, data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const actualizarMateriaRequest = (data, id) => instance.put(`/api/academia/actualizar-materia/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const eliminarMateriaRequest = (id) => instance.delete(`/api/academia/eliminar-materia/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const obtenerMateriasRequest = () => { return instance.get(`/api/academia/obtener-materias/`, { timeout: tiempoEspera }) }

//RUTAS DE HORARIOS
export const nuevoHorarioRequest = (data) => instance.post(`/api/academia/crear-horario/`, data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const actualizarHorarioRequest = (data, id) => instance.put(`/api/academia/actualizar-horario/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const eliminarHorarioRequest = (id) => instance.delete(`/api/academia/eliminar-horario/${id}/`, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const obtenerHorariosRequest = () => { return instance.get(`/api/academia/obtener-horarios/`, { timeout: tiempoEspera }) }


//OBTENER DETALLE COMPLETO POR CURSO
export const obtenerDetalleCompletoPorCurso = () => { return instance.get(`/api/academia/obtener/`, { timeout: tiempoEspera }) }

//RUTAS DE DETALLE CURSO MATERIA
export const nuevoDetalleCursoMateriaRequest = (data) => instance.post(`/api/academia/crear-detalle-curso-materia/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)
export const eliminarDetalleCursoMateriaRequest = (dato) =>
  instance.delete('/api/academia/eliminar-detalle-curso-materia/', {
    data: dato,
    headers: {
      'Content-Type': 'application/json',
    },
    withCredentials: true,
  });



//RUTAS DE DETALLE CURSO PARALELO
export const nuevoDetalleCursoParaleloRequest = (data) => instance.post(`/api/academia/crear-detalle-curso-paralelo/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)
export const eliminarDetalleCursoParaleloRequest = (dato) =>
  instance.delete('/api/academia/eliminar-paralelo/', {
    data: dato,
    headers: {
      'Content-Type': 'application/json',
    },
    withCredentials: true,
  });

//DETALLE COMPLETO DE MATERIA PROFESOR
export const nuevoDetalleMateriaRequest = (data) => instance.post(`/api/academia/crear-detalle-materia/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)
export const obtenerDetalleMateriaRequest = () => { return instance.get(`/api/academia/obtener-detalle-materia/`, { timeout: tiempoEspera }) }

//OBTENER DETALLE DE LAS MATERIAS DEL PROFESOR
export const obtenerDetalleMateriaProfesorRequest = (id) => { return instance.get(`/api/usuario/obtenerMateriaProfesor/${id}/`, { timeout: tiempoEspera }) }


// NOTIFICACIONES
export const nuevoNotificacionRequest = (data, id) => instance.post(`/api/periodo/crear-notificacion-uni/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)
export const obtenerNotificacionesRequest = (id) => {
  return instance.get(`/api/periodo/obtener-notificacion-uni/${id}/`,
    {
      timeout: tiempoEspera
    })
}


export const actualizarNotificacionesRequest = (id, data) => instance.put(`/api/periodo/actualizar-notificacion-uni/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
})
export const crearNuevaNotificacionRequest = (data, id) => instance.post(`/api/periodo/crear-notificacion-uni/${id}/`,
  data, {
  headers: {
    "Content-Type": "application/json"
  },
  withCredentials: true
}
)




//GESTIONES
export const crearNuevaGestionRequest = (data) => instance.post(`/api/periodo/crear-gestion/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)

export const obtenerGestionRequest = () => { return instance.get(`/api/periodo/obtener-gestiones/`, { timeout: tiempoEspera }) }

//TRIMESTRE 
export const crearNuevoTrimestreRequest = (data) => instance.post(`/api/periodo/crear-trimestre/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)

// LIBRETA
export const crearLibretaRequest = (data) =>
  instance.post(`/api/academia/crear-libreta/`, data, {
    headers: {
      "Content-Type": "application/json",
    },
  });

//DIMENSION
export const obtenerDimensionRequest = () => {
  return instance.get('/api/evaluaciones/obtener-dimensiones/');
};

//TIPO ACTIVIDADES

export const crearActividadRequest = (data) =>
  instance.post(`/api/evaluaciones/crear-nueva-actividad/`, data, {
    headers: {
      "Content-Type": "application/json",
    },
  });

export const obtenerActividadesRequest = () => { return instance.get(`/api/evaluaciones/obtener-actividades/`, { timeout: tiempoEspera }) }

// TAREA O ACTIVIDAD

export const crearNuevoTareaRequest = (data) => instance.post(`/api/evaluaciones/crear-nueva-tarea/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)


//DIMENSION POR ACTIVIDAD

export const actualizarTareasRequest = (data) => instance.put(`/api/evaluaciones/actualizar-tareas/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const obtenerDimensionAsignadasRequest = ({ id_cursoparalelo, gestion, horario_materia, fecha_inicio, fecha_fin }) => {
  return instance.get('/api/evaluaciones/obtener-actividades-curso2/', {
    params: {
      id_cursoparalelo,
      gestion,
      horario_materia,
      fecha_inicio,
      fecha_fin
    },
    timeout: tiempoEspera
  });
};
export const obtenerAlumnosTareasAsiganadasRequest = ({ id_cursoparalelo, gestion, horario_materia, fecha_inicio, fecha_fin }) => {
  return instance.get('/api/evaluaciones/obtener-actividades-curso/', {
    params: {
      id_cursoparalelo,
      gestion,
      horario_materia,
      fecha_inicio,
      fecha_fin
    },
    timeout: tiempoEspera
  });
};


// ASISTENCIA 

export const crearAsistenciaRequest = (data) => instance.post(`/api/evaluaciones/crear-asistencia/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const actualizarAsistenciaRequest = (data) => instance.put(`/api/evaluaciones/actualizar-asistencia/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const obtenerAlumnosRequest = (anio_escolar,id_cursoparalelo) => {
  return instance.get(`/api/usuario/obtener-alumnos/${anio_escolar}/${id_cursoparalelo}/`, {
    timeout: tiempoEspera
  });
};


export const obtenerAsistenciaRequest = (data) => instance.post(`/api/evaluaciones/obtener-asistencia/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    },
    timeout: tiempoEspera
  }
)

export const obtenerAsistenciPorAlumnoRequest = (id) => { return instance.get(`/api/evaluaciones/obtener-asistencia-gestion/${id}/`,{timeout:tiempoEspera})}


// obtener notas
export const obtenerNotaAlumnosGestionRequest = (id, gestion) => { return instance.get(`/api/evaluaciones/obtener-notas/${id}/${gestion}/`, { timeout: tiempoEspera }) }

// PARTICIPACIONES

export const crearParticipacionesRequest = (data) => instance.post(`/api/periodo/crear-participacion/`,
  data,
  {
    headers: {
      "Content-Type": "application/json"
    }
  }
)
export const obtenerParticipacionesRequest = (id, materia) => {
  return instance.get(`/api/periodo/obtener-participacion/${id}/${materia}/`, {
    timeout: tiempoEspera
  });
};

//DASBOARD

export const obtenerDasboard = () => { return instance.get(`/api/usuario/api/dashboard-stats/`, {timeout:tiempoEspera})}


//bitacora

export const obtenerBitacoraRequestt = () => {return instance.get(`/api/usuario/obtener-bitacora/`,{timeout:tiempoEspera})}