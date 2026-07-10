const form = document.getElementById("bookingForm");

form.addEventListener("submit", async function(event) {

    event.preventDefault();

    const datos = {
        nombre: document.getElementById("nombre").value,
        email: document.getElementById("email").value,
        tramo: document.getElementById("tramo").value,
        fecha: document.getElementById("fecha").value
    };


    const respuesta = await fetch("URL_DE_TU_LAMBDA", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(datos)
    });


    const resultado = await respuesta.json();

    console.log(resultado);

});

// let comentarios = []; //ahora se llenará con lambda, 

const comentarios = [

    {
        nombre:"Camila",
        fecha:"09/07/2026",
        texto:"Muy buen recorrido.",
        foto:"https://i.pravatar.cc/150?img=32"
    },

    {
        nombre:"Felipe",
        fecha:"09/07/2026",
        texto:"Lo mejor fue la cárcel. asdskj ajks jsa kjak jsdja kssjajk sdladwalijdnalwd wadn dakjsdj asjdkjaskj akjs djajska djkawj",
        foto:"https://i.pravatar.cc/150?img=12"
    },

    {
        nombre:"Javiera",
        fecha:"09/07/2026",
        texto:"Volvería nuevamente.",
        foto:"https://i.pravatar.cc/150?img=48"
    },

    {
        nombre:"Ignacio",
        fecha:"09/07/2026",
        texto:"Muy distinto a un tour normal.",
        foto:"https://i.pravatar.cc/150?img=51"
    },

    {
        nombre:"Valentina",
        fecha:"09/07/2026",
        texto:"Excelente experiencia.",
        foto:"https://i.pravatar.cc/150?img=15"
    }

];

let actual = 0;

const izquierda = document.querySelector(".testimonio-left");
const centro = document.querySelector(".testimonio-center");
const derecha = document.querySelector(".testimonio-right");

function cargar(card, dato){

    card.innerHTML = `

        <img src="${dato.foto}" alt="${dato.nombre}">

        <div class="testimonio-info">

            <h3>${dato.nombre}</h3>

            <span>${dato.fecha}</span>

        </div>

        <p>${dato.texto}</p>

    `;

}

function actualizar(){

    const anterior = (actual - 1 + comentarios.length) % comentarios.length;
    const siguiente = (actual + 1) % comentarios.length;

    cargar(izquierda, comentarios[anterior]);
    cargar(centro, comentarios[actual]);
    cargar(derecha, comentarios[siguiente]);

}

actualizar();

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