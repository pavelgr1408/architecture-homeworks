workspace {

    model {

        client = person "Пользователь" "Клиент мобильного и web приложения" "Person: Client"

        orderSystem = softwareSystem "Система управления заказами" "Платформа управления заказами" "Context: Product" {

            mobileApp = container "Mobile приложение" "Мобильное приложение клиента" "Mobile Application" "Container: Mobile GUI"
            webApp = container "Web приложение" "Web интерфейс клиента" "Web Application" "Container: Web GUI"

            apiGateway = container "API Gateway" "Единая точка входа REST API" "Backend Service" "Container: Backend Service"

            restaurantApi = container "Restaurant API" "Сервис ресторанов" "Backend Service" "Container: Backend Service"
            restaurantDb = container "Restaurant PostgreSQL" "Данные ресторанов" "PostgreSQL" "Container: Database"

            menuApi = container "Menu API" "Сервис меню" "Backend Service" "Container: Backend Service"
            menuDb = container "Menu PostgreSQL" "Данные меню" "PostgreSQL" "Container: Database"

            loyaltyApi = container "Loyalty API" "Акции, промокоды, скидки" "Backend Service" "Container: Backend Service"
            loyaltyDb = container "Loyalty PostgreSQL" "Данные лояльности" "PostgreSQL" "Container: Database"
            loyaltyBroker = container "Kafka" "События лояльности" "Message Broker" "Container: Message Broker"

            ordersApi = container "Orders API" "Корзина и оформление заказа" "Backend Service" "Container: Backend Service"
            ordersDb = container "Orders PostgreSQL" "Данные заказов" "PostgreSQL" "Container: Database"

            paymentsApi = container "Payment API" "Обработка платежей" "Backend Service" "Container: Backend Service"
            paymentsDb = container "Payment PostgreSQL" "Данные платежей" "PostgreSQL" "Container: Database"

            deliveryApi = container "Delivery API" "Интеграция доставки" "Backend Service" "Container: Backend Service"
            deliveryDb = container "Delivery PostgreSQL" "Данные доставки" "PostgreSQL" "Container: Database"

            authApi = container "Auth API" "Авторизация пользователей" "Backend Service" "Container: Backend Service"
            authDb = container "Auth PostgreSQL" "Пользователи" "PostgreSQL" "Container: Database"

            restaurantApi -> restaurantDb "Читает и записывает данные"
            menuApi -> menuDb "Читает и записывает данные"
            loyaltyApi -> loyaltyDb "Читает и записывает данные"
            ordersApi -> ordersDb "Читает и записывает данные"
            paymentsApi -> paymentsDb "Читает и записывает данные"
            deliveryApi -> deliveryDb "Читает и записывает данные"
            authApi -> authDb "Читает и записывает данные"

            apiGateway -> restaurantApi "Получить рестораны REST"
            apiGateway -> menuApi "Получить меню REST"
            apiGateway -> loyaltyApi "Получить акции REST"
            apiGateway -> ordersApi "Создать заказ REST"
            apiGateway -> paymentsApi "Оплата REST"
            apiGateway -> deliveryApi "Статус доставки REST"
            apiGateway -> authApi "Авторизация REST"

            loyaltyApi -> ordersApi "Промокоды и скидки"
            ordersApi -> paymentsApi "Передать заказ на оплату"
            ordersApi -> deliveryApi "Передать заказ на доставку"
        }

        paymentGateway = softwareSystem "Платежный шлюз" "Внешняя платежная система" "Context: External"
        deliverySystem = softwareSystem "Система доставки" "Внешняя система доставки" "Context: External"

        client -> mobileApp "Использует"
        client -> webApp "Использует"

        paymentsApi -> paymentGateway "Инициализация оплаты REST"
        paymentGateway -> paymentsApi "Статус оплаты webhook"

        deliveryApi -> deliverySystem "Поиск курьера"
        deliverySystem -> deliveryApi "Статус доставки webhook"
    }

    views {
        systemLandscape {
            include *
            autoLayout lr
        }
        container orderSystem {
            include *
            autoLayout lr
        }
        styles {

            element "Person: Client" {
                background #8fbc8f
                color #000000
                shape Person
                description true
            }

            element "Person: Employee" {
                background #87cefa
                color #000000
                shape Person
                description true
            }

            element "Person: Partner" {
                background #d3d3d3
                color #000000
                shape Person
                description true
            }

            element "Context: Product" {
                background #87cefa
                color #000000
                shape Box
                description true
            }

            element "Context: External" {
                background #c0c0c0
                color #000000
                shape Box
                description true
            }

            element "Context: Common" {
                background #b0c4de
                color #000000
                shape Box
                description true
            }

            element "Container: Backend Service" {
                background #87cefa
                color #000000
                shape Hexagon
                description true
            }

            element "Container: Database" {
                background #87cefa
                color #000000
                shape Cylinder
                description true
            }

            element "Container: Message Broker" {
                background #87cefa
                color #000000
                shape Pipe
                description true
            }

            element "Container: Web GUI" {
                background #87cefa
                color #000000
                shape WebBrowser
                description true
            }

            element "Container: Mobile GUI" {
                background #87cefa
                color #000000
                shape MobileDevicePortrait
                description true
            }

            element "Container: Target" {
                background #008080
                color #ffffff
            }

            element "Container: Deprecated" {
                background #666633
                color #c0c0c0
            }

            element "Container: Abstract" {
                background #c0c0c0
                color #000000
                shape Folder
                opacity 50
            }

            relationship "Relation: Based On" {
                color #a9a9a9
                style Solid
                routing Direct
                opacity 50
            }

            relationship "Relation: Deleted" {
                color #ff0000
            }

            relationship "Relation: Added" {
                color #008000
            }

            relationship "Relation: Deprecated" {
                color #666633
            }

            relationship "Relation: Target" {
                color #008080
            }

            relationship "Relation: Uses" {
                color #008000
                style Dashed
                routing Direct
            }

            relationship "Relation: Synchronous" {
                color #000000
                style Solid
                routing Direct
            }

            relationship "Relation: Asynchronous" {
                color #000000
                style Dashed
                routing Direct
            }

            relationship "Relation: Interacts" {
                color #808080
                style Dashed
                routing Direct
            }
        }
    }
}
