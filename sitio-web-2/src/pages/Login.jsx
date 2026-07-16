import { useNavigate } from "react-router-dom";
import "./Login.css";

function Login() {

    const navigate = useNavigate();

    function iniciarSesion(e) {

        e.preventDefault();

        navigate("/admin");

    }

    return (

        <section className="login">

            <div className="login-content">

                <h1>Administrador</h1>

                <p>Inicia sesión para administrar los recorridos.</p>

                <form onSubmit={iniciarSesion}>

                    <h2>Login</h2>

                    <input type="text" placeholder="Usuario" />

                    <input type="password" placeholder="Contraseña" />

                    <button type="submit">
                        Ingresar
                    </button>

                </form>
            </div>

        </section>
    );

}

export default Login;