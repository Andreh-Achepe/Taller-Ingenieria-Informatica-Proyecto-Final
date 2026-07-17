import json
import boto3
import os
import uuid
import base64

dynamoDB = boto3.resource("dynamodb")
table = dynamoDB.Table(os.environ["TABLE_NAME"])
s3 = boto3.client("s3")
bucket = os.environ["BUCKET_NAME"]


def img_url(path):
    if path and path.startswith("lugares/"):
        return s3.generate_presigned_url(
            "get_object",
            Params={"Bucket": bucket, "Key": path},
            ExpiresIn=3600,
        )
    return path


def resp(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(body, default=str),
    }


def list_all():
    result = table.scan(
        FilterExpression="entity_type = :t",
        ExpressionAttributeValues={":t": "lugar"},
    )
    items = sorted(result.get("Items", []), key=lambda i: int(i.get("orden", 99)))
    return resp(
        200,
        [
            {
                "id": i["id"],
                "nombre": i["nombre"],
                "recorrido": i.get("recorrido", ""),
                "imagen": img_url(i.get("imagen", "")),
                "parrafo1": i.get("parrafo1", ""),
                "parrafo2": i.get("parrafo2", ""),
                "orden": int(i.get("orden", 99)),
            }
            for i in items
        ],
    )


def get_one(lugar_id):
    result = table.get_item(Key={"id": lugar_id})
    item = result.get("Item")
    if not item or item.get("entity_type") != "lugar":
        return resp(404, {"message": "No encontrado"})
    item["imagen"] = img_url(item.get("imagen", ""))
    return resp(200, item)


def create(body):
    if "nombre" not in body:
        return resp(400, {"message": "Falta nombre"})
    imagen_final = body.get("imagen", "")
    if body.get("imagen_base64"):
        ext = "jpg"
        img_key = f"lugares/{str(uuid.uuid4())}.{ext}"
        s3.put_object(
            Bucket=bucket,
            Key=img_key,
            Body=base64.b64decode(body["imagen_base64"]),
            ContentType=f"image/{ext}",
        )
        imagen_final = img_key

    item = {
        "id": str(uuid.uuid4()),
        "entity_type": "lugar",
        "nombre": body["nombre"],
        "recorrido": body.get("recorrido", ""),
        "imagen": imagen_final,
        "parrafo1": body.get("parrafo1", ""),
        "parrafo2": body.get("parrafo2", ""),
        "orden": int(body.get("orden", 99)),
    }
    table.put_item(Item=item)
    return resp(201, item)


def update(lugar_id, body):
    result = table.get_item(Key={"id": lugar_id})
    item = result.get("Item")
    if not item or item.get("entity_type") != "lugar":
        return resp(404, {"message": "No encontrado"})
    updates = {}
    if body.get("imagen_base64"):
        ext = "jpg"
        img_key = f"lugares/{str(uuid.uuid4())}.{ext}"
        s3.put_object(
            Bucket=bucket,
            Key=img_key,
            Body=base64.b64decode(body["imagen_base64"]),
            ContentType=f"image/{ext}",
        )
        updates["imagen"] = img_key
    for field in ["nombre", "recorrido", "parrafo1", "parrafo2", "orden"]:
        if field in body:
            updates[field] = int(body[field]) if field == "orden" else body[field]
    if not updates:
        return resp(400, {"message": "Nada que actualizar"})
    update_expr = "SET " + ", ".join(f"#{k} = :{k}" for k in updates)
    expr_attr_names = {f"#{k}": k for k in updates}
    expr_attr_values = {f":{k}": v for k, v in updates.items()}
    table.update_item(
        Key={"id": lugar_id},
        UpdateExpression=update_expr,
        ExpressionAttributeNames=expr_attr_names,
        ExpressionAttributeValues=expr_attr_values,
    )
    item.update(updates)
    return resp(200, item)


def delete(lugar_id):
    result = table.get_item(Key={"id": lugar_id})
    item = result.get("Item")
    if not item or item.get("entity_type") != "lugar":
        return resp(404, {"message": "No encontrado"})
    table.delete_item(Key={"id": lugar_id})
    return resp(200, {"message": "Eliminado", "id": lugar_id})


def handler(event, context):
    method = event.get("httpMethod", "GET")
    path = event.get("path", "/api/lugares")
    try:
        if method == "GET" and path == "/api/lugares":
            return list_all()
        if method == "GET" and path.startswith("/api/lugares/"):
            lugar_id = path.split("/")[-1]
            return get_one(lugar_id)
        if method == "POST" and path == "/api/lugares":
            return create(json.loads(event.get("body", "{}")))
        if method == "PUT" and path.startswith("/api/lugares/"):
            lugar_id = path.split("/")[-1]
            return update(lugar_id, json.loads(event.get("body", "{}")))
        if method == "DELETE" and path.startswith("/api/lugares/"):
            lugar_id = path.split("/")[-1]
            return delete(lugar_id)
        return resp(405, {"message": "Metodo no permitido"})
    except Exception as e:
        return resp(500, {"message": "Error interno", "error": str(e)})
