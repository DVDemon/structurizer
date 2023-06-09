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
}

group "OSS Landscape" {
    drone = softwareSystem "Дрон"{
        description "Аэромобильная платформа для наблюдения за пользователями" 
        tags "ExternalSystem"
    }
}
