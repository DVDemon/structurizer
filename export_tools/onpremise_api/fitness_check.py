import requests
import hashlib
import hmac
from base64 import b64encode
from datetime import datetime, timedelta
from sqlalchemy import create_engine

import fitness_functions

# https://www.javainuse.com/onlineBcrypt
# bcrypt $2a$10$nx.q74ZbUamFr20p0vsegOBkVt8jGk2kaXEEsAuUvwrnavJ6aLIqu

#structurizr.apiKey=arch-code.arch-code.cloud.vimpelcom.ru

# password            = "1234567890"
# url_onpremises      = "http://localhost:8081/api/workspace"
# url_onpremises_base = "http://localhost:8081/api"
# url_onpremises_web  = "http://localhost:8081"

password            = "1234567890"
url_onpremises      = "https://structurizr.vimpelcom.ru/api/workspace"
url_onpremises_base = "https://structurizr.vimpelcom.ru/api"
url_onpremises_web  = "https://structurizr.vimpelcom.ru"


# ----------------------------
# Structurizr Helper Functions
# ----------------------------

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

# -------------------
# Classes
# -------------------
class Workspace:
    def __init__(self,id,name,description,apiKey,apiSecret,privateUrl,publicUrl) -> None:
        self.id = id
        self.name = name
        self.description = description
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.privateUrl = privateUrl
        self.publicUrl = publicUrl
    
    def print(self) -> None:
        print("id=",self.id)
        print("name=",self.name)
        print("description=",self.description)
        print("apiKey=",self.apiKey)
        print("apiSecret=",self.apiSecret)
        print("privateUrl=",self.privateUrl)
        print("publicUrl=",self.publicUrl)                     

def load_workspace(wrk : Workspace):
    apiKey=wrk.apiKey
    apiSecret=wrk.apiSecret
    apiUrl=url_onpremises_base+wrk.privateUrl
    method ='GET'
    content=''
    content_type=''
    url_path = '/api'+wrk.privateUrl 
    definition_md5 = _md5(content)
    nonce = _number_once()
    message_digest = _message_digest(
                method,
                url_path,
                definition_md5,
                content_type,
                nonce)
    
    message_hash = _base64_str(_hmac_hex(apiSecret, message_digest))

    headers = {
                "X-Authorization": f"{apiKey}:{message_hash}",
                "Nonce": nonce
            }

    resp = requests.get(url=apiUrl, headers=headers)

    if(resp.status_code==200):
        return resp.json()
    else:
        return dict()

def get_workspace_cmdb(data):
    cmdb = ''
    systems             = dict()
    model               = data['model']
    views               = data['views']

    if 'softwareSystems' in model:
        software_systems    = model['softwareSystems'] # Системы  
        for s in software_systems:
            systems[s['id']] = s

    if 'systemContextViews' in views:
        context_views = views['systemContextViews']
        for v in context_views:
            if 'softwareSystemId' in v:
                softwareSystemId = v['softwareSystemId']
                if softwareSystemId in systems:
                    system = systems[softwareSystemId]
                    if 'properties' in system:
                        properties = system['properties']
                        if 'cmdb' in properties:
                            return properties['cmdb']
                        else:
                            print(f'- Нет cmdb кода системы {system["name"]}')
                    else:
                        print(f'- Нет properties системы {system["name"]}')
    return cmdb

def main():
    # 1111 это мой пароль для пользователя postgres
    engine = create_engine("postgresql+psycopg2://pguser:pguser@localhost/pgdb")
    engine.connect()

    # engine.execute('CREATE TABLE IF NOT EXISTS ptr_status'+
    #                '(system_id varchar(256) not null,'+
    #                'deployment int not null,'+
    #                'deployment_errors int not null,'+
    #                'deployment_date date not null,'+
    #                'primary key (system_id));')

    print(engine)

    headers = {
                "X-Authorization": password
            }

    resp = requests.get(url=url_onpremises, headers=headers)

    print(f'request{url_onpremises} with {password}')

    if(resp.status_code==200):
        data  = resp.json()

        for w in data["workspaces"]:
            print()
            wrk = Workspace(w["id"],
                            w["name"],
                            w["description"],
                            w["apiKey"],
                            w["apiSecret"],
                            w["privateUrl"],
                            w["publicUrl"])
           
            print(f'{wrk.id}: {wrk.name}')
            print("Loading workspace ...",end='')
            wrk_data = load_workspace(wrk)
            if "name" in wrk_data:
                modified_date = wrk_data['lastModifiedDate']
                print(modified_date)

                cmdb = get_workspace_cmdb(wrk_data)

                
                for f in fitness_functions.get_functions():
                    foo = getattr(fitness_functions, f)
                    result = foo(wrk_data)

                    if len(cmdb)>0:
                        print(f'[{len(result)}] {f}')
                        format = 'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                        deployment_status = 1
                        if(len(result)>0):
                            deployment_status = 0
                        print(f'CMDB код системы {cmdb} : errors = {len(result)}')

                        # if(deployment_status):
                        #     engine.execute("update fdm_ptr_artifacts set "+
                        #                     " "+f+"_link='"+url_onpremises_web+"/share/"+str(wrk.id)+"'"+
                        #                     ", "+f+"_ts=TO_TIMESTAMP('"+modified_date+"','"+format+"') "+
                        #                     ","+f+"_source='Structurizr' where cmdb_mnem='"+cmdb+"'")
                        #     engine.execute("insert into fdm_ptr_artifacts(cmdb_mnem,"+f+"_link,"+f+"_ts, "+f+"_source) "+
                        #                     "select '"+cmdb+"','"+url_onpremises_web+"/share/"+str(wrk.id)+"', TO_TIMESTAMP('"+modified_date+"','"+format+"') , 'Structurizr' "+
                        #                     "where not exists (select 1 from fdm_ptr_artifacts where cmdb_mnem='"+cmdb+"')")
                    else:
                        print(f'[Critical] Не задан CMDB code для системы с контекстной диаграммой')
            else:
                print("Error")
    else:
        print(f'{resp.status_code} {resp.reason} {resp.content}')
            

if __name__ == "__main__":
    main()