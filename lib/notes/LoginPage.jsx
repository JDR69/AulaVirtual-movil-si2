import React, { useState, useEffect} from 'react'
import '../css/LoginPageCss.css'
import { useAuth } from '../../context/AuthContext'
import { useNavigate } from 'react-router-dom'

const LoginPage = () => {

    const navigate = useNavigate();
    const [loading,setLoading] = useState(false)
    const { signin,setDirectorOK} = useAuth();

    const [data, setData] = useState({
        ci: '',
        password: '',
    });

    const loguearse = async() =>{
        try {
            setLoading(true)
            const res = await signin(data)
            if(res){
                if(res === "Profesor"){
                    navigate('/dasboard/seleccionar-curso')
                }else{
                    navigate('/dasboard/homeda')
                    setDirectorOK("okis")
                }
            }
            console.log(res)
        } catch (error) {
            console.log(error)
        }finally{
            setLoading(false)
        }
    }

    return (
        <div className='contenedorLogin-principal'>
            <div className='contenedorLogin-vista'>
                <div id="login">
                    <form className="formLogin">
                        <h3>Iniciar Sesión</h3>

                        <div className="opciones">
                            <label >Usuario</label>
                            <input
                                type="text"
                                value={data.ci}
                                name='ci'
                                onChange={(e) => setData({ ...data, [e.target.name]: e.target.value })}
                                placeholder="colocarCI"
                                required
                            />
                        </div>

                        <div className="opciones">
                            <label >Contraseña</label>
                            <input
                                type="password"
                                value={data.password}
                                name='password'
                                onChange={(e) => setData({ ...data, [e.target.name]: e.target.value })}
                                id="password"
                                placeholder="********" />
                        </div>

                        <button type="button" onClick={loguearse} disabled={loading}>{loading ? 'Cargando...' : 'Iniciar Sesión'}</button>
                    </form>
                </div>
                <div id='img'>
                </div>
            </div>
        </div>
    )
}

export default LoginPage
