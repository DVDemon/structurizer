# DSL
https://github.com/structurizr/dsl/blob/master/docs/language-reference.md

# ADR tool
https://asiermarques.medium.com/implementing-a-workflow-for-your-architecture-decisions-records-ab5b55ee2a9d


# Configure onpremises

<!-- https://structurizr.com/share/18571/documentation -->

If deployment was successful, navigating to http://localhost:8080 should open the Structurizr on-premises installation. You can then sign in using the default credentials (structurizr and password).

# CLI

<!-- https://github.com/structurizr/cli -->
https://github.com/structurizr/cli/tree/master/docs

docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli push -url http://192.168.1.82:8081/api -id 1 -key f4efddc4-ef85-4efd-aa8b-3020ce351413 -secret 470bb115-9aa6-43ec-b827-bf0058150d8c -workspace workspace.dsl

docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli export -workspace workspace.dsl -format json

# Install freeipa

<!-- https://itsecforu.ru/2021/09/01/%F0%9F%90%B3-%D0%B7%D0%B0%D0%BF%D1%83%D1%81%D0%BA-%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0-freeipa-%D0%B2-%D0%BA%D0%BE%D0%BD%D1%82%D0%B5%D0%B9%D0%BD%D0%B5%D1%80%D0%B0%D1%85-docker-podman/ -->

git clone https://github.com/freeipa/freeipa-container.git
cd freeipa-container
sudo docker build -t freeipa-server -f Dockerfile.fedora-34 .

# api generator
https://mermade.github.io/widdershins/ConvertingFilesBasicCLI.html
sudo npm install -g widdershins
widdershins --environment env.json swagger.json -o myOutput.md
