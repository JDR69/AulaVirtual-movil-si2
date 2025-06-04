import React, { useState, useEffect, useRef } from 'react';
import '../../css/Libreta.css';
import { obtenerGestionRequest, obtenerUsuarioRequest, obtenerNotaAlumnosGestionRequest } from '../../../api/auth';
import jsPDF from 'jspdf';
import 'jspdf-autotable';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import html2canvas from 'html2canvas';

function LibretaPage() {
    const [busquedaAlumno, setBusquedaAlumno] = useState('');
    const [sugerencias, setSugerencias] = useState([]);
    const [alumnoSeleccionado, setAlumnoSeleccionado] = useState(null);
    const [alumnos, setAlumnos] = useState([]);
    const [gestiones, setGestiones] = useState([]);
    const [gestionSeleccionada, setGestionSeleccionada] = useState("");
    const [notasData, setNotasData] = useState([]);
    const reportRef = useRef(null);

    // Función para procesar y estructurar los datos de notas
    const procesarDatosNotas = (datosOriginales) => {
        const materiasMap = new Map();

        datosOriginales.forEach(item => {
            const materiaId = item.materia_id;
            const trimestre = item.trimestre.nro;
            const nombreMateria = item.nombre_materia;

            // Calcular promedio de todas las dimensiones para este trimestre
            const promediosValidos = item.dimensiones
                .filter(dim => dim.promedio !== null)
                .map(dim => dim.promedio);

            const promedioTrimestre = promediosValidos.length > 0
                ? (promediosValidos.reduce((sum, val) => sum + val, 0))
                : null;

            if (!materiasMap.has(materiaId)) {
                materiasMap.set(materiaId, {
                    materia_id: materiaId,
                    nombre_materia: nombreMateria,
                    trimestre1: null,
                    trimestre2: null,
                    trimestre3: null
                });
            }

            const materia = materiasMap.get(materiaId);
            materia[`trimestre${trimestre}`] = promedioTrimestre;
        });

        return Array.from(materiasMap.values());
    };

    // Calcular promedio con 2 decimales
    const calcularNotaFinal = (trimestre1, trimestre2, trimestre3) => {
        const notas = [trimestre1, trimestre2, trimestre3].filter(nota => nota !== null);
        if (notas.length === 0) return '0.00';
        const suma = notas.reduce((acc, nota) => acc + nota, 0);
        return (suma / notas.length).toFixed(2);
    };

    // Determina si el alumno aprobó en base al promedio general
    const determinarAprobacion = (materias = []) => {
        if (materias.length === 0) return 'Sin materias';

        let totalPromedio = 0;
        let materiasConNotas = 0;

        for (const materia of materias) {
            const notaFinal = parseFloat(calcularNotaFinal(materia.trimestre1, materia.trimestre2, materia.trimestre3));
            if (notaFinal > 0) {
                if (notaFinal < 51) {
                    return 'Reprobado'; // Si hay al menos una materia reprobada, retorna "Reprobado"
                }
                totalPromedio += notaFinal;
                materiasConNotas++;
            }
        }

        if (materiasConNotas === 0) return 'Sin calificaciones';

        const promedio = totalPromedio / materiasConNotas;
        return promedio >= 50 ? 'Aprobado' : 'Reprobado';
    };

    // Manejar el cambio en el input de búsqueda
    const handleBusquedaChange = (e) => {
        const valor = e.target.value;
        setBusquedaAlumno(valor);
        if (valor.trim().length >= 3) {
            const sugeridos = alumnos.filter((a) =>
                a.nombre.toLowerCase().includes(valor.toLowerCase())
            );
            setSugerencias(sugeridos);
        } else {
            setSugerencias([]);
        }
    };

    const seleccionarAlumno = (alumno) => {
        setBusquedaAlumno(alumno.nombre);
        setAlumnoSeleccionado(alumno);
        setSugerencias([]);
    };

    useEffect(() => {
        if (alumnoSeleccionado && gestionSeleccionada) {
            obtenerNotas();
        }
    }, [alumnoSeleccionado, gestionSeleccionada]);

    const obtenerNotas = async () => {
        try {
            const id = parseInt(alumnoSeleccionado.id);
            const gestion = parseInt(gestionSeleccionada);
            const res = await obtenerNotaAlumnosGestionRequest(id, gestion);
            console.log('Datos originales:', res.data);

            const datosEstructurados = procesarDatosNotas(res.data);
            console.log('Datos estructurados:', datosEstructurados);
            setNotasData(datosEstructurados);
        } catch (error) {
            console.log(error);
        }
    };

    const fetchData = async () => {
        try {
            const [gestionesRes, usuariosRes] = await Promise.all([
                obtenerGestionRequest(),
                obtenerUsuarioRequest(),
            ]);

            setGestiones(gestionesRes.data);
            const alumnosFiltrados = usuariosRes.data.filter((usuario) => usuario.rol_nombre === 'Alumno');
            setAlumnos(alumnosFiltrados);
        } catch (error) {
            console.error('Error al obtener datos:', error);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    // Función para exportar a PDF
    const exportToPDF = () => {
        if (!alumnoSeleccionado) return;
        
        const doc = new jsPDF();
        
        // Añadir título
        doc.setFontSize(18);
        doc.setTextColor(63, 81, 181);
        doc.text('Libreta de Calificaciones', 105, 15, { align: 'center' });
        
        // Añadir info del alumno
        doc.setFontSize(12);
        doc.setTextColor(0, 0, 0);
        doc.text(`Alumno: ${alumnoSeleccionado.alumno?.nombre_usuario || alumnoSeleccionado.nombre}`, 14, 30);
        doc.text(`CI: ${alumnoSeleccionado.ci}`, 14, 37);
        doc.text(`Gestión: ${gestionSeleccionada}`, 14, 44);
        doc.text(`Estado del Curso: ${determinarAprobacion(notasData)}`, 14, 51);
        
        // Crear tabla de calificaciones
        const tableColumn = ["Materia", "1er Trimestre", "2do Trimestre", "3er Trimestre", "Nota Final", "Estado"];
        const tableRows = [];
        
        notasData.forEach(materia => {
            const notaFinal = parseFloat(
                calcularNotaFinal(
                    materia.trimestre1,
                    materia.trimestre2,
                    materia.trimestre3
                )
            );
            const estado = notaFinal >= 60 ? 'Aprobado' : (notaFinal > 0 ? 'Reprobado' : 'Sin calificar');
            
            const row = [
                materia.nombre_materia,
                materia.trimestre1 ? materia.trimestre1.toFixed(2) : '-',
                materia.trimestre2 ? materia.trimestre2.toFixed(2) : '-',
                materia.trimestre3 ? materia.trimestre3.toFixed(2) : '-',
                notaFinal > 0 ? notaFinal.toFixed(2) : '-',
                estado
            ];
            tableRows.push(row);
        });
        
        // Generar tabla
        doc.autoTable({
            head: [tableColumn],
            body: tableRows,
            startY: 60,
            theme: 'grid',
            styles: {
                fontSize: 10,
                cellPadding: 3,
                halign: 'center'
            },
            headStyles: {
                fillColor: [63, 81, 181],
                textColor: [255, 255, 255],
                fontStyle: 'bold'
            },
            alternateRowStyles: {
                fillColor: [245, 247, 250]
            }
        });
        
        // Añadir fecha al pie de página
        const fecha = new Date().toLocaleDateString();
        doc.setFontSize(8);
        doc.setTextColor(128, 128, 128);
        doc.text(`Fecha de impresión: ${fecha}`, 14, doc.internal.pageSize.height - 10);
        
        // Guardar el PDF
        doc.save(`Libreta_${alumnoSeleccionado.nombre}_${gestionSeleccionada}.pdf`);
    };
    
    // Función para exportar a Excel
    const exportToExcel = () => {
        if (!alumnoSeleccionado) return;
        
        const workbook = XLSX.utils.book_new();
        
        // Preparar datos de cabecera (información del alumno)
        const headerData = [
            [`Libreta de Calificaciones - ${alumnoSeleccionado.alumno?.nombre_usuario || alumnoSeleccionado.nombre}`],
            [`CI: ${alumnoSeleccionado.ci}`],
            [`Gestión: ${gestionSeleccionada}`],
            [`Estado del Curso: ${determinarAprobacion(notasData)}`],
            [""],  // Línea vacía de separación
        ];
        
        // Preparar datos de tabla
        const tableData = [
            ["Materia", "1er Trimestre", "2do Trimestre", "3er Trimestre", "Nota Final", "Estado"]
        ];
        
        notasData.forEach(materia => {
            const notaFinal = parseFloat(
                calcularNotaFinal(
                    materia.trimestre1,
                    materia.trimestre2,
                    materia.trimestre3
                )
            );
            const estado = notaFinal >= 60 ? 'Aprobado' : (notaFinal > 0 ? 'Reprobado' : 'Sin calificar');
            
            tableData.push([
                materia.nombre_materia,
                materia.trimestre1 ? materia.trimestre1.toFixed(2) : '-',
                materia.trimestre2 ? materia.trimestre2.toFixed(2) : '-',
                materia.trimestre3 ? materia.trimestre3.toFixed(2) : '-',
                notaFinal > 0 ? notaFinal.toFixed(2) : '-',
                estado
            ]);
        });
        
        // Combinar datos de cabecera y tabla
        const allData = [...headerData, ...tableData];
        
        // Crear hoja de Excel
        const worksheet = XLSX.utils.aoa_to_sheet(allData);
        
        // Añadir hoja al libro
        XLSX.utils.book_append_sheet(workbook, worksheet, "Libreta");
        
        // Generar archivo Excel
        const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
        const data = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        
        // Guardar archivo
        saveAs(data, `Libreta_${alumnoSeleccionado.nombre}_${gestionSeleccionada}.xlsx`);
    };
    
    // Función para exportar a HTML
    const exportToHTML = () => {
        if (!alumnoSeleccionado || !reportRef.current) return;
        
        html2canvas(reportRef.current).then(canvas => {
            // Convertir el elemento a imagen
            const imgData = canvas.toDataURL('image/png');
            
            // Crear plantilla HTML
            const htmlTemplate = `
            <!DOCTYPE html>
            <html lang="es">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Libreta de Calificaciones - ${alumnoSeleccionado.nombre}</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    h1 { color: #3f51b5; text-align: center; }
                    .reporte-container { max-width: 900px; margin: 0 auto; }
                    .fecha { color: #777; font-size: 12px; text-align: right; margin-top: 30px; }
                </style>
            </head>
            <body>
                <div class="reporte-container">
                    <h1>Libreta de Calificaciones</h1>
                    <img src="${imgData}" alt="Libreta de Calificaciones" style="max-width: 100%;">
                    <div class="fecha">Fecha de exportación: ${new Date().toLocaleDateString()}</div>
                </div>
            </body>
            </html>
            `;
            
            // Crear blob y descargar
            const blob = new Blob([htmlTemplate], { type: 'text/html' });
            saveAs(blob, `Libreta_${alumnoSeleccionado.nombre}_${gestionSeleccionada}.html`);
        });
    };

    return (
        <div className='contenedor-principal'>
            <div className="contenedor-secundario">
                <div className="libreta-container">
                    <div className="libreta-header">
                        <h1>Libreta de Calificaciones</h1>

                        <div>
                            <h3>Seleccionar Gestión</h3>
                            <select
                                name="gestion"
                                className="form-select"
                                value={gestionSeleccionada}
                                onChange={(e) => setGestionSeleccionada(e.target.value)}
                                required
                            >
                                <option value="">Seleccionar la Gestión</option>
                                {gestiones.map((gestion) => (
                                    <option key={gestion.gestion} value={gestion.anio_escolar}>
                                        {gestion.anio_escolar}
                                    </option>
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
                                required
                                id="busqueda"
                            />
                            {busquedaAlumno.trim().length >= 3 && sugerencias.length > 0 && (
                                <ul className="sugerencias">
                                    {sugerencias.map((alumno) => (
                                        <li
                                            key={alumno.id}
                                            onClick={() => seleccionarAlumno(alumno)}
                                            className="sugerencia-item"
                                        >
                                            {alumno.nombre}
                                        </li>
                                    ))}
                                </ul>
                            )}
                        </div>
                    </div>

                    {alumnoSeleccionado && (
                        <div className="libreta-datos">
                          {/* Botones de exportación */}
                          <div className="jdr2-export-buttons">
                            <button
                              className="jdr2-export-btn jdr2-pdf-btn"
                              onClick={exportToPDF}
                              title="Exportar a PDF"
                            >
                              <i className="fas fa-file-pdf"></i> PDF
                            </button>
                            <button
                              className="jdr2-export-btn jdr2-excel-btn"
                              onClick={exportToExcel}
                              title="Exportar a Excel"
                            >
                              <i className="fas fa-file-excel"></i> Excel
                            </button>
                            <button
                              className="jdr2-export-btn jdr2-html-btn"
                              onClick={exportToHTML}
                              title="Exportar a HTML"
                            >
                              <i className="fas fa-file-code"></i> HTML
                            </button>
                          </div>

                          {/* Datos del Alumno */}
                          <div className="jdr1-datos-alumno-card">
                            <div className="jdr1-datos-alumno-header">
                              <h2>Datos del Alumno</h2>
                            </div>
                            <div className="jdr1-datos-alumno-body">
                              <div className="jdr1-alumno-info-item">
                                <span className="jdr1-alumno-info-label">Nombre Completo:</span>
                                <span className="jdr1-alumno-info-value">
                                  {alumnoSeleccionado.alumno?.nombre_usuario || alumnoSeleccionado.nombre}
                                </span>
                              </div>
                              <div className="jdr1-alumno-info-item">
                                <span className="jdr1-alumno-info-label">CI:</span>
                                <span className="jdr1-alumno-info-value">{alumnoSeleccionado.ci}</span>
                              </div>
                              <div className="jdr1-alumno-info-item">
                                <span className="jdr1-alumno-info-label">Estado del Curso:</span>
                                <span
                                  className={`jdr1-estado-curso ${
                                    determinarAprobacion(notasData) === "Aprobado"
                                      ? "jdr1-estado-aprobado"
                                      : determinarAprobacion(notasData) === "Reprobado"
                                      ? "jdr1-estado-reprobado"
                                      : "jdr1-estado-sin-calificar"
                                  }`}
                                >
                                  {determinarAprobacion(notasData)}
                                </span>
                              </div>
                            </div>
                          </div>

                          {/* Tabla de Calificaciones */}
                          <div className="jdr2-tabla-container">
                            <h2>Materias y Calificaciones</h2>
                            <table className="jdr2-tabla-calificaciones">
                              <thead>
                                <tr>
                                  <th>Materia</th>
                                  <th>1er Trimestre</th>
                                  <th>2do Trimestre</th>
                                  <th>3er Trimestre</th>
                                  <th>Nota Final</th>
                                  <th>Estado</th>
                                </tr>
                              </thead>
                              <tbody>
                                {notasData.map((materia, index) => {
                                  const notaFinal = parseFloat(
                                    calcularNotaFinal(
                                      materia.trimestre1,
                                      materia.trimestre2,
                                      materia.trimestre3
                                    )
                                  );
                                  const estado =
                                    notaFinal >= 50
                                      ? "Aprobado"
                                      : notaFinal > 0
                                      ? "Reprobado"
                                      : "Sin calificar";

                                  return (
                                    <tr key={index}>
                                      <td>{materia.nombre_materia}</td>
                                      <td>{materia.trimestre1 ? materia.trimestre1.toFixed(2) : "-"}</td>
                                      <td>{materia.trimestre2 ? materia.trimestre2.toFixed(2) : "-"}</td>
                                      <td>{materia.trimestre3 ? materia.trimestre3.toFixed(2) : "-"}</td>
                                      <td>{notaFinal > 0 ? notaFinal.toFixed(2) : "-"}</td>
                                      <td
                                        className={`jdr2-estado-${
                                          estado === "Aprobado"
                                            ? "aprobado"
                                            : estado === "Reprobado"
                                            ? "reprobado"
                                            : "sin-calificar"
                                        }`}
                                      >
                                        {estado}
                                      </td>
                                    </tr>
                                  );
                                })}
                              </tbody>
                            </table>
                          </div>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

export default LibretaPage;