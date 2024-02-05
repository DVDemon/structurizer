from atlassian import Confluence
import os

# os.system("node export-documentation.js http://localhost:8080/workspace/documentation")

os.system("pandoc -f html -t jira documentation.html -o documentation.txt")

# # Create a Confluence instance


# # Read the text file
with open('documentation.txt', 'r') as file:
    content = file.read()

# # Convert the text file to Confluence format
# confluence_content = confluence.convert_wiki_to_storage(content)

# print(confluence_content)

# Upload the file to Confluence
import logging

logging.basicConfig(filename='conf_connect.log', filemode='w', level=logging.DEBUG)

try:
    confluence = Confluence(
        url='https://bwiki.beeline.ru',
        # username='Tech_STRUCTURIZR_MS@beeline.ru',
        # password='+ki2p],mxfsr1oq5',
        username = 'dmvldzyuba@beeline.ru',
        password = '3.14Oneer.2',
        # verify_ssl=False
        )
    
    confluence.update_or_create(362744056, 
                                'Публикация в confluence', 
                                content, 
                                representation='wiki', 
                                full_width=False)

except Exception as e:
    logging.error(e)