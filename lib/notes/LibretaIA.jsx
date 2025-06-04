import React, { useState, useEffect } from 'react';
import '../../css/LibretaIA.css';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  ResponsiveContainer
} from 'recharts';
import { AlertCircle, Brain } from 'lucide-react';
import {
  obtenerGestionRequest,
  obtenerUsuarioRequest,
  obtenerNotaAlumnosGestionRequest
} from '../../../api/auth';

function calcularTotal(dimensiones) {
  const promediosValidos = dimensiones
    .filter(d => d.promedio !== null && d.promedio !== undefined)
    .map(d => d.promedio);

  if (promediosValidos.length === 0) return 0;
  
  const suma = promediosValidos.reduce((a, b) => a + b, 0);
  return parseFloat((suma).toFixed(2));
}


function predecirNota(datos) {
  if (datos.length < 2) return null;
  const x = datos.map((_, i) => i + 1);
  const y = datos.map(d => d.promedio);
  const n = x.length;
  const sumX = x.reduce((a, b) => a + b, 0);
  const sumY = y.reduce((a, b) => a + b, 0);
  const sumXY = x.reduce((acc, val, i) => acc + val * y[i], 0);
  const sumXX = x.reduce((acc, val) => acc + val * val, 0);
  const m = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  const b = (sumY - m * sumX) / n;
  const nextX = n + 1;
  return parseFloat((m * nextX + b).toFixed(2));
}

function generarComentario(datos) {
  if (datos.length < 2) return "No hay suficientes datos para analizar la evolución del estudiante.";
  const inicio = datos[0].promedio;
  const fin = datos[datos.length - 1].promedio;
  const tendencia = fin - inicio;

  if (tendencia > 5) {
    return `El estudiante muestra una mejora notable en su desempeño, subiendo de ${inicio} a ${fin}. Se espera que continúe con buenos resultados si mantiene este ritmo.`;
  } else if (tendencia > 0) {
    return `El estudiante presenta una leve mejora, pasando de ${inicio} a ${fin}. Puede reforzar su estudio para acelerar el progreso.`;
  } else if (tendencia === 0) {
    return `El promedio del estudiante se ha mantenido constante (${inicio}). Es recomendable implementar nuevas estrategias de aprendizaje.`;
  } else {
    return `El rendimiento del estudiante ha disminuido de ${inicio} a ${fin}. Se sugiere intervención pedagógica para mejorar su desempeño.`;
  }
}

