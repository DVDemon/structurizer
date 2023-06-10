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
                        tags "Oracle Enteprise Linux" "ip 10.1.12.34"
                        client_mobile_app_backend_instance1 = containerInstance client_mobile_app_backend
                }
                deploymentNode "BFF Server Mobile 2" {
                        tags "Oracle Enteprise Linux" "ip 10.1.12.35"
                        client_mobile_app_backend_instance2 = containerInstance client_mobile_app_backend
                }

                deploymentNode "BFF Server Mobile 3" {
                        tags "Oracle Enteprise Linux" "ip 10.1.12.36"
                        client_mobile_app_backend_instance3 = containerInstance client_mobile_app_backend
                }   

                deploymentNode "BFF Server Web 1" {
                        tags "Oracle Enteprise Linux" "ip 10.1.12.37"
                        client_web_app_backend_instance1 = containerInstance client_web_app_backend
                }
                deploymentNode "BFF Server Web 2"  {
                        tags "Oracle Enteprise Linux" "ip 10.1.12.38"
                        client_web_app_backend_instance2 = containerInstance client_web_app_backend
                }
                deploymentNode "BFF Server Web 3" {
                        tags "Oracle Enteprise Linux" "ip 10.1.12.39"
                        client_web_app_backend_instance3 = containerInstance client_web_app_backend
                }
            }

            deploymentNode "BPM First" {
                bpm_instance1 = containerInstance bpm
            }
            deploymentNode "BPM Second" {
                bpm_instance2 = containerInstance bpm
            }

            deploymentNode "Inventory server" {
                    inventory_instance = containerInstance inventory          
            }

            deploymentNode "Tracker First" {
                tracker_instance1 = containerInstance tracker
            }

            deploymentNode "Tracker Second" {
                tracker_instance2 = containerInstance tracker
            }

            deploymentNode "Billing" {
                billing_instance = containerInstance billing
            }

        }

