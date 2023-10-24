        deploymentEnvironment "ProductionDeployment" {
            deploymentNode "iOS Device" {
                    description "Мобильные телефоны и планшеты клиентов во внешней сети"
                    properties {
                        "os" "iOS"
                        "ram" "8"
                    }

                    client_mobile_app_instance1  = containerInstance client_mobile_app
            }

            deploymentNode "Android Device" {
                    description "Мобильные телефоны и планшеты клиентов во внешней сети"
                    client_mobile_app_instance2  = containerInstance client_mobile_app
                    properties {
                        "os" "Android"
                        "cpu" "2"
                        "ram" "8"
                    }
            }

            deploymentNode "Client Device 2" {
                    description "Стационарные компьютеры пользователей во внешней сети или мобильные устройства с установленным браузером"
                    properties {
                        "os" "Windows/MacOS/Linux Ubuntu"
                        "cpu" "4"
                        "ram" "8"
                    }
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

                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_mobile_app_backend_instance1 = containerInstance client_mobile_app_backend
                }
                bffm2 = deploymentNode "BFF Server Mobile 2" {
                        description "Backend для мобильного приложения"
                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_mobile_app_backend_instance2 = containerInstance client_mobile_app_backend
                }

                bffm3 = deploymentNode "BFF Server Mobile 3" {
                        description "Backend для мобильного приложения"
                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_mobile_app_backend_instance3 = containerInstance client_mobile_app_backend
                }   

                bffw1 = deploymentNode "BFF Server Web 1" {
                        description "Backend для веба"
                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_web_app_backend_instance1 = containerInstance client_web_app_backend
                }
                bffw2 = deploymentNode "BFF Server Web 2"  {
                        description "Backend для веба"
                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_web_app_backend_instance2 = containerInstance client_web_app_backend
                }
                bffw3 = deploymentNode "BFF Server Web 3" {
                        description "Backend для веба"
                         properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "16"
                        }
                        client_web_app_backend_instance3 = containerInstance client_web_app_backend
                }

                client_mobile_app_instance1 -> fw1
                client_mobile_app_instance2 -> fw1
                client_web_app_instance -> fw1
                fw1 -> lb1 "HTTP :80,443"
                fw1 -> lb2 "HTTP :80,443"
                lb1 -> bffm1 "HTTP :80,443"
                lb1 -> bffm2 "HTTP :80,443"
                lb1 -> bffm3 "HTTP :80,443"
                lb2 -> bffw1 "HTTP :80,443"
                lb2 -> bffw2 "HTTP :80,443"
                lb2 -> bffw3 "HTTP :80,443"
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
                        properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "8"
                        }
                        bpm_instance1 = containerInstance bpm
                }

                bpm2 = deploymentNode "BPM Second" {
                        !script groovy {             
                                element.description = workspace.model.softwareSystems.find{
                                        element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                                element -> element.name=='BPM'}.description
                        }
                        properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "8"
                        }
                        bpm_instance2 = containerInstance bpm
                }

                bffm1 -> fw2 "HTTP :80,443"
                bffm2 -> fw2 "HTTP :80,443"
                bffm3 -> fw2 "HTTP :80,443"
                bffw1 -> fw2 "HTTP :80,443"
                bffw2 -> fw2 "HTTP :80,443"
                bffw3 -> fw2 "HTTP :80,443"

                fw2 -> bpm1 "HTTP :80,443"
                fw2 -> bpm2 "HTTP :80,443"
            }

            

            deploymentNode "Inventory server" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Inventory'}.description
                }
                properties {
                        "os" "Oracle Enteprise Linux"
                        "cpu" "4"
                        "ram" "8"
                }
                inventory_instance = containerInstance inventory          
            }


            deploymentNode "Tracker First" {
                        !script groovy {             
                                element.description = workspace.model.softwareSystems.find{
                                        element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                                element -> element.name=='Tracker'}.description
                        }
                        properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "8"
                        }
                        tracker_instance = containerInstance tracker
            }



            deploymentNode "Billing" {
                !script groovy {             
                        element.description = workspace.model.softwareSystems.find{
                                 element -> element.name=='Мобильный телохранитель'}.containers.find { 
                                        element -> element.name=='Billing'}.description
                }
                
                properties {
                                "os" "Oracle Enteprise Linux"
                                "cpu" "4"
                                "ram" "32"
                        }
                billing_instance = containerInstance billing
            }

        }

