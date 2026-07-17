import "./TestimonioCard.css";

function TestimonioCard({ testimonio }) {
    return (
        <article className="testimonio-card">
            {testimonio.foto ? (
                <img src={testimonio.foto} alt={testimonio.nombre} />
            ) : (
                <div
                    style={{ width: 80, height: 80, background: "#eee", borderRadius: 8 }}
                />
            )}

            <div className="testimonio-info">
                <h3>{testimonio.nombre}</h3>

                <span>{testimonio.fecha}</span>
            </div>

            <p>{testimonio.descripcion}</p>
        </article>
    );
}

export default TestimonioCard;
