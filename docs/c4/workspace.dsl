workspace "MobiSocial" "Mobilidade urbana inclusiva - SOA + Event-Driven (Spring Boot)" {

    model {
        passageiro = person "Passageiro" "Usuário comum, estudante ou paciente de UBS. Solicita, agenda e acompanha corridas." "Pessoa"
        motorista = person "Motorista Parceiro" "Cadastra veículos, aceita rotas planejadas e transporta passageiros." "Pessoa"

        gateway = softwareSystem "Gateway Externo de Pagamentos" "Processa cobranças, rateios e validação de vouchers sociais." "Externo"
        mapas = softwareSystem "API de Mapas / Geolocalização" "Fornece distância, tempo estimado e traçado de rotas urbanas." "Externo"

        mobisocial = softwareSystem "MobiSocial" "Plataforma de rotas, corridas compartilhadas e pagamentos com tarifa social." {

            frontend = container "Aplicação Front-end" "Interface para cadastro, login, solicitação de corridas e acompanhamento da viagem." "Web App (SPA)" "Frontend"

            userService = container "Serviço de Usuários" "Cadastro, login (emissão de JWT), perfis tarifários (comum, estudante, social) e regras de negócio de usuários e motoristas." "Spring Boot (REST)" "Servico"

            rideService = container "Serviço de Rotas e Corridas" "Cria rotas, agenda corridas, pareia passageiros e publica eventos. Valida o JWT recebido." "Spring Boot (REST)" "Servico"

            broker = container "Message Broker" "Filas payments.process e notifications.dispatch." "RabbitMQ (AMQP)" "Broker"

            paymentService = container "Serviço de Pagamentos" "Consome corridas agendadas, calcula rateio/tarifa social e processa a cobrança." "Spring Boot (Worker)" "Servico"

            notificationService = container "Serviço de Notificações" "Consome eventos finais e emite avisos de corrida e pagamento." "Spring Boot (Worker)" "Servico"

            db = container "Banco de Dados" "Usuários, veículos, rotas, corridas e pagamentos (schema por serviço)." "PostgreSQL" "Database"
        }

        # --- Nível 1: Contexto
        passageiro -> mobisocial "Cadastra-se, solicita e acompanha corridas" "HTTPS"
        motorista -> mobisocial "Cadastra veículos e aceita rotas" "HTTPS"
        mobisocial -> gateway "Processa cobranças e vouchers" "HTTPS"
        mobisocial -> mapas "Calcula rotas e distâncias" "HTTPS"

        # --- Nível 2: Containers
        passageiro -> frontend "Usa" "HTTPS"
        motorista -> frontend "Usa" "HTTPS"

        frontend -> userService "Cadastro e login (/api/users, /api/auth)" "HTTPS/REST (JSON)"
        frontend -> rideService "Rotas e corridas (/api/rides, /api/routes)" "HTTPS/REST (JSON)"

        userService -> db "Lê e grava usuários e perfis" "JDBC"

        rideService -> userService "Consulta perfil tarifário do passageiro" "HTTP/REST"
        rideService -> mapas "Consulta rotas e distâncias" "HTTPS"
        rideService -> db "Lê e grava rotas e corridas" "JDBC"
        rideService -> broker "Publica evento em payments.process" "AMQP"

        broker -> paymentService "Entrega payments.process" "AMQP"
        paymentService -> db "Lê e grava pagamentos" "JDBC"
        paymentService -> gateway "Cobra" "HTTPS"
        paymentService -> broker "Publica evento em notifications.dispatch" "AMQP"

        broker -> notificationService "Entrega notifications.dispatch" "AMQP"
        notificationService -> db "Registra envios" "JDBC"
    }

    views {
        systemContext mobisocial "N1-Contexto" "C4 Nível 1 - Diagrama de Contexto" {
            include *
            autolayout lr
        }

        container mobisocial "N2-Containers" "C4 Nível 2 - Diagrama de Containers" {
            include *
            autolayout lr
        }

        styles {
            element "Pessoa" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Externo" {
                background #8a8a8a
                color #ffffff
            }
            element "Frontend" {
                shape WebBrowser
                background #0277bd
                color #ffffff
            }
            element "Servico" {
                background #2e7d32
                color #ffffff
            }
            element "Broker" {
                shape Pipe
                background #e65100
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #5e35b1
                color #ffffff
            }
            relationship "Relationship" {
                routing Orthogonal
                fontSize 22
            }
        }
    }
}
