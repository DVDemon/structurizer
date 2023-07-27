# coding: utf-8
import json
import requests
from requests.auth import HTTPBasicAuth

BASE_URL = "https://xxx/rest/api/content"
USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.82 Safari/537.36"


def get_page_ancestors(auth, pageid):
    url = '{base}/{pageid}?expand=ancestors'.format(base=BASE_URL,pageid=pageid)
    r = requests.get(url, auth=auth, headers={'Content-Type': 'application/json', 'USER-AGENT': USER_AGENT})
    r.raise_for_status()
    return r.json()['ancestors']


def get_page_info(auth, page_id):
    url = '{base}/{page_id}'.format(base=BASE_URL, page_id=page_id)
    r = requests.get(url, auth=auth, headers={'Content-Type': 'application/json', 'USER-AGENT': USER_AGENT})
    r.raise_for_status()
    return r.json()

def write_data(auth, title, html, page_id):
    info = get_page_info(auth, page_id)
    ver = int(info['version']['number']) + 1
    ancestors = get_page_ancestors(auth, page_id)
    anc = ancestors[-1]
    del anc['_links']
    del anc['_expandable']
    del anc['extensions']

    info['title'] = title
    data = {
        'id': str(page_id),
        'type': 'page',
        'title': info['title'],
        'version': {'number': ver},
        'ancestors': [anc],
        'body': {
            'storage':
                {
                    'representation': 'storage',
                    'value': str(html),
                }
        }
    }

    data = json.dumps(data)

    url = '{base}/{page_id}'.format(base=BASE_URL, page_id=page_id)

    our_headers = {'Content-Type': 'application/json', 'USER-AGENT': USER_AGENT}

    r = requests.put(
        url,
        data=data,
        auth=auth,
        headers=our_headers
    )

    r.raise_for_status()

    return ""


def read_data(auth, page_id):
    url = '{base}/{page_id}?expand=body.storage'.format(base=BASE_URL, page_id=page_id)
    r = requests.get(url,auth=auth,headers={'Content-Type': 'application/json', 'USER-AGENT': USER_AGENT})
    r.raise_for_status()
    return r


def main():

    auth = HTTPBasicAuth("","")
    pageid = 999999

    with open('documentation.html', 'r') as file:
        html = file.read() 
        print (html)
        write_data(auth, "test product", html, pageid)
    return

if __name__ == "__main__": main()