function LibretaIA() {
  const [busquedaAlumno, setBusquedaAlumno] = useState('');
  const [sugerencias, setSugerencias] = useState([]);
  const [alumnoSeleccionado, setAlumnoSeleccionado] = useState(null);
  const [datosNotas, setDatosNotas] = useState({});
  const [materiaSeleccionada, setMateriaSeleccionada] = useState('');
  const [alumnos, setAlumnos] = useState([]);
  const [cantidadGestiones, setCantidadGestiones] = useState('');
  const [numeroGestiones, setNumeroGestiones] = useState([]);
  const [gestiones, setGestiones] = useState([]);

  const fetchData = async () => {
    try {
      const [gestionesRes, usuariosRes] = await Promise.all([
        obtenerGestionRequest(),
        obtenerUsuarioRequest(),
      ]);
      if (gestionesRes.data) {
        const cantidad = Array.from({ length: gestionesRes.data.length }, (_, i) => i + 1);
        setNumeroGestiones(cantidad);
        setGestiones(gestionesRes.data);
      }
      const alumnosFiltrados = usuariosRes.data.filter(u => u.rol_nombre === 'Alumno');
      setAlumnos(alumnosFiltrados);
    } catch (error) {
      console.error('Error al obtener datos:', error);
    }
  };

  useEffect(() => { fetchData(); }, []);

  const handleBusquedaChange = (e) => {
    const valor = e.target.value;
    setBusquedaAlumno(valor);
    setSugerencias(valor.trim().length >= 3
      ? alumnos.filter(a => a.nombre.toLowerCase().includes(valor.toLowerCase()))
      : []);
  };

  const seleccionarAlumno = (alumno) => {
    setBusquedaAlumno(alumno.nombre);
    setAlumnoSeleccionado(alumno);
    setSugerencias([]);
    setDatosNotas({});
    setMateriaSeleccionada('');
  };

  useEffect(() => {
    if (alumnoSeleccionado && cantidadGestiones) {
      obtenerDatosAlumno(alumnoSeleccionado.id, cantidadGestiones);
    }
  }, [alumnoSeleccionado, cantidadGestiones]);

  const obtenerDatosAlumno = async (alumnoId, cantidadGestiones) => {
    try {
      const seleccionadas = gestiones.slice(0, cantidadGestiones);
      const promesas = seleccionadas.map(async (g) => {
        try {
          const res = await obtenerNotaAlumnosGestionRequest(alumnoId, g.anio_escolar);
          return { anio: g.anio_escolar, datos: res.data };
        } catch {
          return { anio: g.anio_escolar, datos: [] };
        }
      });
      const resultados = await Promise.all(promesas);
      const agrupado = {};
      resultados.forEach(({ anio, datos }) => { agrupado[anio] = datos; });
      setDatosNotas(agrupado);
    } catch (error) {
      console.error("Error general al obtener datos del alumno:", error);
    }
  };

  const gestionesDisponibles = Object.keys(datosNotas);
  const renderGrafica = () => {
    if (!materiaSeleccionada || gestionesDisponibles.length === 0) return null;

    const datosMateria = gestionesDisponibles.map(anio => {
        const notas = datosNotas[anio].filter(d => d.nombre_materia === materiaSeleccionada);
        const totalNotas = notas.flatMap(n => n.dimensiones).reduce((acc, dim) => acc + (dim.promedio || 0), 0);
        const cantidadTrimestres = notas.length > 0 ? notas.length : 1; 
        const promedioFinal = cantidadTrimestres > 0 ? totalNotas / cantidadTrimestres : null;

        return { anio, promedio: promedioFinal ? parseFloat(promedioFinal.toFixed(2)) : null };
    }).filter(d => d.promedio !== null);

   
    const prediccion = predecirNota(datosMateria);
    if (prediccion !== null) {
        const proximoAnio = (parseInt(gestionesDisponibles[gestionesDisponibles.length - 1]) + 1).toString();
        datosMateria.push({ anio: proximoAnio, promedio: prediccion });
    }

    // Generar un comentario más dinámico y atractivo
    const comentario = generarComentario(datosMateria);

    return (
        <>
            <div className="grafica-container">
                <h3>Desempeño en {materiaSeleccionada} por gestión</h3>
                <ResponsiveContainer width="100%" height={300}>
                    <LineChart data={datosMateria}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis dataKey="anio" />
                        <YAxis />
                        <Tooltip />
                        <Legend />
                        <Line type="monotone" dataKey="promedio" stroke="#8884d8" activeDot={{ r: 8 }} />
                    </LineChart>
                </ResponsiveContainer>
            </div>
            
            <div className="comentario-desempeno">
                <div className="comentario-card">
                    <div className="comentario-header">
                        <Brain size={24} />
                        <h4>Análisis de IA</h4>
                    </div>
                    <div className="comentario-contenido">
                        <p className="comentario-texto">{comentario}</p>
                        
                        {prediccion !== null && (
                            <div className="prediccion-container">
                                <h5>Predicción para el próximo año:</h5>
                                <div className="prediccion-valor">
                                    <span className="badge">{prediccion}</span>
                                    <span className="tendencia">
                                        {datosMateria.length >= 2 && 
                                         prediccion > datosMateria[datosMateria.length-2].promedio ? 
                                         '↗️ En ascenso' : '↘️ En descenso'}
                                    </span>
                                </div>
                            </div>
                        )}
                        
                        <div className="recomendacion-container">
                            <h5>Recomendaciones:</h5>
                            <ul className="recomendacion-lista">
                                <li>Continuar con el plan de estudio personalizado</li>
                                <li>Reforzar los conceptos fundamentales de la materia</li>
                                <li>Implementar técnicas de estudio activo</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
  };

  const materiasDisponibles = gestionesDisponibles.length > 0
    ? [...new Set(
        gestionesDisponibles.flatMap(anio =>
          datosNotas[anio].map(n => n.nombre_materia)
        )
      )]
    : [];

  return (
    <div className="libreta-ia">
      <div className="header">
        <h1><Brain className="icono-header" /> LibretaIA Predictiva</h1>
        <p>Predicción académica anual basada en datos reales</p>
      </div>

      <div className="gestiones-selector">
        <label htmlFor="gestiones">Cantidad de gestiones a considerar:</label>
        <select id="gestiones" className='form-select' value={cantidadGestiones} onChange={(e) => setCantidadGestiones(Number(e.target.value))}>
          <option value="">Sin selección</option>
          {numeroGestiones.map((g, i) => (
            <option key={i} value={g}>{g}</option>
          ))}
        </select>
      </div>

      <div className="acomodar">
        <h3>Buscar Alumno</h3>
        <input
          type="text"
          className="form-control"
          value={busquedaAlumno}
          onChange={handleBusquedaChange}
          placeholder="Ej: Juan Pérez"
          autoComplete="off"
        />
        {busquedaAlumno.trim().length >= 3 && sugerencias.length > 0 && (
          <ul className="sugerencias">
            {sugerencias.map((alumno) => (
              <li key={alumno.id} onClick={() => seleccionarAlumno(alumno)} className="sugerencia-item">
                {alumno.nombre}
              </li>
            ))}
          </ul>
        )}
      </div>

      {materiasDisponibles.length > 0 && (
        <div className="materias-selector">
          <label htmlFor="materias">Seleccione una materia:</label>
          <select
            id="materias"
            value={materiaSeleccionada}
            onChange={(e) => setMateriaSeleccionada(e.target.value)}
          >
            <option value="">-- Seleccione --</option>
            {materiasDisponibles.map((materia, index) => (
              <option key={index} value={materia}>{materia}</option>
            ))}
          </select>
        </div>
      )}

      {renderGrafica()}
    </div>
  );
}

export default LibretaIA;