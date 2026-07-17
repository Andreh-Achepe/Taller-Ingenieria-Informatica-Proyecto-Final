# Proyecto Final — Taller de Ingeniería Informática

## Integrantes

- [Benjamin Alberto Martinez Hernandez](https://github.com/ELBA21)
- [Andres Hernandez Perez](https://github.com/Andreh-Achepe)

---

## Descripción

**AntiTurismo Puerto Montt** es una plataforma web de turismo que promociona los lugares menos explorados de Puerto Montt. El sistema permite a los usuarios explorar recorridos, reservar buses turísticos y compartir sus experiencias mediante testimonios moderados.

### Flujo principal

1. Usuario visita el sitio y explora los **lugares** de interés agrupados por recorridos
2. Usuario puede **reservar** un bus turístico mediante el formulario (backend envía confirmación por email vía SES)
3. Usuario envía un **testimonio** con foto (queda en estado `pending`)
4. **Administrador** ingresa a `/admin`, revisa los testimonios pendientes y los **aprueba** o **rechaza**
5. Los testimonios aprobados aparecen en el **carrusel** público de la página principal
6. Administrador puede **crear, editar y eliminar lugares** desde el panel de administración

---

## Arquitectura

### Diagrama de infraestructura

![Diagrama de infraestructura](./infraestructura/Infraestructura.png)

### Componentes

| Componente | Tecnología | Descripción |
|------------|------------|-------------|
| **Frontend** | React + Vite (SPA) | Servido por Nginx en ECS Fargate |
| **ALB** | Application Load Balancer | Rutea tráfico HTTP y separa `/api/*` hacia Lambdas |
| **ECS Fargate** | AWS ECS con Fargate | Contenedores serverless en subnets privadas, multi‑AZ |
| **Auto Scaling** | Application Auto Scaling | Escala entre 2‑4 tareas según CPU (>70%) |
| **Lambdas** | Python 3.12 | Manejan booking, lugares y testimonios |
| **DynamoDB** | DynamoDB | Almacena lugares y reservas |
| **S3** | S3 (cifrado KMS) | Almacena fotos de lugares y testimonios |
| **SES** | Simple Email Service | Envía confirmaciones de reserva por email |
| **ECR** | Elastic Container Registry | Repositorio de imágenes Docker del frontend |
| **VPC** | VPC multi‑AZ | Subnets públicas (ALB) y privadas (ECS, Lambdas) |
| **Security Groups** | Mínimo privilegio | ALB acepta HTTP/HTTPS público; ECS solo recibe del ALB |
| **IAM** | Roles con mínimo privilegio | Cada Lambda accede solo a sus recursos (DynamoDB, S3, SES) |

### Endpoints de la API

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/lugares` | Obtener todos los lugares |
| `POST` | `/api/lugares` | Crear un nuevo lugar |
| `PUT` | `/api/lugares/:id` | Actualizar un lugar |
| `DELETE` | `/api/lugares/:id` | Eliminar un lugar |
| `GET` | `/api/testimonios` | Obtener testimonios aprobados (público) |
| `GET` | `/api/testimonios/admin` | Obtener todos los testimonios (admin) |
| `POST` | `/api/testimonios` | Enviar un nuevo testimonio |
| `PUT` | `/api/testimonios/:id` | Aprobar/rechazar testimonio |
| `DELETE` | `/api/testimonios/:id` | Eliminar testimonio |
| `POST` | `/api/booking` | Realizar reserva de bus (envía email) |

### Rutas del frontend

| Ruta | Componente | Descripción |
|------|------------|-------------|
| `/` | `Home.jsx` | Página principal con lugares, testimonios y reserva |
| `/login` | `Login.jsx` | Inicio de sesión de administrador |
| `/admin` | `Admin.jsx` | Panel con pestañas "Recorridos" (CRUD lugares) y "Testimonios" (moderación) |

---

## Tecnologías

- **Cloud**: AWS (ECS Fargate, Lambda, S3, DynamoDB, SES, ECR, ALB)
- **Frontend**: React 19, Vite, React Router
- **Backend**: Python 3.12 (AWS Lambda)
- **Infraestructura**: Terraform (HCL)
- **Contenedores**: Docker, Nginx
- **Control de versiones**: Git, GitHub

---

## Despliegue

### Requisitos previos

- AWS CLI configurado con credenciales
- Terraform >= 1.8
- Docker
- Cuenta AWS con permisos para ECR, ECS, Lambda, S3, DynamoDB, SES y ALB

### Paso 1 — Clonar el repositorio

```bash
git clone git@github.com:Andreh-Achepe/Taller-Ingenieria-Informatica-Proyecto-Final.git
cd Taller-Ingenieria-Informatica-Proyecto-Final
```

### Paso 2 — Crear repositorio ECR (una sola vez)

```bash
aws ecr create-repository --repository-name ulagos-tin-lab3-web
```

### Paso 3 — Inicializar y aplicar Terraform

```bash
cd infraestructura

# Inicializar Terraform con configuración del backend
bash terraform_init.sh

# Validar y planificar
terraform validate
terraform plan

# Desplegar infraestructura (~3-5 minutos)
terraform apply
```

### Paso 4 — Construir y desplegar el frontend

```bash
./docker_build.sh
```

Este script:
1. Lee el tag semántico y la URL del ALB
2. Construye la imagen Docker del frontend
3. Prueba localmente que el sitio responda
4. Sube la imagen a ECR
5. Fuerza un nuevo despliegue en ECS

### Paso 5 — Verificar

```bash
# Obtener URL del sitio
terraform output -raw alb_dns

# Probar APIs
curl http://$(terraform output -raw alb_dns)/api/lugares
curl http://$(terraform output -raw alb_dns)/api/testimonios
```

### Destruir infraestructura

```bash
terraform destroy
```

> Nota: El repositorio ECR se gestiona fuera de Terraform (`data source`), por lo que sobrevive al `destroy`. Si necesitas eliminarlo:
> ```bash
> aws ecr delete-repository --repository-name ulagos-tin-lab3-web --force
> ```

---

## Desarrollo local

Para desarrollo del frontend sin necesidad de infraestructura en AWS:

```bash
cd sitio-web-2
npm install
npm run dev    # http://localhost:5173 con proxy al ALB
```

El proxy de Vite reenvía las llamadas `/api/*` al ALB en producción, pero los datos se cargan con fallback a información estática si el backend no está disponible.

---

## Escalabilidad y resiliencia

- **Multi‑AZ**: Subnets en `us-east-1a` y `us-east-1b`, con VPC pública y privada
- **Balanceo de carga**: Application Load Balancer distribuyendo tráfico entre tareas Fargate
- **Auto Scaling**: Escala automática entre 2‑4 tareas según uso de CPU (target: 70%)
- **Fargate**: Sin servidores que administrar; AWS gestiona la capacidad subyacente
- **Lambda**: Backend serverless que escala automáticamente con la demanda

---

## Seguridad

- **Seguridad de red**: ECS en subnets privadas, solo el ALB tiene exposición pública
- **Grupos de seguridad**: ALB recibe HTTP/HTTPS del público; ECS solo acepta tráfico del ALB
- **IAM con mínimo privilegio**: Cada Lambda tiene políticas acotadas a los recursos que necesita (DynamoDB, S3, SES)
- **Cifrado**: Repositorio ECR con cifrado KMS; S3 gestionado con cifrado del lado del servidor
- **Sin secretos hardcodeados**: Variables sensibles gestionadas mediante `terraform.tfvars` (excluido de control de versiones mediante `.gitignore`)
