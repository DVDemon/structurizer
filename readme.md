# Шаблон проекта в Structurizr DSL

## Описание

Пример предназначен для демонстрации шаблона HLD с ичпользованием Structurizr

## Полезные ссылки
* [Описание языка моделирования](https://github.com/structurizr/dsl/blob/master/docs/language-reference.md)

* [ADR tool](https://asiermarques.medium.com/implementing-a-workflow-for-your-architecture-decisions-records-ab5b55ee2a9d)

* [Пример модели от Саймона Брауна](https://github.com/structurizr/examples/blob/main/dsl/big-bank-plc/workspace.dsl)

## Конфигурирование Structurizr OnPremise

* [Ссылка на документацию](https://structurizr.com/share/18571/documentation) паролль и логин "по умолчанию" structurizr/password
* [Инструкция по спользованию CLI](https://github.com/structurizr/cli)

### Примеры команд CLI
docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli push -url http://192.168.1.82:8081/api -id 1 -key f4efddc4-ef85-4efd-aa8b-3020ce351413 -secret 470bb115-9aa6-43ec-b827-bf0058150d8c -workspace workspace.dsl

docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli export -workspace workspace.dsl -format json


## Api generator

Инструмент по генерации Markdown документации по Swagger
* https://mermade.github.io/widdershins/ConvertingFilesBasicCLI.html
* sudo npm install -g widdershins
* widdershins --environment env.json swagger.json -o myOutput.md
