import hashlib
import hmac
from base64 import b64encode
from datetime import datetime, timedelta, timezone
import requests


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
apiKey='42853b91-b32e-4922-80e7-2774c8cbe0c4'
apiSecret='d5d21ea9-b9b0-473a-8bd8-df3becd33981'
apiUrl='http://localhost:8081/api/workspace/2' # предположим что нам нужен именно workspace 1

# Формируем контент запроса
method ='GET'
content=''
content_type=''
url_path = '/api/workspace/2' # предположим что нам нужен именно workspace 1
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
    

    software_systems    = model['softwareSystems'] # Системы


    # ----------------------------------------------------------------------------------
    # распечатаем все компоненты (микросервисы) и соберем реестр используемых технологий 
    tech = set()
    containers = dict()
    relationships = list()
    systems    = dict()
    
    print('Системы использованные в решении:')
    for s in software_systems:
        print(f"system: {s['name']}")
        systems[s["id"]]=s

        if 'relationships' in s:
            for r in s['relationships']:
                relationships.append(r)

        if 'containers' in s:
            for c2 in s['containers']:
                print(f" - container: {c2['name']}")
                containers[c2["id"]]=c2
                if 'relationships' in c2:
                    for r in c2['relationships']:
                        relationships.append(r)
                if 'technology' in c2:
                    tech.add(c2['technology'])
                if 'components' in c2:
                    for c3 in c2['components']:
                        print(f"   - component: {c3['name']}")
                        if 'technology' in c3:
                            tech.add(c3['technology'])
    print()
    print('Использованны технологии:')
    for t in tech:
        print(f' - {t}')      
    
    print()
    print('Вызовы:')

    import xlsxwriter

    workbook = xlsxwriter.Workbook("relations.xlsx")
    worksheet_components = workbook.add_worksheet("Взаимодействия")

    worksheet_components.write(0,0,'#')
    worksheet_components.write(0,1,'Источник')
    worksheet_components.write(0,2,'Получатель')
    worksheet_components.write(0,3,'Описание')
    worksheet_components.write(0,4,'Технология')


    i = 1
    for r in relationships:
        worksheet_components.write(i,0,i)
        worksheet_components.write(i,3,r["description"])
        if 'technology' in r:
            worksheet_components.write(i,4,r["technology"])
        print(f'{r["id"]}: {r["description"]}   {r["sourceId"]} -> {r["destinationId"]}')

        if r["sourceId"] in systems:
            print (f'Источник: {systems[r["sourceId"]]["name"]}')
            worksheet_components.write(i,1,systems[r["sourceId"]]["name"])
        elif r["sourceId"] in containers:
            print (f'Источник: {containers[r["sourceId"]]["name"]}')
            worksheet_components.write(i,1,containers[r["sourceId"]]["name"])

        if r["destinationId"] in systems:
            print (f'Источник: {systems[r["destinationId"]]["name"]}')
            worksheet_components.write(i,2,systems[r["destinationId"]]["name"])
        elif r["destinationId"] in containers:
            print (f'Источник: {containers[r["destinationId"]]["name"]}')
            worksheet_components.write(i,2,containers[r["destinationId"]]["name"])

        i +=1
    
    workbook.close()