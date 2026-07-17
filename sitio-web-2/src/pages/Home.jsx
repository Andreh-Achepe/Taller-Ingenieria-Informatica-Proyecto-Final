import Hero from "../components/Hero/Hero.jsx";
import Intro from "../components/Intro/Intro.jsx";
import Lugares from "../components/Lugares/Lugares.jsx";
import Testimonios from "../components/Testimonios/Testimonios.jsx";
import Reserva from "../components/Reserva/Reserva.jsx";

function Home() {

    return (
        <>
            <Hero />
            <Intro/>
            <Lugares/>
            <Testimonios/>
            <Reserva/>
        </>
    );

}

export default Home;