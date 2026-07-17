import { useState, useEffect } from "react";
import "./Lugares.css";
import LugarCard from "./LugarCard.jsx";
import lugaresFallback from "../../data/lugares.js";

function Lugares() {
  const [lugares, setLugares] = useState([]);
  const [recorrido, setRecorrido] = useState("Todos");

  useEffect(() => {
    fetch("/api/lugares")
      .then((r) => r.json())
      .then((data) => setLugares(data))
      .catch(() => setLugares(lugaresFallback));
  }, []);

  const recorridos = [
    ...new Set(lugares.map((l) => l.recorrido).filter(Boolean)),
  ];

  const filtrados =
    recorrido == "Todos"
      ? lugares
      : lugares.filter((l) => l.recorrido === recorrido);

  return (
    <section id="lugarestitulo" className="lugares">
      <h2 className="section-title">Lugares de interest</h2>

      {recorridos.length > 0 && (
        <div className="recorrido-filtro">
          <select
            value={recorrido}
            onChange={(e) => setRecorrido(e.target.value)}
          >
            <option value="Todos">Todos los recorridos</option>
            {recorridos.map((r) => (
              <option key={r} value={r}>
                {r}
              </option>
            ))}
          </select>
        </div>
      )}

      {filtrados.map((lugar, index) => (
        <LugarCard key={lugar.id} lugar={lugar} revertir={index % 2 !== 0} />
      ))}
    </section>
  );
}

export default Lugares;
