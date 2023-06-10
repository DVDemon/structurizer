workspace {
    name "Мобильный телохранитель"
    description "демонстрационный пример для показа техник ведения проектной документацииы"
    !adrs decisions
    !docs documentation
    #!identifiers hierarchical
    
    
    model {
        !include landscape_model.dsl
        !include model.dsl  
        !include deployment_model.dsl  
        

    }

    #!plugin FindRelationshipsPlugin

    views {
        properties {
            "structurizr.sort" "type"
        }

        # systemLandscape "SystemLandscape" {
        #     include *
        #     autoLayout lr
        # }
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

        deployment guard_system "ProductionDeployment" "vs"{
            include *
            description "Типовое размещение оборудования"
            autoLayout
        }

        dynamic guard_system "UC01" {
            autoLayout lr
            description "Поиск и аренда дрона"
            properties {
                plantuml.sequenceDiagram true
            }

            client_mobile_app -> sso "Запрос токена для аутентификации"
            client_mobile_app -> client_mobile_app_backend "Запрос на поиск дрона в окресностях геолокации"        
            client_mobile_app_backend -> bpm "Запрос на поиск дрона"
            bpm -> crm "Запрос данных по клиенту"
            bpm -> crm "Запрос данных по ребенку"
            bpm -> mlc "Запрос данных о геопозициях ребенка"
            bpm -> billing "Запрос достаточности баланса"
            bpm -> inventory "Поиск свободных дронов"
            bpm -> tracker "Передача данных ребенка на дрон"
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