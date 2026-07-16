import "./LugarCard.css";

function LugarCard({ lugar, revertir }) {
  return (
    <article className={revertir ? "card reverse" : "card"}>
      <img src={lugar.imagen} alt={lugar.nombre} />

      <div className="card-content">
        <h2>{lugar.nombre}</h2>

        <p>{lugar.parrafo1}</p>

        <p>{lugar.parrafo2}</p>
      </div>
    </article>
  );
}

export default LugarCard;
