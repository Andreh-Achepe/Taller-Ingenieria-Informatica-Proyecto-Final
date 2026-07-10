import json, boto3, os, uuid, base64
from datetime import datetime, timezone

s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]


def handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")

    if method == "POST":
        try:
            body = json.loads(event.get("body", "{}"))
            if "foto_base64" not in body or "nombre" not in body:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"message": "Faltan campos requeridos"}),
                }
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
                "created_at": datetime.now(timezone.utc).isoformat(),
            }
            s3.put_object(
                Bucket=bucket,
                Key=f"testimonios-meta/{uid}.json",
                Body=json.dumps(meta),
                ContentType="application/json",
            )

            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({"message": "ok", "id": uid}),
            }
        except Exception as e:
            return {
                "statusCode": 500,
                "body": json.dumps({"message": "Error interno", "error": str(e)}),
            }
    if method == "GET":
        resp = s3.list_objects_v2(Bucket=bucket, Prefix="testimonios-meta/")
        testimonios = []

        if "Contents" in resp:
            objetos = sorted(
                resp["Contents"], key=lambda o: o["LastModified"], reverse=True
            )
            for obj in objetos[:3]:
                try:
                    meta_resp = s3.get_object(Bucket=bucket, Key=obj["Key"])
                    meta = json.loads(meta_resp["Body"].read())

                    # Generar presigned URL para la foto (válida 1 hora)
                    foto_url = s3.generate_presigned_url(
                        "get_object",
                        Params={"Bucket": bucket, "Key": meta["foto_key"]},
                        ExpiresIn=3600,
                    )

                    testimonios.append(
                        {
                            "nombre": meta["nombre"],
                            "texto": meta["texto"],
                            "fecha": meta["fecha"],
                            "foto_url": foto_url,
                        }
                    )
                except Exception:
                    continue
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps(testimonios),
        }
    return {
        "statusCode": 405,
        "body": json.dumps({"message": f"Metodo {method} no permitido"}),
    }
