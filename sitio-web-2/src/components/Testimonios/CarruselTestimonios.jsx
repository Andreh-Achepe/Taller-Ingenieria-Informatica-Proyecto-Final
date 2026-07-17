import { useState, useEffect } from "react";
// import testimonios from "../../data/testimonios";
import TestimonioCard from "./TestimonioCard";
import "./CarruselTestimonios.css";

function CarruselTestimonios() {
    const [actual, setActual] = useState(0);
    const [testimonios, setTestimonios] = useState([]);
    const [cargando, setCargando] = useState(true);

    useEffect(() => {
        fetch("/api/testimonios")
            .then((r) => r.json())
            .then((d) => {
                setTestimonios(d);
                setCargando(false);
            })
            .catch(() => {
                setCargando(false);
                console.error("Error al cargar testimonios");
            });
    }, []);

    if (cargando)
        return (
            <div className="testimonios-carousel">
                <p>Cargando testimonios...</p>
            </div>
        );
    if (testimonios.length === 0)
        return (
            <div className="testimonios-carousel">
                <p>No hay testimonios aún.</p>
            </div>
        );

    function siguiente() {
        setActual((actual + 1) % testimonios.length);
    }
    function anterior() {
        setActual((actual - 1 + testimonios.length) % testimonios.length);
    }
    const izquierda = (actual - 1 + testimonios.length) % testimonios.length;
    const derecha = (actual + 1) % testimonios.length;

    return (
        <div className="testimonios-carousel">
            <button onClick={anterior}>❮</button>

            <div className="testimonios-contenedor">
                <div className="testimonio-left">
                    <TestimonioCard testimonio={testimonios[izquierda]} />
                </div>

                <div className="testimonio-center">
                    <TestimonioCard testimonio={testimonios[actual]} />
                </div>

                <div className="testimonio-right">
                    <TestimonioCard testimonio={testimonios[derecha]} />
                </div>
            </div>

            <button onClick={siguiente}>❯</button>
        </div>
    );
}

export default CarruselTestimonios;
