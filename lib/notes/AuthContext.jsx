import { createContext, useState, useContext, useEffect } from "react";
import {
    login_request,
    obtenerUsuarioRequest,
    obtenerRolesRequest,
    obtenerPrivilegiosRequest,
    obtenerPermisosRequest,
    obtenerCursosRequest,
    obtenerMateriasRequest,
    obtenerHorariosRequest,
    obtenerNivelesRequest,
    obtenerParalelosRequest,
    obtenerDetalleCompletoPorCurso,
    obtenerGestionRequest
} from "../api/auth";

const AuthContext = createContext();

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error("useAuth must be used within an AuthProvider");
    }
    return context;
};

export const AuthProvider = ({ children }) => {
    // Recuperar materiaProfesor del localStorage al iniciar
    const [materiaProfesor, setMateriaProfesorState] = useState(() => {
        const savedMateria = localStorage.getItem('materiaProfesor');
        return savedMateria ? JSON.parse(savedMateria) : null;
    });

    // Función para actualizar materiaProfesor y guardarlo en localStorage
    const setMateriaProfesor = (materia) => {
        setMateriaProfesorState(materia);
        if (materia) {
            localStorage.setItem('materiaProfesor', JSON.stringify(materia));
            console.log("Materia guardada en localStorage:", materia);
        } else {
            localStorage.removeItem('materiaProfesor');
        }
    };

    const [directorOk, setDirectorOK] = useState(null);

    // Inicializar user desde localStorage si está disponible
    const [user, setUser] = useState(() => {
        const savedUser = localStorage.getItem("usuario");
        return savedUser ? JSON.parse(savedUser) : null;
    });

    //Variables Usuarios
    const [usuarios, setUsuarios] = useState(null);
    const [permisosDelUsuario, setPermisosDelUsuario] = useState(null);
    const [roles, setRoles] = useState([]);
    const [privilegios, setPrivilegios] = useState([]);
    const [permisos, setPermisos] = useState([]);

    //Variables Academia
    const [cursos, setCursos] = useState([]);
    const [materias, setMaterias] = useState([]);
    const [horarios, setHorarios] = useState([]);
    const [niveles, setNiveles] = useState([]);
    const [paralelos, setParalelos] = useState([]);
    const [gestion, setGestion] = useState([]);

    //DETALLE CURSO
    const [detalleCompleto, setDetalleCompleto] = useState([]);

    const signin = async (user) => {
        try {
            const res = await login_request(user);
            console.log(res.data);

            const userData = res.data.usuario;
            setUser(userData);
            setPermisosDelUsuario(res.data.permisos);

            // Guardamos el usuario en localStorage
            localStorage.setItem("usuario", JSON.stringify(userData));

            // Si hay un curso guardado para un usuario diferente, lo eliminamos
            const savedMateria = localStorage.getItem('materiaProfesor');
            if (savedMateria) {
                const materiaData = JSON.parse(savedMateria);
                if (materiaData && materiaData.profesor_id !== userData.id) {
                    localStorage.removeItem('materiaProfesor');
                    setMateriaProfesorState(null);
                }
            }

            return userData.rol_nombre;
        } catch (err) {
            throw err;
        }
    };


    
    // Estado para el curso seleccionado
    const [cursoSeleccionado, setCursoSeleccionado] = useState(() => {
        const savedCurso = localStorage.getItem('cursoSeleccionado');
        return savedCurso ? JSON.parse(savedCurso) : null;
    });
    const setCursoYParalelo = (curso) => {
        setCursoSeleccionado(curso);
        if (curso) {
            localStorage.setItem('cursoSeleccionado', JSON.stringify(curso));
            console.log("Curso y paralelo guardados en localStorage:", curso);
        } else {
            localStorage.removeItem('cursoSeleccionado');
        }
    };



    // Función de logout que limpia los estados y localStorage
    const logout = () => {
        localStorage.removeItem('materiaProfesor');
        localStorage.removeItem('usuario');
        setMateriaProfesorState(null);
        setUser(null);
    };

    const cargarDatos = async () => {
        try {
            const [
                resUsuarios,
                resRoles,
                resPrivilegios,
                resPermisos,
                resCursos,
                resMaterias,
                resParalelos,
                resHorarios,
                resNiveles,
                resDetalleCurso
            ] = await Promise.all([
                obtenerUsuarioRequest(),
                obtenerRolesRequest(),
                obtenerPrivilegiosRequest(),
                obtenerPermisosRequest(),
                obtenerCursosRequest(),
                obtenerMateriasRequest(),
                obtenerParalelosRequest(),
                obtenerHorariosRequest(),
                obtenerNivelesRequest(),
                obtenerDetalleCompletoPorCurso(),
            ]);

            setUsuarios(resUsuarios.data);
            setRoles(resRoles.data);
            setPrivilegios(resPrivilegios.data);
            setPermisos(resPermisos.data);
            setCursos(resCursos.data);
            setMaterias(resMaterias.data);
            setParalelos(resParalelos.data);
            setHorarios(resHorarios.data);
            setNiveles(resNiveles.data);
            setDetalleCompleto(resDetalleCurso.data);
        } catch (err) {
            console.error("Error cargando datos:", err);
            throw err;
        }
    };

    const cargarGestion = async () => {
        try {
            // Verificar si ya existe una gestión en localStorage
            const savedGestion = localStorage.getItem('gestion');
            if (savedGestion) {
                setGestion(JSON.parse(savedGestion));
                console.log("Gestión cargada desde localStorage:", JSON.parse(savedGestion));
                return;
            }

            // Si no existe, obtener la gestión más reciente desde la API
            const gest = await obtenerGestionRequest();
            const mayor = gest.data.reduce((max, actual) =>
                actual.anio_escolar > max.anio_escolar ? actual : max
            );
            console.log("Gestión más reciente:", mayor);

            // Guardar la gestión en el estado y en localStorage
            setGestion(mayor);
            localStorage.setItem('gestion', JSON.stringify(mayor));
        } catch (error) {
            console.error("Error al cargar la gestión:", error);
        }
    };

    useEffect(() => {
        async function checklogin() {
            const token = localStorage.getItem('token');
            const savedUser = localStorage.getItem("usuario");

            if (savedUser) {
                setUser(JSON.parse(savedUser));
                await cargarDatos();
            }
        }

        checklogin();
        cargarGestion(); // Cargar la gestión más reciente al iniciar la aplicación
    }, []);

    return (
        <AuthContext.Provider value={{
            signin,
            logout,
            cursos,
            setCursos,
            materias,
            setMaterias,
            horarios,
            setHorarios,
            niveles,
            setNiveles,
            paralelos,
            setParalelos,

            roles,
            setRoles,
            privilegios,
            setPrivilegios,
            permisos,
            setPermisos,
            usuarios,
            setUsuarios,

            detalleCompleto,

            materiaProfesor,
            setMateriaProfesor,

            user,
            setUser,

            setDirectorOK,
            directorOk,

            cursoSeleccionado,
            setCursoYParalelo,

            gestion,
            setGestion,
            cargarGestion, // Exponer la función para cargar gestión si es necesario
        }}>
            {children}
        </AuthContext.Provider>
    );
};