        deploymentEnvironment "ProductionDeployment" {
            deploymentNode "iOS Device" {
                    description "Мобильные телефоны и планшеты клиентов во внешней сети"
                    tags "Android" 
                    client_mobile_app_instance1  = containerInstance client_mobile_app
            }

            deploymentNode "Android Device" {
                    description "Мобильные телефоны и планшеты клиентов во внешней сети"
                    tags "iOS"
                    client_mobile_app_instance2  = containerInstance client_mobile_app
            }

            deploymentNode "Client Device 2" {
                    description "Стационарные компьютеры пользователей во внешней сети или мобильные устройства с установленным браузером"
                    tags "Windows" "MacOS" "Linux Ubuntu"
                    client_web_app_instance = containerInstance client_web_app
            }

            
            deploymentNode "DMZ" {
                fw1 = infrastructureNode "Firewall"  {
                        description "Аппаратный межсетевой экран"
                        technology "Дионис"
                }

                lb1 = infrastructureNode "LoadBalancer Mobile"{
                        description "Балансировщик запросов к мобильным backend"
                        technology "nginx"
                }

                lb2 = infrastructureNode "LoadBalancer Web"{
                        description "Балансировщик запросов к web backend"
                        technology "nginx"
                }
            
                bffm1 = deploymentNode "BFF Server Mobile 1" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance1 = containerInstance client_mobile_app_backend
                }
                bffm2 = deploymentNode "BFF Server Mobile 2" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance2 = containerInstance client_mobile_app_backend
                }

                bffm3 = deploymentNode "BFF Server Mobile 3" {
                        description "Backend для мобильного приложения"
                        tags "Oracle Enteprise Linux"
                        client_mobile_app_backend_instance3 = containerInstance client_mobile_app_backend
                }   

                bffw1 = deploymentNode "BFF Server Web 1" {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance1 = containerInstance client_web_app_backend
                }
                bffw2 = deploymentNode "BFF Server Web 2"  {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance2 = containerInstance client_web_app_backend
                }
                bffw3 = deploymentNode "BFF Server Web 3" {
                        description "Backend для веба"
                        tags "Oracle Enteprise Linux"
                        client_web_app_backend_instance3 = containerInstance client_web_app_backend
                }

                client_mobile_app_instance1 -> fw1
                client_mobile_app_instance2 -> fw1
                client_web_app_instance -> fw1
                fw1 -> lb1 "Запросы от мобильного клиента"
                fw1 -> lb2 "Запросы от веб клиента"
                lb1 -> bffm1 "Перенаправление запросов"
                lb1 -> bffm2 "Перенаправление запросов"
                lb1 -> bffm3 "Перенаправление запросов"
                lb2 -> bffw1 "Перенаправление запросов"
                lb2 -> bffw2 "Перенаправление запросов"
                lb2 -> bffw3 "Перенаправление запросов"
            }

            deploymentNode "BPM Cluster" {
                fw2 = infrastructureNode "Loadbalancer"  {
                        description "Аппаратный межсетевой экран"
                        technology "nginx"
                }

                bpm1 = deploymentNode "BPM First" {
                        !script groovy {             
                                element.description = workspace.model.softwareSystems.find{
                                        element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                                element -> element.name=='BPM'}.description
                        }
                        tags "Oracle Enteprise Linux"
                        bpm_instance1 = containerInstance bpm
                }

                bpm2 = deploymentNode "BPM Second" {
                        !script groovy {             
                                element.description = workspace.model.softwareSystems.find{
                                        element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                                element -> element.name=='BPM'}.description
                        }
                        tags "Oracle Enteprise Linux"
                        bpm_instance2 = containerInstance bpm
                }

                bffm1 -> fw2 "Перенаправление запросов"
                bffm2 -> fw2 "Перенаправление запросов"
                bffm3 -> fw2 "Перенаправление запросов"
                bffw1 -> fw2 "Перенаправление запросов"
                bffw2 -> fw2 "Перенаправление запросов"
                bffw3 -> fw2 "Перенаправление запросов"

                fw2 -> bpm1 "Перенаправление запросов"
                fw2 -> bpm2 "Перенаправление запросов"
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
                        tracker_instance = containerInstance tracker
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

