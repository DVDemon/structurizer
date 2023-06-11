user = person "Пользователь" "Заказчик услуги, осуществляющий наблюдение за ребенком" "Customer"

        guard_system = softwareSystem "Мобильный телохранитель" {

            #clien app
            group "Клиентские приложения" {
                client_mobile_app   =  container "Мобильное приложение клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "Android/iOS app" "MobileApp"
                client_web_app      =  container "Веб приложение клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "Web Browser" "WebBrowser"
            }

            client_mobile_app -> payment_system "Оплата"
            client_web_app -> payment_system "Оплата"

            #bff
            group "API клиента" {
                client_mobile_app_backend  =  container "Backend мобильного приложения клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "GoLang" "Container"
                client_web_app_backend     =  container "Backend веб приложения клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "GoLang" "Container"
    
                client_mobile_app       -> client_mobile_app_backend "Получение данных/ нотификаций/ выполнение запросов" "WebSocket"
                client_web_app          -> client_web_app_backend "Получение данных/ нотификаций/ выполнение запросов" "WebSocket"
            }

            
            # containers
            sso = container "Single Sign On" "Аутентификация и авторизация пользователей" "KeyCloak"
            client_mobile_app       -> sso "Получение данных/нотификаций" "REST/HTTP :80"
            client_web_app          -> sso "Получение данных/нотификаций" "REST/HTTP :80"

            bpm = container "BPM" "Реализация сценариев трэкинга" "Camunda"

            client_mobile_app_backend -> bpm "Получение данных/ нотификаций/ выполнение запросов" "REST/HTTP :80"
            client_web_app_backend ->  bpm "Получение данных/ нотификаций/ выполнение запросов" "REST/HTTP :80"

            bpm -> mlc "Запрос данных по геопозиции детей" "REST/HTTP :80"
            
            group  "Доменные сервисы" {
                billing   = container "Billing" "Прием оплат и контроль расходов" "GoLang" "Container" {
                    billing_facade = component "API" "Интерфейс для работы с подписками" "GoLang"
                    billing_database = component "Subscription Database" "Информация о балансах" "PostgreSQL" "Database"
                    billing_controller = component "Controler" "Сервис учета использования дронов" "GoLang"
                    billing_queue  = component "Брокер" "Брокер для учета использования дронов" "RabbitMQ/MQTT" "AMQP"
                    biiling_ussd_gateway = component "Шлюз"
                    billing_queue -> biiling_ussd_gateway "связь" "REST/HTTP :80"
                    billing_queue -> billing_controller "учет использования дрона" "REST/HTTP :80"

                    billing_facade -> billing_database "запрос остатка баланса" "REST/HTTP :80"
                    billing_facade -> billing_database "списание баланса" "REST/HTTP :80"
                    billing_facade -> billing_database "пополнение баланса" "REST/HTTP :80"
                    
                    payment_system -> billing_facade "пополнение баланса" "REST/HTTP :80"
                    billing_controller -> billing_database "списание баланса" "REST/HTTP :80"
                    bpm -> billing_facade "Запрос баланса/осуществление платежа" "REST/HTTP :80"

                }

                inventory = container "Inventory" "Учет дронов" "GoLang" "Container"{
                    inventory_facade = component "API" "API учета информации о дронах" "Golang"
                    inventory_database = component "Реестр дронов" "Учет информации о дронах" "PosthreSQL" "Database"
                    inventory_facade -> inventory_database "Запрос и обновление информации о дронах" "TCP :5453"

                    bpm -> inventory_facade "Запрос данных о свободных дронах/Резервация" "REST/HTTP :80"
                }

                crm       = container "Clients" "Учет пользователей" "GoLang" "Container"{
                    crm_facade = component "API" "Интерфейс для работы с клиентом" "Golang"
                    crm_database = component "Client Database" "Информация о клиентах" "PostgreSQL" "Database"
                    crm_facade -> crm_database "запрос/изменение данных о пользователях" "TCP :5432"
                    sso -> crm_facade "получение профиля клиента по id" "REST/HTTP :80"
                    sso -> crm_facade "ауктентификация клиента" "REST/HTTP :80"
                    bpm -> crm_facade "Запрос данных о клиенте и его детях" "REST/HTTP :80"
                }
                

                tracker   = container "Tracker" "Подсистема трэкинга дронов в реальном времени" "GoLang" "Container"{
                    tracker_facade = component "API" "Интерфейс для работы с дронами" "GoLang"
                    tracker_status = component "Данные дронов" "Информация о позиции и данных дронов" "Redis" "Database"
                    tracker_queue  = component "Брокер" "Брокер для взаимодействия с дронами" "RabbitMQ/MQTT" "Queue"
                    tracker_controler = component "Controler" "Сервис управления дронами" "GoLang"
                    

                    tracker_facade -> tracker_status "Запрос данных о статусе дрона" "REST/HTTP :80"
                    tracker_facade -> tracker_controler "Управление дроном" "REST/HTTP :80"

                    tracker_controler -> tracker_queue "Команды управления" "MQTT :1883"                   
                    tracker_controler -> tracker_status "Обновление актуального статуса дронов" "REST/HTTP :80"
                    tracker_controler -> billing_queue "Данные об использовании дрона" "MQTT :1883"
                    tracker_controler -> billing_facade "запрос остатка баланса" "REST/HTTP :80"
                    tracker_controler -> inventory_facade "Обновдение информации о дронах" "REST/HTTP :80"
                    tracker_controler -> security "Вызов службы охраны на проишествие" "REST/HTTP :80"

                    billing_controller -> tracker_facade "Информирование об исчерпании средств на подписке"

                    tracker_queue -> drone "Команды управления" "MQTT :1883"
                    tracker_queue -> tracker_controler "Телеметрия" "MQTT :1883"
                    tracker_queue -> tracker_controler "События безопасности" "MQTT :1883"
                    drone -> tracker_queue "Телеметрия" "MQTT :1883"
                    drone -> tracker_queue "События безопасности" "MQTT :1883"
                    drone -> client_mobile_app "Видео" "WebRTC :443"
                    drone -> client_web_app "Видео" "WebRTC :443"
                    bpm -> tracker_facade "Управление дроном" "REST/HTTP :80"

                }      
            }

            # Relations with customer
            user -> client_mobile_app "Управление услугой"
            user -> client_web_app "Управление услугой"
        }