const form = document.getElementById("bookingForm");
const mensaje = document.getElementById("mensaje");
const btn = form.querySelector(".btn");

form.addEventListener("submit", async function(event) {
    event.preventDefault();
    btn.disabled = true;
    btn.textContent = "Enviando...";
    mensaje.textContent = "";
    const datos = {
        nombre: document.getElementById("nombre").value,
        email: document.getElementById("email").value,
        tramo: document.getElementById("tramo").value,
        fecha: document.getElementById("fecha").value,
    };
    try {
        const respuesta = await fetch(
            "https://i6zid2olkgztgzm34ibksuofom0psqfk.lambda-url.us-east-1.on.aws/",
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(datos),
            },
        );
        const resultado = await respuesta.json();
        console.log(resultado);
        if (respuesta.ok) {
            mensaje.style.color = "green";
            mensaje.textContent = "Reserva confirmada, revisa tu email";
            form.reset();
        } else {
            mensaje.style.color = "red";
            mensaje.textContent = "Error, algo salio mal";
        }
    } catch (err) {
        console.error(err);
        mensaje.style.color = "red";
        mensaje.textContent = " Error de conexion";
    } finally {
        btn.disabled = false;
        btn.textContent = "Reservar";
    }
});

// let comentarios = []; //ahora se llenará con lambda,

let comentarios = [];
let actual = 0;

async function cargarTestimonios() {
    try {
        const resp = await fetch(
            "https://ojoprmz2qi36mf6pio545lghmy0crqta.lambda-url.us-east-1.on.aws/",
        );
        comentarios = await resp.json();
        actual = 0;
    } catch {
        console.error("No se pudieron cargar testimonios");
    }
    actualizar();
}

cargarTestimonios();

const izquierda = document.querySelector(".testimonio-left");
const centro = document.querySelector(".testimonio-center");
const derecha = document.querySelector(".testimonio-right");

function cargar(card, dato) {
    card.innerHTML = `

        <img src="${dato.foto_url}" alt="${dato.nombre}">

        <div class="testimonio-info">

            <h3>${dato.nombre}</h3>

            <span>${dato.fecha}</span>

        </div>

        <p>${dato.texto}</p>

    `;
}

function actualizar() {
    const anterior = (actual - 1 + comentarios.length) % comentarios.length;
    const siguiente = (actual + 1) % comentarios.length;

    cargar(izquierda, comentarios[anterior]);
    cargar(centro, comentarios[actual]);
    cargar(derecha, comentarios[siguiente]);
}

document.getElementById("testimonio-next").addEventListener("click", () => {
    actual = (actual + 1) % comentarios.length;

    actualizar();
});

document.getElementById("testimonio-prev").addEventListener("click", () => {
    actual = (actual - 1 + comentarios.length) % comentarios.length;

    actualizar();
});

const botonTestimonio = document.getElementById("mostrar-formulario");
const formularioTestimonio = document.getElementById("formulario-testimonio");

botonTestimonio.addEventListener("click", () => {
    formularioTestimonio.classList.toggle("oculto");
});

const btnEnviarTestimonio = document.getElementById("enviar-testimonio");

btnEnviarTestimonio.addEventListener("click", async () => {
    const nombre = document.getElementById("nombre-testimonio").value;
    const texto = document.getElementById("texto-testimonio").value;
    const fecha = document.getElementById("fecha-testimonio").value;
    const fotoInput = document.getElementById("foto-testimonio");

    if (!nombre || !texto || !fecha || !fotoInput.files[0]) {
        alert("Completa todos los campos");
        return;
    }
    btnEnviarTestimonio.disabled = true;
    btnEnviarTestimonio.textContent = "Enviando...";

    const file = fotoInput.files[0];
    const reader = new FileReader();
    reader.onload = async () => {
        const foto_base64 = reader.result.split(",")[1];

        try {
            const resp = await fetch(
                "https://ojoprmz2qi36mf6pio545lghmy0crqta.lambda-url.us-east-1.on.aws/",
                {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ nombre, texto, fecha, foto_base64 }),
                },
            );
            const data = await resp.json();
            if (resp.ok) {
                alert("¡Testimonio enviado!");
                formularioTestimonio.classList.add("oculto");
                // Recargar testimonios
                await cargarTestimonios();
            } else {
                alert("Error: " + (data.message || "algo salió mal"));
            }
        } catch {
            alert("Error de conexion");
        } finally {
            btnEnviarTestimonio.disabled = false;
            btnEnviarTestimonio.textContent = "Enviar";
        }
    };
    reader.readAsDataURL(file);
});
