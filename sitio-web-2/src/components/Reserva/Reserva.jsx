import "./Reserva.css";

function Reserva() {

    return (
        <section id="reserva" className="reserva">
            <h2>Reserva tu recorrido</h2>

            <p>
                Completa el formulario para reservar un cupo en nuestro recorrido de
                AntiTurismo Puerto Montt.
            </p>

            <form id="bookingForm">
                <label for="nombre">Nombre completo</label>
                <input type="text" id="nombre" name="nombre" placeholder="Ej: Robert Lox" required />

                <label for="email">Correo electrónico</label>
                <input type="email" id="email" name="email" placeholder="Ej: benjappmartickets@email.com" required />

                <label for="tramo">Recorrido</label>
                <select id="tramo" name="tramo" required>
                    <option value="">Seleccione un recorrido</option>
                    <option value="Recorrido julio">Recorrido julio</option>
                </select>

                <label for="fecha">Fecha</label>
                <input type="date" id="fecha" name="fecha" required />

                <button type="submit" className="btn">Reservar</button>
            </form>

            <p id="mensaje"></p>
        </section>

    );

}

export default Reserva;