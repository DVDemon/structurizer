# используем https://pypi.org/project/markdown-to-json/
# pip install markdown-to-json

import hashlib
import hmac
from base64 import b64encode
from datetime import datetime, timedelta, timezone
import requests
import markdown_to_json

# Вспомогательные функции для прохождения актентификации в Structurizr

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


# Настройки доступа к репозиторию (лучше хранить не в коде, а в переменных окружения)
apiKey='f4efddc4-ef85-4efd-aa8b-3020ce351413'
apiSecret='470bb115-9aa6-43ec-b827-bf0058150d8c'
apiUrl='http://localhost:8081/api/workspace/1' # предположим что нам нужен именно workspace 1

# Формируем контент запроса
method ='GET'
content=''
content_type=''
url_path = '/api/workspace/1' # предположим что нам нужен именно workspace 1
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

# Заголовки для авторизации
headers = {
            "X-Authorization": f"{apiKey}:{message_hash}",
            "Nonce": nonce,
        }

resp = requests.get(url=apiUrl, headers=headers)

if(resp.status_code==200):
    data  = resp.json()
    product_name = data['name']
    model = data['model']
    

    peoples             = model['people'] # Акторы
    software_systems    = model['softwareSystems'] # Системы
    deployment_nodes    = model['deploymentNodes'] # Стенды
    documentation       = data['documentation']['sections'] # Документация 
    adrs                = data['documentation']['decisions'] # Перечень архитектурных решений
    imsgaes             = data['documentation']['images'] # Картинки (если есть)
    views               = data['views'] # диаграммы

    # ----------------------------------------------------------------------------------
    # распечатаем все компоненты (микросервисы) и соберем реестр используемых технологий 
    

    def print_dict(val,offset,is_usecase):
        if isinstance(val, list):
            if is_usecase:
                for v in val:
                    for i in range(offset):
                        print(' ',end='')
                    print_dict(v,offset+1,True)
        elif isinstance(val, dict):
            for k, v in val.items():
                if k.startswith('Use-cases') or is_usecase:
                    for i in range(offset):
                        print(' ',end='')
                    print(f'{k}:')
                    print_dict(v,offset+1,True)
                else:
                    print_dict(v,offset+1,False)
        else:
            if is_usecase:
                for i in range(offset):
                        print(' ',end='')
                print(val)

    for section in documentation:
        if '06_runtime_view.md'==section['filename']:
            markdown_content = section['content']
            json_conent = markdown_to_json.dictify(markdown_content)
            print_dict(json_conent,0,False)
              