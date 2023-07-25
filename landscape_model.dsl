properties {
            structurizr.groupSeparator "/"
        }

group "BSS Landscape" {
    payment_system = softwareSystem "Внешняя платежная система" {
        description "Система регистрации платежей по банковским картам, QR кодам и через SPB"
        tags "ExternalSystem"
    } 
}

group "Infrastructure platforms" {
    security = softwareSystem "ЧОП" {
        description "Внешнее партнерское охранное агенство"
        tags "ExternalSystem" 
    }
    firewall = softwareSystem "FireWall" {
        description "Программный межсетевой экран"
        tags "ExternalSystem"
    }

    group "IDP" {
        sso = softwareSystem "Single Sign On" {
            description "Аутентификация и авторизация пользователей"

            authorization_password = container "Авторизация по логину и паролю"
            authorization_mobile_id = container "Авторизация Mobile ID"
            authorization_one_time = container "Авторизация по разовому паролю"
        } 
    }
}

group "OSS Landscape" {
    drone = softwareSystem "Дрон"{
        description "Аэромобильная платформа для наблюдения за пользователями" 
        tags "ExternalSystem"
    }

    mlc = softwareSystem "MLC"{
        description "Mobile Location Centre"
        tags "Externalsystem"
    }
}
