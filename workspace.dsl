workspace {
    name "Мобильный телохранитель"
    description "демонстрационный пример для показа техник ведения проектной документацииы"
    !adrs decisions
    !docs documentation
    
    model {
        user = person "Пользователь" "Заказчик услуги, осуществляющий наблюдение за ребенком" "Customer"
        
        # child = person "Ребенок" "Объект, за которым осуществляется слежение" "Customer"

        payment_system = softwareSystem "Внешняя платежная система" "Регистрация платежей за сервис" "ExternalSystem"
        drone = softwareSystem "Дрон" "Автономный дрон" "ExternalSystem"
        security = softwareSystem "ЧОП" "Внешнее партнерское охранное агенство" "ExternalSystem"

        guard_system = softwareSystem "Мобильный телохранитель" {

            #clien app
            group "Клиентские приложения" {
                client_mobile_app   =  container "Мобильное приложение клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "Android/iOS app" "MobileApp"
                client_web_app      =  container "Веб приложение клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "Web Browser" "WebBrowser"
              #  child_mobile_app   =  container "Мобильное приложение ребенка" "Приложение для предоставления геолокации и вызова помощи"  "Android/iOS app" "MobileApp"
            }

            client_mobile_app -> payment_system "Оплата"
            client_web_app -> payment_system "Оплата"

            #bff
            group "API клиента" {
                client_mobile_app_backend  =  container "Backend мобильного приложения клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "go" "Container"
                client_web_app_backend     =  container "Backend веб приложения клиента" "Приложение для осуществления заказа услуги и контроля передвижения"  "go" "Container"
               # child_mobile_app_backend   =  container "Backend мобильного приложение ребенка" "Приложение для предоставления геолокации и вызова помощи"  "go" "Container"
    
                client_mobile_app       -> client_mobile_app_backend "Получение данных/ нотификаций/ выполнение запросов" "WebSocket"
                client_web_app          -> client_web_app_backend "Получение данных/ нотификаций/ выполнение запросов" "WebSocket"
                #child_mobile_app        -> child_mobile_app_backend "Получение данных/ нотификаций/ выполнение запросов" "WebSocket"
            }

            
            # containers
            sso = container "Single Sign On" "Аутентификация и авторизация пользователей" "KeyCloak"
            client_mobile_app       -> sso "Получение данных/нотификаций" "HTTP"
            client_web_app          -> sso "Получение данных/нотификаций" "HTTP"
            #child_mobile_app        -> sso "Получение данных/нотификаций" "HTTP"

            bpm = container "BPM" "Реализация сценариев трэкинга" "Camunda" {

            }

            client_mobile_app_backend -> bpm "Получение данных/ нотификаций/ выполнение запросов" "REST"
            client_web_app_backend ->  bpm "Получение данных/ нотификаций/ выполнение запросов" "REST"
            #child_mobile_app_backend -> bpm "Получение данных/ нотификаций/ выполнение запросов" "REST"

            group  "Доменные сервисы" {
                billing   = container "Billing" "Прием оплат и контроль расходов" "go" "Container" {
                    billing_facade = component "API" "Интерфейс для работы с подписками" "go"
                    billing_database = component "Subscription Database" "Информация о балансах" "PostgreSQL" "Database"
                    billing_controller = component "Controler" "Сервис учета использования дронов" "go"
                    billing_queue  = component "Брокер" "Брокер для учета использования дронов" "RabbitMQ/MQTT" "AMQP"

                    billing_queue -> billing_controller ->  "учет использования дрона"

                    billing_facade -> billing_database "запрос остатка баланса"
                    billing_facade -> billing_database "списание баланса"
                    billing_facade -> billing_database "пополнение баланса"
                    
                    payment_system -> billing_facade "пополнение баланса"
                    billing_controller -> billing_database "списание баланса"
                    bpm -> billing_facade "Запрос баланса/осуществление платежа" "REST"

                }

                


                inventory = container "Inventory" "Учет дронов" "go" "Container"{
                    inventory_facade = component "API" "API учета информации о дронах" "REST"
                    inventory_database = component "Реестр дронов" "Учет информации о дронах" "PosthreSQL" "Database"
                    inventory_facade -> inventory_database "Запрос и обновление информации о дронах"

                    bpm -> inventory_facade "Запрос данных о свободных дронах/Резервация" "REST"
                }

                


                crm       = container "Clients" "Учет пользователей" "go" "Container"{
                    crm_facade = component "API" "Интерфейс для работы с клиентом" "REST"
                    crm_database = component "Client Database" "Информация о клиентах" "PostgreSQL" "Database"
                    crm_facade -> crm_database "запрос/изменение данных о пользователях"
                    sso -> crm_facade "получение профиля клиента по id" "REST"
                    sso -> crm_facade "ауктентификация клиента" "REST"
                    bpm -> crm_facade "Запрос данных о клиенте и его детях" "REST"
                }
                

                tracker   = container "Tracker" "Подсистема трэкинга дронов в реальном времени" "go" "Container"{
                    tracker_facade = component "API" "Интерфейс для работы с дронами" "REST"
                    tracker_status = component "Данные дронов" "Информация о позиции и данных дронов" "Redis" "Database"
                    tracker_queue  = component "Брокер" "Брокер для взаимодействия с дронами" "RabbitMQ/MQTT" "Queue"
                    tracker_controler = component "Controler" "Сервис управления дронами" "go"
                    

                    tracker_facade -> tracker_status "Запрос данных о статусе дрона"
                    tracker_facade -> tracker_controler "Управление дроном" "REST"

                    tracker_controler -> tracker_queue "Команды управления" "MQTT"                   
                    tracker_controler -> tracker_status "Обновление актуального статуса дронов"
                    tracker_controler -> billing_queue "Данные об использовании дрона"
                    tracker_controler -> billing_facade "запрос остатка баланса"
                    tracker_controler -> inventory_facade "Обновдение информации о дронах" "REST"
                    tracker_controler -> security "Вызов службы охраны на проишествие" "REST"

                    billing_controller -> tracker_facade "Информирование об исчерпании средств на подписке"

                    tracker_queue -> drone "Команды управления" "MQTT"
                    tracker_queue -> tracker_controler "Телеметрия" "MQTT"
                    tracker_queue -> tracker_controler "События безопасности" "MQTT"
                    drone -> tracker_queue "Телеметрия" "MQTT"
                    drone -> tracker_queue "События безопасности" "MQTT"
                    drone -> client_mobile_app "Видео" "WebRTC"
                    drone -> client_web_app "Видео" "WebRTC"

                    bpm -> tracker_facade "Управление дроном" "REST"

                }      
            }

            # Relations with customer
            user -> client_mobile_app "Управление услугой"
            user -> client_web_app "Управление услугой"
            #child -> child_mobile_app "Предоставление данных"
        }

        user  -> guard_system "Управление услугой"
        #child -> guard_system "Предоставление геолокации"

        deploymentEnvironment "Value Stream" {
            deploymentNode "1 Partner Engagement" {         
            }
            deploymentNode "2 Product Creation" {
            }
            deploymentNode "3 Customer Engagement" {
                deploymentNode "Управление привлечением клиента" {
                    client_web_app_instance1 = containerInstance client_web_app
                }
            }
            deploymentNode "4 Product Offering" {
                deploymentNode "Управление привлечением клиента" {
                    client_mobile_app_instance  = containerInstance client_mobile_app
                    client_web_app_instance2 = containerInstance client_web_app
                    client_mobile_app_backend_instance = containerInstance client_mobile_app_backend
                    client_web_app_backend_instance = containerInstance client_web_app_backend

                }
            }
            deploymentNode "5 Product Ordering" {
                deploymentNode "Управление обеспечением безопасности" {
                    inventory_instance = containerInstance inventory
                    bpm_instance = containerInstance bpm
                    tracker_instance1 = containerInstance tracker

                }
                deploymentNode "Управление видеотрансляциями" {
                    tracker_instance2 = containerInstance tracker
                }
            }
            deploymentNode "6 Support" {
                deploymentNode "Управление оплатой" {
                    billing_instance = containerInstance billing
                }
            }

        }


    }

    views {
        properties {
            "structurizr.sort" "type"
        }
        systemContext guard_system "Context" {
            include *
            autoLayout
        }

        container guard_system "Containers" {
            include *
            autoLayout
        }

        component billing "Billing"{
            include *
            autoLayout
        }

        component inventory "Inventory"{
            include *
            autoLayout
        }

        component crm "CRM"{
            include *
            autoLayout
        }

        component tracker "Tracking"{
            include *
            autoLayout
        }

        deployment guard_system "Value Stream" {
            include *
            # animation {
            #     developerSinglePageApplicationInstance
            #     developerWebApplicationInstance developerApiApplicationInstance
            #     developerDatabaseInstance
            # }
            # autoLayout
            description "Пример потока ценности."
        }

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #08427b
            }

            element "ExternalSystem" {
                background #c0c0c0
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "WebBrowser" {
                shape WebBrowser
            }
            element "MobileApp" {
                shape MobileDevicePortrait
            }
            element "Database" {
                shape Cylinder
            }
            element "Queue" {
                shape Pipe
            }
            element "Component" {
                background #85bbf0
                color #000000
                shape Component
            }

            
        }
    }

}