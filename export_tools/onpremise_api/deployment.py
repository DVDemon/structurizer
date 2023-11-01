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
id='1'
apiKey='f4efddc4-ef85-4efd-aa8b-3020ce351413'
apiSecret='470bb115-9aa6-43ec-b827-bf0058150d8c'
apiUrl='http://localhost:8081/api/workspace/'+id # предположим что нам нужен именно workspace 1

# Формируем контент запроса
method ='GET'
content=''
content_type=''
url_path = '/api/workspace/'+id # предположим что нам нужен именно workspace 1
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
    data                = resp.json()
    product_name        = data['name']
    model               = data['model']

    peoples             = model['people'] # Акторы
    software_systems    = model['softwareSystems'] # Системы
    deployment_nodes    = model['deploymentNodes'] # Стенды
    documentation       = data['documentation']['sections'] # Документация 
    adrs                = data['documentation']['decisions'] # Перечень архитектурных решений
    imsgaes             = data['documentation']['images'] # Картинки (если есть)
    views               = data['views'] # диаграммы


    containers = dict()
    
    for s in software_systems:
        if 'containers' in s:
            for c2 in s['containers']:
                containers[c2["id"]]=c2
                
    # Создадим XLS с паспортом стенда   
    # нам потребуется библиотечка: pip3 install xlsxwriter
    import xlsxwriter

    workbook = xlsxwriter.Workbook("паспорт.xlsx")
    worksheet_components = workbook.add_worksheet("Боевой стенд")

    worksheet_components.write(0,0,'#')
    worksheet_components.write(0,1,'ИС (продукт)')
    worksheet_components.write(0,2,'Назначение сервера')
    worksheet_components.write(0,3,'Имя сервера')
    worksheet_components.write(0,4,'IP-address')
    worksheet_components.write(0,5,'Тип сервера (VM/k8s)')
    worksheet_components.write(0,6,'OC')
    worksheet_components.write(0,7,'Pods')
    worksheet_components.write(0,8,'CPU')
    worksheet_components.write(0,9,'RAM,Gb')
    worksheet_components.write(0,10,'HDD,Gb')
    worksheet_components.write(0,11,'Системное ПО')
    worksheet_components.write(0,12,'Прикладное ПО')
    worksheet_components.write(0,13,'Комментарий')

    def process_node(worksheet_components,i,d_node):
        applications = ''
        if 'containerInstances' in d_node:
            if ('properties' in d_node):
                for prop in d_node['properties'].keys():
                    prop_name = prop
                    prop_value = d_node['properties'][prop]                
                    if prop_name == 'os':
                         worksheet_components.write(i,6,prop_value)
                    if prop_name == 'cpu':
                         worksheet_components.write(i,8,prop_value)
                    if prop_name == 'ram':
                         worksheet_components.write(i,9,prop_value)
                    if prop_name == 'hdd':
                         worksheet_components.write(i,10,prop_value)
               
            worksheet_components.write(i,0,i)
            worksheet_components.write(i,1,product_name)
            if('description' in d_node):
                worksheet_components.write(i,2,d_node['description'])
            worksheet_components.write(i,3,d_node['name'])

            tags = d_node['tags'].split(',')
            system_applications = ''
            for tag in tags:
                if not tag in {'Element','Deployment Node'}:
                    system_applications += tag + '; '
            worksheet_components.write(i,6,system_applications)

            for container_instance in d_node['containerInstances']:
                c_id = container_instance['containerId']
                applications += f"{containers[c_id]['name']}; "
            worksheet_components.write(i,12,applications)
            return i+1
        else:
            if 'children' in d_node:
                for c in d_node['children']:
                    i = process_node(worksheet_components,i,c)
        return i

    i = 1
    for d_node in deployment_nodes:
        i = process_node(worksheet_components,i,d_node)
        
    workbook.close()