import "./FormularioTestimonio.css";

function FormularioTestimonio() {

    return (

        <div className="formulario-testimonio">

            <h3>Cuéntanos tu experiencia</h3>

            <p>Comparte tu experiencia para que otros sepan a lo que se enfrentan.</p>

            <form>

                <label htmlFor="nombre-testimonio">Nombre:</label>
                <input id="nombre-testimonio" type="text" placeholder="Tu nombre" />

                <label htmlFor="foto-testimonio">Foto:</label>
                <input id="foto-testimonio" type="file" accept="image/*" />

                <label htmlFor="texto-testimonio">Tu experiencia:</label>
                <textarea id="texto-testimonio" placeholder="Escribe tu experiencia"></textarea>

                <label htmlFor="fecha-testimonio">Fecha del trauma:</label>
                <input id="fecha-testimonio" type="date" />

                <button id="enviar-testimonio" className="btn" type="submit">Enviar</button>

            </form>

        </div>

    );

}

export default FormularioTestimonio;