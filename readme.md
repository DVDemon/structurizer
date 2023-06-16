# Шаблон проекта в Structurizr DSL

## Описание

Пример предназначен для демонстрации шаблона HLD с ичпользованием Structurizr
Пример состоит из следующих частей:
* landscape_model.dsl - модель "Ландшафта" которая используется в режиме read-only. Она генерируется по архитектурному репозиторию (например, из Sparx EA)
* model.dsl - файл с моделями проекта
* deployment_model.dsl -файл с диаграмами развертывания
* workspace.dsl - корневой файл проекта. Подключает все остальные и содержит описание представлений (view)
* Директори decisions - папка с Architecture Decision Records (ADR) проекта
* Директория documentation - папка с документацией проекта в формате MarkDown
* Директория export_tools - папка с примерами скриптов по автоматизации работы с Structurizr OnPremise

## Запуск

**docker-compose up -d**

## Примеры команд CLI

Экспорт модели в OnPremise репозиторий с помощью докер контейнера structurizr/cli:

*docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli push -url http://some_ip:some_port/api -id 1 -key f4efddc4-ef85-4efd-aa8b-3020ce351413 -secret 470bb115-9aa6-43ec-b827-bf0058150d8c -workspace workspace.dsl*

Экспорт модели в json формат с помощью докер контейнера structurizr/cli:

*docker run -it --rm -v /Users/dvdemon/src/structurizer:/usr/local/structurizr structurizr/cli export -workspace workspace.dsl -format json*

[Инструкция по спользованию CLI](https://github.com/structurizr/cli)

## Пример автоматизации по работе со Structurizr OnPremise 

**python3 diagram_check.py**

* Вывод на экран всех компонент продукта
* Выгрузка реестра технологий продукта

**python3 deployment.py**

* Формирование шаблона для паспорта стенда в XLS

## Как выгрузить offline html

Offline html выгружается c помощью скрипта https://github.com/structurizr/puppeteer.git
Требует node.js и https://developer.chrome.com/docs/puppeteer/

node export-documentation.js http://localhost:8080/workspace/documentation

## Api generator

Инструмент по генерации Markdown документации по Swagger
* [https://mermade.github.io/widdershins/ConvertingFilesBasicCLI.html](https://mermade.github.io/widdershins/ConvertingFilesBasicCLI.html)
* sudo npm install -g widdershins
* widdershins --environment env.json swagger.json -o myOutput.md

## Полезные ссылки
* [Описание языка моделирования](https://github.com/structurizr/dsl/blob/master/docs/language-reference.md)
* [ADR tool](https://asiermarques.medium.com/implementing-a-workflow-for-your-architecture-decisions-records-ab5b55ee2a9d)
* [Пример модели от Саймона Брауна](https://github.com/structurizr/examples/blob/main/dsl/big-bank-plc/workspace.dsl)

## Конфигурирование Structurizr OnPremise

* [Ссылка на документацию](https://structurizr.com/share/18571/documentation) паролль и логин "по умолчанию" structurizr/password
