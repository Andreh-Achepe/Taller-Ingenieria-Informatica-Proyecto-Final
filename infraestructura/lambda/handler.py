import json, boto3, os, uuid
from datetime import datetime


dynamodb = boto3.resource("dynamodb")
ses = boto3.client("ses")
table = dynamodb.Table(os.environ["TABLE_NAME"])
sender = os.environ["SENDER_EMAIL"]


def handler(event, context):
    body = json.loads(event.get("body", "{}"))

    item = {
        "id": str(uuid.uuid4()),
        "type": "booking",
        "user-mail": body["email"],
        "tramo": body["tramo"],
        "fecha": body["fecha"],
        "nombre": body["nombre"],
        "created_at": datetime.now().isoformat(),
    }
    table.put_item(Item=item)

    ses.send_email(
        Source=sender,
        Destination={"ToAddresses": [body["email"]]},
        Message={
            "Subject": {"Data": "Confirmación - AntiTurismo Puerto Montt"},
            "Body": {
                "Text": {
                    "Data": (
                        f"Hola {body['nombre']},\n\n"
                        f"Tu reserva para el tramo '{body['tramo']}' "
                        f"el {body['fecha']} ha sido confirmada.\n\n"
                        "¡Gracias por viajar con AntiTurismo!"
                    )
                }
            },
        },
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Reserva confirmada, revisa tu email"}),
    }
