        deploymentEnvironment "ProductionDeployment" {
            deploymentNode "Client Device 1" {
                    description "Мобильные телефоны и планшеты клиентов во внешней сети"
                    tags "Android" "iOS"
                    client_mobile_app_instance  = containerInstance client_mobile_app
            }

            deploymentNode "Client Device 2" {
                    description "Стационарные компьютеры пользователей во внешней сети или мобильные устройства с установленным браузером"
                    tags "Windows" "MacOS" "Linux Ubuntu"
                    client_web_app_instance = containerInstance client_web_app
            }
            
            group "Backend Cluster" {
                deploymentNode "BFF Server Mobile 1" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance1 = containerInstance client_mobile_app_backend
                }
                deploymentNode "BFF Server Mobile 2" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance2 = containerInstance client_mobile_app_backend
                }

                deploymentNode "BFF Server Mobile 3" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance3 = containerInstance client_mobile_app_backend
                }   

                deploymentNode "BFF Server Web 1" {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance1 = containerInstance client_web_app_backend
                }
                deploymentNode "BFF Server Web 2"  {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance2 = containerInstance client_web_app_backend
                }
                deploymentNode "BFF Server Web 3" {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance3 = containerInstance client_web_app_backend
                }
            }

            deploymentNode "BPM First" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='BPM'}.description
                }
                tags "Oracle Enteprise Linux" "Camunda 7"
                bpm_instance1 = containerInstance bpm
            }
            deploymentNode "BPM Second" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='BPM'}.description
                }
                tags "Oracle Enteprise Linux" "Camunda 7"
                bpm_instance2 = containerInstance bpm
            }

            deploymentNode "Inventory server" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Inventory'}.description
                }
                tags "Oracle Enteprise Linux"
                inventory_instance = containerInstance inventory          
            }

            deploymentNode "Tracker First" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Tracker'}.description
                }
                tags "Oracle Enteprise Linux"
                tracker_instance1 = containerInstance tracker
            }

            deploymentNode "Tracker Second" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Tracker'}.description
                }
                tags "Oracle Enteprise Linux"
                tracker_instance2 = containerInstance tracker
            }

            deploymentNode "Billing" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Billing'}.description
                }
                tags "Oracle Enteprise Linux"
                billing_instance = containerInstance billing
            }

        }

