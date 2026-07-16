import "./Testimonios.css";

import CarruselTestimonios from "./CarruselTestimonios";
import FormularioTestimonio from "./FormularioTestimonio";

import { useState } from "react";

function Testimonios() {
    const [mostrarFormulario, setMostrarFormulario] = useState(false);

    return (

        <section className="testimonios">
            <h2 className="section-title">💀 Qué dicen los sobrevivientes 💀</h2>

            <CarruselTestimonios />

            <div className="testimonios-footer">
                <h3>¿Lograste salir con vida?</h3>
                <p>
                    ¡Únete a esta secta! digo, a esta ¡selecta! colección de experiencias
                    con el botoncito de abajo
                </p>
                <button className="btn" onClick={() => setMostrarFormulario(!mostrarFormulario)}>
                    {mostrarFormulario ? "Ocultar formulario" : "Dejar mi experiencia"}
                </button>
            </div>

            {mostrarFormulario && <FormularioTestimonio />}
        </section>

    );

}

export default Testimonios;