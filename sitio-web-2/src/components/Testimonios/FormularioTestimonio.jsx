import "./FormularioTestimonio.css";
import { useState } from "react";

function FormularioTestimonio() {
    const [form, setForm] = useState({ nombre: "", texto: "", fecha: "" });
    const [archivo, setArchivo] = useState(null);
    const [msg, setMsg] = useState(null);
    const [enviando, setEnviando] = useState(false);

    function handleChange(e) {
        setForm({ ...form, [e.target.name]: e.target.value });
    }
    function handleFileChange(e) {
        setArchivo(e.target.files[0] || null);
    }
    function handleSubmit(e) {
        e.preventDefault();
        if (!archivo) {
            setMsg("Selecciona una foto");
            return;
        }
        setEnviando(true);
        const reader = new FileReader();
        reader.onload = () => {
            const foto_base64 = reader.result.split(",")[1];
            fetch("/api/testimonios", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ ...form, foto_base64 }),
            })
                .then((r) => r.json())
                .then(() => {
                    setMsg("¡Gracias! Testimonio enviado, pendiente de aprobación.");
                    setForm({ nombre: "", texto: "", fecha: "" });
                    setArchivo(null);
                })
                .catch(() => setMsg("Error al enviar"))
                .finally(() => setEnviando(false));
        };
        reader.readAsDataURL(archivo);
    }

    return (
        <div className="formulario-testimonio">
            <h3>Cuéntanos tu experiencia</h3>

            <p>Comparte tu experiencia para que otros sepan a lo que se enfrentan.</p>

            <form onSubmit={handleSubmit}>
                {msg && <p className="msg">{msg}</p>}
                <label htmlFor="nombre-testimonio">Nombre:</label>
                <input id="nombre-testimonio" name="nombre" type="text" placeholder="Tu nombre" value={form.nombre} onChange={handleChange} required />

                <label htmlFor="foto-testimonio">Foto:</label>
                <input id="foto-testimonio" type="file" accept="image/*" onChange={handleFileChange} />

                <label htmlFor="texto-testimonio">Tu experiencia:</label>
                <textarea
                    id="texto-testimonio"
                    name="texto"
                    placeholder="Escribe tu experiencia"
                    value={form.texto}
                    onChange={handleChange}
                ></textarea>

                <label htmlFor="fecha-testimonio">Fecha del trauma:</label>
                <input id="fecha-testimonio" name="fecha" type="date" value={form.fecha} onChange={handleChange} />

                <button id="enviar-testimonio" className="btn" type="submit" disabled={enviando}>
                    {enviando ? "Enviando..." : "Enviar"}
                </button>
            </form>
        </div>
    );
}

export default FormularioTestimonio;
