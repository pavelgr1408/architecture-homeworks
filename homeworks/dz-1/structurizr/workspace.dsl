workspace "Order Training System" "Учебная архитектура сервиса заказов" {
    model {
        customer = person "Customer" "Создаёт и просматривает заказы."

        paymentSystem = softwareSystem "Payment System" "Внешняя платёжная система." {
            tags "External System"
        }

        orderPlatform = softwareSystem "Order Platform" "Учебная система оформления заказов." {
            webApp = container "Web Application" "Пользовательский интерфейс." "TypeScript / React"
            apiGateway = container "API Gateway" "Единая точка входа." "Nginx"
            orderService = container "Order Service" "Управляет жизненным циклом заказа." "Java / Spring Boot"
            orderDatabase = container "Order Database" "Хранит заказы." "PostgreSQL" {
                tags "Database"
            }
            eventBroker = container "Event Broker" "Передаёт доменные события." "Apache Kafka" {
                tags "Queue"
            }
        }

        customer -> webApp "Создаёт заказ"
        webApp -> apiGateway "Вызывает API" "HTTPS / JSON"
        apiGateway -> orderService "Передаёт команды" "HTTP / JSON"
        orderService -> orderDatabase "Читает и записывает заказы" "JDBC"
        orderService -> eventBroker "Публикует OrderCreated" "Kafka"
        orderService -> paymentSystem "Запрашивает оплату" "HTTPS / JSON"
    }

    views {
        systemContext orderPlatform "SystemContext" {
            include *
            autoLayout lr
        }

        container orderPlatform "Containers" {
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "Queue" {
                shape pipe
            }
        }
    }
}
