# Proyecto final TIM

## Integrantes

- [Benjamin Alberto Martinez Hernandez](https://github.com/ELBA21)
- [Andres Hernandez Perez](https://github.com/Andreh-Achepe)

## Tecnologias

- **Cloud**: AWS
- Web: Proyecto Final
- Otros: Docker
- Infraestructura:
  ![Diagrama de ingraestructura del sitio](./infraestructura/Infraestructura.png)

## Intrucciones

Clonar repositorio

```bash
git clone git@github.com:Andreh-Achepe/Taller-Ingenieria-Informatica-Proyecto-Final.git

cd infraestructura

# En lugar de usar terraform init
bash terraform_init.sh # Asi inyectamos flags manteniendo variables sin hardcodear

terraform ftm -recursive

terraform validate

terraform plan

terraform apply

terraform destroy
```

## Sitio web: Repositorio colaborativo de apuntes

Sistema de subida y organización inteligente de apuntes universitarios.

- **S3**: Almacena los PDFs de apuntes
- **Lambda**: Extrae texto y asigna tags automáticamente al subir un PDF
- **DynamoDB**: Guarda metadatos (ramo, tags, autor, fecha) con índice por ramo
- **ECS Fargate**: Frontend web para subir, buscar y descargar apuntes

![Diagrama de ingraestructura del sitio](./infraestructura/Infraestructura.png)
