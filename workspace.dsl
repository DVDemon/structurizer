workspace {
    name "Мобильный телохранитель"
    description "демонстрационный пример для показа техник ведения проектной документацииы"
    !adrs decisions
    !docs documentation
    #!identifiers hierarchical

    model {
        !include export_tools/sparx_to_structurizr/bss_landscape.dsl
        !include export_tools/sparx_to_structurizr/ess_landscape.dsl
        !include landscape_model.dsl
        !include model.dsl  
        !include deployment_model.dsl  
    }

    views {
        properties {
            "plantuml.url" "http://localhost:8082/plantuml"
            "plantuml.format" "svg"
            "structurizr.sort" "created"
        }

        image guard_system "datamodel"{
            plantuml datamodel.puml
        }
        
        systemLandscape "SystemLandscape" {
            //include *
            include "element.tag==rel:1.1.0"
            include "element.tag==rel:2.0"
            autoLayout lr
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
            autoLayout tb
            animation {
                bpm
                tracker
                billing_queue
                billing_controller
                billing_database  
                payment_system
                billing_facade
            }
        }

        component inventory "Inventory"{
            include *
            autoLayout lr
        }

        component crm "CRM"{
            include *
            autoLayout
        }

        component tracker "Tracking"{
            include *
            autoLayout
        }

        deployment guard_system "Production" "vs"{
            include *
            description "Типовое размещение оборудования"
            exclude ext_rel_1 ext_rel_2 bpm_rel_1 bpm_rel_2 

            #autoLayout
        }

        dynamic guard_system "UC01" {
            autoLayout lr
            description "Тестовый сценарий"

            user -> client_mobile_app "1. Клиент открывает мобильное приложение"
            client_mobile_app -> authorization_password "2. Мобильное приложение запрашивает данные для аутентификации клиента (login/password) и проверяет их через WebSSO"
            user -> client_mobile_app "3. Клиент выбирает раздел Заказ дрона"
            client_mobile_app -> client_mobile_app_backend "4. Мобильное приложение запрашивает backend для поиска дрона"
            client_mobile_app_backend -> bpm "5. Backend мобильного приложения запускает на BPM сценарий поиска дрона"
            bpm -> crm "6. BPM получает в CRM данные по клиенту и его детям"
            bpm -> crm "7. BPM получает информацию о маршруте ребенка"
            bpm -> mlc "8. BPM получает информацию о текущем положении ребенка из MLC"
            bpm -> billing  "9. BPM получает данные по достаточности баланса у клиента"
            bpm -> inventory "10. BPM получает данные в inventory о свободных дронах"
            bpm -> tracker "11. BPM передает команду на дрона о начале трэкинга" 
            
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