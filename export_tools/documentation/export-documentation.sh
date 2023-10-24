# Для этого нам понадобится скрипт (клонируем репозиторий):
# git clone https://github.com/structurizr/puppeteer.git
# Он для своей работы потребует node.js https://nodejs.org/ru/download
# Устанавливаем Puppeteer:
# npm install puppeteer

node export-documentation.js http://localhost:8080/workspace/documentation
# Создаем страницу в Confluence
# Загружаем полученый documentation.html как attach
# С помощью macro "HTML-bobswift" показываем html (Location HTML Data: ^documentation.html)