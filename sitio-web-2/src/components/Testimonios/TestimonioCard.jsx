import "./TestimonioCard.css";

function TestimonioCard({ testimonio }) {

    return (

        <article className="testimonio-card">

            <img 
                src={testimonio.foto}
                alt={testimonio.nombre}
            />

            <div className="testimonio-info">

                <h3>{testimonio.nombre}</h3>

                <span>{testimonio.fecha}</span>

            </div>

            <p>
                {testimonio.descripcion}
            </p>

        </article>

    );

}

export default TestimonioCard;