import "./Reserva.css";
import { useState, useEffect } from "react";

function Reserva() {
    const [lugares, setLugares] = useState([]);
    const [mensaje, setMensaje] = useState({ texto: "", color: "" });
    const [enviando, setEnviando] = useState(false);

    useEffect(() => {
        fetch("/api/lugares")
            .then((r) => r.json())
            .then((data) => setLugares(data))
            .catch(() => { });
    }, []);

    function handleSubmit(e) {
        e.preventDefault();
        const data = {
            nombre: e.target.nombre.value,
            email: e.target.email.value,
            tramo: e.target.tramo.value,
            fecha: e.target.fecha.value,
        };
        setEnviando(true);
        fetch("/api/booking", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data),
        })
            .then((r) => r.json())
            .then((d) => {
                setMensaje({ texto: d.message, color: "green" });
                e.target.reset();
            })
            .catch(() => setMensaje({ texto: "Error de conexión", color: "red" }))
            .finally(() => setEnviando(false));
    }

    return (
        <section id="reserva" className="reserva">
            <h2>Reserva tu recorrido</h2>

            <p>
                Completa el formulario para reservar un cupo en nuestro recorrido de
                AntiTurismo Puerto Montt.
            </p>

            <form id="bookingForm" onSubmit={handleSubmit}>
                <label htmlFor="nombre">Nombre completo</label>
                <input
                    type="text"
                    id="nombre"
                    name="nombre"
                    placeholder="Ej: Robert Lox"
                    required
                />

                <label htmlFor="email">Correo electrónico</label>
                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Ej: benjappmartickets@email.com"
                    required
                />

                <label htmlFor="tramo">Recorrido</label>
                <select id="tramo" name="tramo">
                    <option value="">Seleccione un recorrido</option>
                    {lugares.map((l) => (
                        <option key={l.id} value={l.nombre}>
                            {l.nombre}
                        </option>
                    ))}
                </select>

                <label htmlFor="fecha">Fecha</label>
                <input type="date" id="fecha" name="fecha" required />

                <button type="submit" className="btn" disabled={enviando}>
                    {enviando ? "Enviando..." : "Reservar"}
                </button>
            </form>

            {mensaje.texto && (
                <p id="mensaje" style={{ color: mensaje.color, marginTop: "1rem" }}>
                    {mensaje.texto}
                </p>
            )}
        </section>
    );
}

export default Reserva;
