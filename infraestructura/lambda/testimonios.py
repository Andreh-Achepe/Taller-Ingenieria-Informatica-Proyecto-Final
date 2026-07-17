import json, boto3, os, uuid, base64, re
from datetime import datetime, timezone

s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]
CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}


def respond(status, body):
    return {
        "statusCode": status,
        "headers": CORS_HEADERS,
        "body": json.dumps(body),
    }


def get_public():
    resp = s3.list_objects_v2(Bucket=bucket, Prefix="testimonios-meta/")
    approved = []
    if "Contents" not in resp:
        return respond(200, approved)
    for obj in resp["Contents"]:
        try:
            meta_resp = s3.get_object(Bucket=bucket, Key=obj["Key"])
            meta = json.loads(meta_resp["Body"].read())
            if meta.get("status") != "approved":
                continue
            foto_url = s3.generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": meta["foto_key"]},
                ExpiresIn=3600,
            )
            approved.append(
                {
                    "id": meta["id"],
                    "nombre": meta["nombre"],
                    "foto": foto_url,
                    "fecha": meta["fecha"],
                    "descripcion": meta["texto"],
                    "created_at": meta["created_at"],
                }
            )
            approved.sort(key=lambda x: x["created_at"], reverse=True)
        except Exception:
            continue
    return respond(200, approved)


def get_admin():
    resp = s3.list_objects_v2(Bucket=bucket, Prefix="testimonios-meta/")
    todos = []
    if "Contents" not in resp:
        return respond(200, todos)
    for obj in resp["Contents"]:
        try:
            meta_resp = s3.get_object(Bucket=bucket, Key=obj["Key"])
            meta = json.loads(meta_resp["Body"].read())
            foto_url = s3.generate_presigned_url(
                "get_object",
                Params={"Bucket": bucket, "Key": meta["foto_key"]},
                ExpiresIn=3600,
            )
            todos.append(
                {
                    "id": meta["id"],
                    "nombre": meta["nombre"],
                    "foto": foto_url,
                    "fecha": meta["fecha"],
                    "descripcion": meta["texto"],
                    "status": meta.get("status", "pending"),
                }
            )
        except Exception:
            continue
    # Más recientes primero
    todos.reverse()
    return respond(200, todos)


def create(event):
    try:
        body = json.loads(event.get("body", "{}"))
        if "foto_base64" not in body or "nombre" not in body:
            return respond(400, {"message": "Faltan campos requeridos"})

        uid = str(uuid.uuid4())
        foto_bytes = base64.b64decode(body["foto_base64"])
        s3.put_object(
            Bucket=bucket,
            Key=f"testimonios/{uid}.jpg",
            Body=foto_bytes,
            ContentType="image/jpeg",
        )
        meta = {
            "id": uid,
            "nombre": body["nombre"],
            "texto": body["texto"],
            "fecha": body["fecha"],
            "foto_key": f"testimonios/{uid}.jpg",
            "status": "pending",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }
        s3.put_object(
            Bucket=bucket,
            Key=f"testimonios-meta/{uid}.json",
            Body=json.dumps(meta),
            ContentType="application/json",
        )

        return respond(200, {"message": "ok", "id": uid})
    except Exception as e:
        return respond(500, {"message": "Error interno", "error": str(e)})


def update_status(testimonio_id, event):
    try:
        body = json.loads(event.get("body", "{}"))
        new_status = body.get("status")
        if new_status not in ("approved", "rejected"):
            return respond(400, {"message": "status debe ser 'approved' o 'rejected'"})

        meta_key = f"testimonios-meta/{testimonio_id}.json"
        try:
            meta_resp = s3.get_object(Bucket=bucket, Key=meta_key)
            meta = json.loads(meta_resp["Body"].read())
        except s3.exceptions.NoSuchKey:
            return respond(404, {"message": "Testimonio no encontrado"})

        meta["status"] = new_status
        s3.put_object(
            Bucket=bucket,
            Key=meta_key,
            Body=json.dumps(meta),
            ContentType="application/json",
        )
        return respond(200, {"message": "Status actualizado", "id": testimonio_id})
    except Exception as e:
        return respond(500, {"message": "Error interno", "error": str(e)})


def delete(testimonio_id):
    try:
        meta_key = f"testimonios-meta/{testimonio_id}.json"
        try:
            meta_resp = s3.get_object(Bucket=bucket, Key=meta_key)
            meta = json.loads(meta_resp["Body"].read())
        except s3.exceptions.NoSuchKey:
            return respond(404, {"message": "Testimonio no encontrado"})

        # Borrar foto
        s3.delete_object(Bucket=bucket, Key=meta.get("foto_key", ""))
        # Borrar metadata
        s3.delete_object(Bucket=bucket, Key=meta_key)

        return respond(200, {"message": "Testimonio eliminado", "id": testimonio_id})
    except Exception as e:
        return respond(500, {"message": "Error interno", "error": str(e)})


def handler(event, context):
    method = event["httpMethod"]

    if method == "OPTIONS":
        return respond(200, {"message": "ok"})
    path = event["path"]

    match_id = re.match(r"^/api/testimonios/([a-f0-9-]+)$", path)
    is_admin = path == "/api/testimonios/admin"

    if method == "GET" and not match_id and not is_admin:
        return get_public()
    elif method == "GET" and is_admin:
        return get_admin()
    elif method == "POST" and not match_id:
        return create(event)
    elif method == "PUT" and match_id:
        return update_status(match_id.group(1), event)
    elif method == "DELETE" and match_id:
        return delete(match_id.group(1))
    else:
        return respond(404, {"message": "Endpoint no encontrado"})
