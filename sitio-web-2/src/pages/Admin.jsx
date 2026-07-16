import { useState, useEffect } from "react";
import { Link } from "react-router-dom";

const VACIO = {
    nombre: "",
    recorrido: "",
    imagen: "",
    parrafo1: "",
    parrafo2: "",
    orden: 99,
};

function Admin() {
    const [lugares, setLugares] = useState([]);
    const [editando, setEditando] = useState(null);
    const [form, setForm] = useState(VACIO);
    const [msg, setMsg] = useState("");

    useEffect(() => {
        cargar();
    }, []);

    function cargar() {
        fetch("/api/lugares")
            .then((r) => r.json())
            .then((d) => setLugares(d))
            .catch(() => setMsg("Error al cargar lugares"));
    }
    function handleSubmit(e) {
        e.preventDefault();

        const url = editando ? `/api/lugares/${editando}` : "/api/lugares";
        const method = editando ? "PUT" : "POST";

        fetch(url, {
            method,
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(form),
        })
            .then((r) => r.json())
            .then(() => {
                cargar();
                setForm(VACIO);
                setEditando(null);
                setMsg(editando ? "Lugar actualizado" : "Lugar creado");
            })
            .catch(() => setMsg("Error"));
    }

    function handleChange(e) {
        setForm({ ...form, [e.target.name]: e.target.value });
    }

    function editar(lugar) {
        setEditando(lugar.id);
        setForm(lugar);
        setMsg("");
    }

    function eliminar(id) {
        if (!confirm("¿Eliminar este lugar?")) return;
        fetch(`/api/lugares/${id}`, { method: "DELETE" }).then(() => {
            cargar();
            setMsg("Lugar eliminado");
        });
    }

    function cancelar() {
        setEditando(null);
        setForm(VACIO);
        setMsg("");
    }
    return (
        <section style={{ maxWidth: 900, margin: "2rem auto", padding: "1rem" }}>
            <h1>Administrador de Recorridos</h1>
            <Link
                to="/"
                className="btn"
                style={{ fontSize: "0.85rem", padding: "8px 16px" }}
            >
                Volver al sitio
            </Link>
            {msg && <p style={{ color: "green" }}>{msg}</p>}
            <form
                onSubmit={handleSubmit}
                style={{
                    background: "#fff",
                    padding: "1.5rem",
                    borderRadius: 8,
                    margin: "1.5rem 0",
                }}
            >
                <h2>{editando ? "Editar lugar" : "Nuevo lugar"}</h2>
                <div style={{ display: "grid", gap: "0.8rem" }}>
                    <input
                        name="nombre"
                        placeholder="Nombre *"
                        value={form.nombre}
                        onChange={handleChange}
                        required
                    />
                    <input
                        name="recorrido"
                        placeholder="Ej: Marzo"
                        value={form.recorrido}
                        onChange={handleChange}
                    />
                    <input
                        name="imagen"
                        placeholder="Imagen (ej: /img/terminal.jpg)"
                        value={form.imagen}
                        onChange={handleChange}
                    />
                    <input
                        name="parrafo1"
                        placeholder="Párrafo 1"
                        value={form.parrafo1}
                        onChange={handleChange}
                    />
                    <input
                        name="parrafo2"
                        placeholder="Párrafo 2"
                        value={form.parrafo2}
                        onChange={handleChange}
                    />
                    <input
                        name="orden"
                        type="number"
                        placeholder="Orden"
                        value={form.orden}
                        onChange={handleChange}
                    />
                </div>
                <div style={{ marginTop: "1rem", display: "flex", gap: "0.5rem" }}>
                    <button type="submit" className="btn">
                        {editando ? "Actualizar" : "Crear"}
                    </button>
                    {editando && (
                        <button
                            type="button"
                            onClick={cancelar}
                            className="btn"
                            style={{ background: "#999" }}
                        >
                            Cancelar
                        </button>
                    )}
                </div>
            </form>
            <h2>Lugares ({lugares.length})</h2>
            <div style={{ display: "grid", gap: "0.5rem" }}>
                {lugares.map((l) => (
                    <div
                        key={l.id}
                        style={{
                            background: "#fff",
                            padding: "0.8rem 1rem",
                            borderRadius: 6,
                            display: "flex",
                            justifyContent: "space-between",
                            alignItems: "center",
                        }}
                    >
                        <span>
                            <strong>#{l.orden}</strong> {l.nombre}
                        </span>
                        <div style={{ display: "flex", gap: "0.4rem" }}>
                            <button
                                onClick={() => editar(l)}
                                className="btn"
                                style={{
                                    fontSize: "0.8rem",
                                    padding: "5px 12px",
                                    background: "#3377cc",
                                }}
                            >
                                Editar
                            </button>
                            <button
                                onClick={() => eliminar(l.id)}
                                className="btn"
                                style={{
                                    fontSize: "0.8rem",
                                    padding: "5px 12px",
                                    background: "#cc3333",
                                }}
                            >
                                Eliminar
                            </button>
                        </div>
                    </div>
                ))}
            </div>
        </section>
    );
}

export default Admin;
