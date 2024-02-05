import json
import os
import logging
import hashlib
import hmac
import requests

from base64 import b64encode
from datetime import datetime, timedelta, timezone
from atlassian import Confluence






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

def find_all(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += len(sub) # use start += 1 to find overlapping matches

def get_diagram(workspace_id,code):
    return code+'.png'

def export_confluence(content,
                      images,
                      confluence_url,
                      confluence_user,
                      confluence_password,
                      confluence_page_id,
                      page_name):
    try:
        confluence = Confluence(
            url=confluence_url,
            username = confluence_user,
            password = confluence_password
            )

        for i in images:
            i = 'images/'+i
            print(i)
            if os.path.isfile(i):
                confluence.attach_file(i, page_id=confluence_page_id)
            else:
                print('!error: file not found '+i)
        
        print('content ...')
        confluence.update_existing_page(page_id=confluence_page_id,
                                        title = page_name,
                                        body=content,
                                        representation='wiki',
                                        type='page',
                                        minor_edit=False)
        # confluence.update_or_create(confluence_parent_page_id, 
        #                             page_title, 
        #                             content, 
        #                             representation='wiki', 
        #                             full_width=False)

    except Exception as e:
        logging.error(e)

def convert_md_wiki(content):
    with open('documentation.md','w') as f:
        f.write(content)

    os.system("pandoc -f markdown -t jira documentation.md -o documentation.txt")

    with open('documentation.txt') as f:
        result = f.read()
        return result


def main():
    logging.basicConfig(filename='conf_connect.log', filemode='w', level=logging.DEBUG)

    STRUCTURIZR_URL     = os.environ['STRUCTURIZR_URL']
    CONFLUENCE_URL      = os.environ['CONFLUENCE_URL']
    CONFLUENCE_USER     = os.environ['CONFLUENCE_USER']
    CONFLUENCE_PASSWORD = os.environ['CONFLUENCE_PASSWORD']
    PAGE_ID             = os.environ['PAGE_ID']
    # PARENT_PAGE_ID      = os.environ['PARENT_PAGE_ID']
    # PAGE_TITLE          = os.environ['PAGE_TITLE']

    #id='4'
    WORKSPACE_ID = os.environ['WORKSPACE_ID']

    #apiKey='23e04769-2f88-4fde-b277-165617ed4cce'
    API_KEY      = os.environ['API_KEY']

    #apiSecret='1b13aba3-58bc-4632-852c-d7f95a6bebde'
    API_SECRET   = os.environ['API_SECRET']
    API_URL      = STRUCTURIZR_URL+ '/api/workspace/'
    apiUrl=API_URL+WORKSPACE_ID 

    # Загружаем картинки
    os.system("node export-diagrams.js "+STRUCTURIZR_URL+"/share/"+WORKSPACE_ID+"/diagrams png")

    # Формируем контент запроса
    method ='GET'
    content=''
    content_type=''
    url_path = '/api/workspace/'+WORKSPACE_ID
    definition_md5 = _md5(content)
    nonce = _number_once()
    message_digest = _message_digest(
                method,
                url_path,
                definition_md5,
                content_type,
                nonce,
            )
    message_hash = _base64_str(_hmac_hex(API_SECRET, message_digest))

    # Заголовки для авторизации
    headers = {
                "X-Authorization": f"{API_KEY}:{message_hash}",
                "Nonce": nonce,
            }

    print("loading documentation --------")

    resp = requests.get(url=apiUrl, headers=headers)

    if(resp.status_code==200):
        page_name  = 'Архитектура'
        workspace  = resp.json()
        if 'name' in workspace:
            page_name = workspace['name']

        if 'documentation' in workspace:
            documentation = workspace['documentation']
            if 'sections' in documentation:
                images = set()
                total_content = ''
                print('importing -------------')

                for section in documentation['sections']:
                    content  = section['content']
                    pattern = '(embed:'
                
                    diagrams = list(find_all(content,pattern))
                    while len(diagrams)>0:
                        start_idx = diagrams[0]
                        end_idx = content.find(')', start_idx)
                        code_start = content.find(':', start_idx)+1
                        code = content[code_start:end_idx].rstrip()
                        image = get_diagram(36921,code)
                        images.add(image)
                        print(f'changing [{code}]->[{image}]')
                        new_content = content[:(start_idx+1)] + image+content[end_idx:]
                        content = new_content
                        diagrams = list(find_all(content,pattern))

                    total_content += content

                print('converting markdown -----')
                wiki_content = convert_md_wiki(total_content)

                print('exporting ---------------')
                export_confluence(wiki_content,
                                  images,
                                  CONFLUENCE_URL,
                                  CONFLUENCE_USER,
                                  CONFLUENCE_PASSWORD,
                                  PAGE_ID,
                                  page_name)
            else:
                print('error: no sections in documentation found')
        else:
            print('error: no documentation found')

if __name__ == "__main__":
    main()