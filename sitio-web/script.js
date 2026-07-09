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