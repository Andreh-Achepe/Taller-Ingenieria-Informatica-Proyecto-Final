import "./Lugares.css";
import LugarCard from "./LugarCard.jsx";
import lugares from "../../data/lugares.js";

function Lugares() {

    return (

        <section className="lugares">

            <h2 className="section-title">Lugares de interest</h2>

            {
                lugares.map((lugar, index) => (
                    <LugarCard
                        key={lugar.id}
                        lugar={lugar}
                        revertir={index % 2 !== 0}
                    />
                ))
            }

        </section>

    );

}

export default Lugares;
