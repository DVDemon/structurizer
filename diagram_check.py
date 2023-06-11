import hashlib
import hmac
from base64 import b64encode
from datetime import datetime, timedelta, timezone
import requests


def _number_once() -> str:
    """Return the number of milliseconds since the epoch."""
    return str(
            int((datetime.utcnow() - datetime(1970, 1, 1)) / timedelta(milliseconds=1))
        )


def _hmac_hex(secret: str, digest: str) -> str:
    """Hash the given digest using HMAC+SHA256 and return the hex string."""
    return hmac.new(
        secret.encode("utf-8"), digest.encode("utf-8"), "sha256"
    ).hexdigest()


def _md5(content: str) -> str:
    """Return the MD5 hash of the given string."""
    return hashlib.md5(content.encode("utf-8")).hexdigest()

def _base64_str(content: str) -> str:
    """Return the base64 encoded string."""
    return b64encode(content.encode("utf-8")).decode("utf-8")

def _message_digest(
    http_verb: str,
    uri_path: str,
    definition_md5: str,
    content_type: str,
    nonce: str,
    ) -> str:
    """Assemble the complete message digest."""
    return f"{http_verb}\n{uri_path}\n{definition_md5}\n{content_type}\n{nonce}\n"

apiKey='f4efddc4-ef85-4efd-aa8b-3020ce351413'
apiSecret='470bb115-9aa6-43ec-b827-bf0058150d8c'
apiUrl='http://localhost:8081/api/workspace/1'

method ='GET'
content=''
content_type=''
url_path = '/api/workspace/1'
definition_md5 = _md5(content)
nonce = _number_once()
message_digest = _message_digest(
            method,
            url_path,
            definition_md5,
            content_type,
            nonce,
        )
message_hash = _base64_str(_hmac_hex(apiSecret, message_digest))

headers = {
            "X-Authorization": f"{apiKey}:{message_hash}",
            "Nonce": nonce,
        }

resp = requests.get(url=apiUrl, headers=headers)

if(resp.status_code==200):
    model = resp.json()['model']

    peoples = model['people']
    software_systems = model['softwareSystems']
    deployment_nodes = model['deploymentNodes']

    for s in software_systems:
        print(f"system: {s['name']}")
        if 'containers' in s:
            for c2 in s['containers']:
                print(f" - container: {c2['name']} : {c2['technology']}")
                if 'components' in c2:
                    for c3 in c2['components']:
                        print(f"   - component: {c3['name']}")
                
