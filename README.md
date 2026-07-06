# Proyecto final TIM

## Integrantes

- [Benjamin Alberto Martinez Hernandez](https://github.com/ELBA21)
- [Andres Hernandez Perez](https://github.com/Andreh-Achepe)

## Tecnologias

- **Cloud**: AWS
- Web: AntiTurismo Puerto important
- Otros: [Python, Docker, Terraform]
- Infraestructura:
  ![Diagrama de ingraestructura del sitio](./infraestructura/Infraestructura.png)

## Intrucciones

Clonar repositorio

```bash
git clone git@github.com:Andreh-Achepe/Taller-Ingenieria-Informatica-Proyecto-Final.git

cd infraestructura

# En lugar de usar terraform init
bash terraform_init.sh # Asi inyectamos flags manteniendo variables sin hardcodear

terraform fmt -recursive

terraform validate

terraform plan

terraform apply

terraform destroy
```

## Sitio web: Repositorio colaborativo de apuntes

- AntiTurismo Puerto Montt es nuestra empresa de turismo dedicada a la promocion de los lugares menos explorados de nuestra magnifica ciudad.
- En nuestro sitio web, los usuarios pueden:
  - Encontrar informacion detallada sobre nuestros recorridos.
  - Inscribirse a buses turisticos.
  - Los usuarios pueden dejar comentarios y calificaciones sobre los lugares visitados.

- La infraestructura levanta el sitio-web del laboratorio 2 como placeholder
