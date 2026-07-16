import "./Hero.css";

import { Link } from "react-router-dom";

function Hero() {

    return (

        <header className="hero">

            <div className="hero-content">

                <h1>AnTi TuRiSm0 PUERTO MONTT</h1>

                <p>
                    Porque ya todos conocen Angelmó.
                    Nosotros te mostramos las cosas raras.
                </p>

                <Link className="btn" to="/login">
                    Administrador
                </Link>

                <a href="#lugarestitulo" className="btn">
                    Ver recorrido
                </a>

            </div>

        </header>

    );

}

export default Hero;