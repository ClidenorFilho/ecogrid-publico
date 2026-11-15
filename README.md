# EcoGrid Público: Smart Grid para Escolas e UBS

Monitoramento Inteligente de Consumo, Otimização de Cargas em Prédios Públicos e Proteção de Insumos Críticos de Saúde documentado com C4 Model (Structurizr).

## 1. Definição do Produto e Escopo

### 1.1. Visão Geral do Produto
O **EcoGrid Público** é uma plataforma de gerenciamento inteligente de energia (*Smart Grid*) voltada para infraestruturas públicas municipais e estaduais, com foco direto em **Escolas Públicas** e **Unidades Básicas de Saúde (UBS)**. O sistema combina coleta de telemetria em tempo real via sensores IoT, detecção automatizada de anomalias de consumo e acionamento remoto de relés inteligentes para otimização energética e proteção de equipamentos vitais.

#### Problemas Reais Solucionados (Impacto Social)
* **Combate ao Desperdício em Escolas Públicas:** Salas de aula, laboratórios de informática e setores administrativos frequentemente permanecem com aparelhos de ar-condicionado e iluminação ligados fora do horário letivo ou em períodos de ociosidade. O sistema mitiga esse gasto desnecessário, evitando a drenagem de recursos públicos que podem ser reinvestidos em merenda, material didático e infraestrutura pedagógica.
* **Proteção de Câmaras de Vacinas e Insumos em UBS:** Unidades Básicas de Saúde sofrem com quedas de fase, sobrecargas na rede elétrica local e falhas em compressores de refrigeração. O monitoramento contínuo previne que interrupções não detectadas nos circuitos de câmaras frias inutilizem lotes inteiros de vacinas, insulinas e medicamentos termolábeis, protegendo a comunidade atendida.
* **Desligamento Inteligente de Cargas (*Load Shedding* Prioritário):** Quando uma sobrecarga é detectada em uma UBS ou escola, a plataforma classifica os circuitos por criticidade social. Em uma UBS, o EcoGrid desliga automaticamente circuitos secundários (como climatização da recepção e iluminação externa) para estabilizar a tensão e preservar 100% da alimentação elétrica das câmaras de vacinas e salas de emergência.

### 1.2. Catálogo de Atores e Sistemas Externos
Abaixo estão definidos os atores e os sistemas/dispositivos externos que interagem diretamente com o **EcoGrid Público**, servindo de base para o **Diagrama de Contexto (C4 Nível 1)**:

#### Atores (*Persons*)
| Ator                                          | Perfil / Papel                                                             | Principais Interações com o Sistema                                                                                                  |
|:----------------------------------------------|:---------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|
| **Gestor da Unidade Pública**                 | Diretor Escolar ou Coordenador de UBS.                                     | Acompanha dashboards de consumo em tempo real, define janelas de funcionamento dos setores e consulta relatórios de economia gerada. |
| **Equipe de Manutenção / Engenharia Clínica** | Técnicos responsáveis pela infraestrutura elétrica e equipamentos médicos. | Recebe alertas urgentes de anomalias elétricas, sobrecargas críticas ou risco térmico em equipamentos de refrigeração médica.        |

#### Sistemas e Dispositivos Externos (*External Systems & Hardware*)
| Sistema / Dispositivo                                               | Tipo                                          | Principais Interações com o Sistema                                                                                                                                          |
|:--------------------------------------------------------------------|:----------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Medidores Inteligentes e Sensores IoT (*Smart Meters*)**          | Hardware / Dispositivo IoT                    | Instalados nos quadros de distribuição (QGBT) das escolas e UBS, enviam leituras contínuas de potência (kW), consumo (kWh), tensão, corrente e temperatura de câmaras frias. |
| **Atuadores de Quadro Elétrico (*Smart Relays* / Disjuntores IoT)** | Hardware / Atuador IoT                        | Recebem comandos do EcoGrid Público para cortar ou religar circuitos não essenciais remotamente.                                                                             |
| **Serviço Externo de Mensageria de Alerta**                         | Sistema Externo (E-mail / SMS / Telegram API) | Realiza a entrega imediata de notificações críticas aos responsáveis técnicos.                                                                                               |

### 1.3. Funcionalidades Documentadas (Requisitos Funcionais)

| Requisito | Funcionalidade | Descrição |
|:----------|:---------------|:----------|
| **RF01** | **Coletar telemetria dos medidores e sensores IoT** | Receber leituras periódicas de potência (kW), consumo (kWh), tensão, corrente e temperatura das câmaras de vacinas, identificando a unidade, o circuito e o instante da medição. |
| **RF02** | **Cadastrar e classificar unidades e circuitos** | Manter as escolas e UBS monitoradas e classificar cada circuito por criticidade — **Vital**, **Essencial** ou **Secundário/Ocioso** — para orientar as decisões de proteção e corte de carga. |
| **RF03** | **Detectar anomalias e situações de risco** | Analisar as leituras recebidas, comparar os valores com os limites configurados e identificar sobrecargas, quedas de fase, consumo fora do horário e risco térmico em equipamentos de refrigeração. |
| **RF04** | **Otimizar cargas e emitir alertas** | Ao detectar uma situação crítica, publicar o comando de *load shedding* para desligar circuitos não prioritários e enviar alertas à equipe de manutenção, preservando a alimentação dos circuitos vitais. |
| **RF05** | **Disponibilizar acompanhamento e relatórios** | Permitir ao gestor acompanhar o consumo e o estado dos circuitos, consultar ocorrências e visualizar a economia gerada pelas ações de otimização. |

### 1.4. Resumo do Fluxo Principal

1. Os medidores inteligentes e sensores IoT instalados na escola ou UBS coletam uma nova leitura e a publicam via AMQP.
2. O Serviço Core consome a mensagem, valida a unidade e o circuito e registra a telemetria para manter o histórico de acompanhamento.
3. O caso de uso de processamento compara os valores com os limites configurados e classifica a ocorrência como normal, anômala ou crítica.
4. Em uma situação crítica, o motor aplica a política de prioridade: mantém os circuitos **Vitais** e **Essenciais** e seleciona circuitos **Secundários/Ociosos** para o corte de carga.
5. O sistema publica o comando de otimização para os relés inteligentes e o alerta para a equipe responsável.
6. Os atuadores executam o desligamento remoto dos circuitos selecionados, enquanto o serviço de notificações comunica a ocorrência aos responsáveis.
7. Após a estabilização, o gestor acompanha o estado atualizado, a ocorrência e a economia gerada no dashboard ou nos relatórios.

## 2. Estilos Arquiteturais Selecionados

Para atender aos requisitos do **Tema 14 (Sistema de Gerenciamento de Energia / Smart Grid)** com baixo acoplamento, tolerância a picos de leitura e isolamento das regras críticas de negócio, o projeto combina dois estilos arquiteturais complementares:

### 2.1. Arquitetura Baseada em Eventos (Event-Driven Architecture — Estilo Macro)
* **Aplicação no Sistema:** Toda a ingestão de leituras dos medidores inteligentes (Smart Meters) instalados nas escolas e UBS ocorre de forma assíncrona por meio de um Message Broker (**RabbitMQ** via protocolo `AMQP`).
* **Justificativa Arquitetural:** Dispositivos IoT geram fluxos contínuos de telemetria na fila `telemetry.readings`. O modelo orientado a eventos garante **desacoplamento temporal e espacial** entre os sensores de borda e o processamento central. Quando o motor de análise detecta uma sobrecarga elétrica ou risco térmico na linha de uma câmara de vacinas, ele publica eventos de domínio (`optimization.commands` e `alerts.critical`) que são consumidos de forma independente pelo controlador de atuadores (para *Load Shedding* automático de circuitos secundários) e pelo serviço de notificações.

### 2.2. Clean Architecture (Estilo Interno do Serviço Central)
* **Aplicação no Sistema:** O microsserviço principal (**Serviço Core de Monitoramento e Otimização**, em Java com Spring Boot) é estruturado internamente em camadas concêntricas:
  * **Entities:** Regras de negócio puras e modelos de domínio (`CircuitEntity`, classificação de criticidade em *Vital*, *Essencial* e *Secundário/Ocioso*).
  * **Use Cases:** Orquestração dos fluxos da aplicação (`ProcessTelemetryReadingUseCase`, políticas de corte de carga em `LoadSheddingPolicyService`).
  * **Interface Adapters:** Adaptadores de entrada e saída (`TelemetryConsumerController`, `UnitRepositoryPort`, `EventPublisherAdapter`).
  * **Frameworks & Drivers:** Integrações externas com Spring Boot, **PostgreSQL** (`JDBC`/JPA) e **RabbitMQ** (`AMQP`).
* **Justificativa Arquitetural:** Garante que as regras críticas de negócio — como a matriz de prioridade elétrica das UBS, os limiares de sobrecarga e o cálculo de desperdício em salas de aula ociosas — fiquem **100% isoladas** do banco de dados e da tecnologia de mensageria utilizada, facilitando a testabilidade e a evolução da infraestrutura.

## 3. Documentação Arquitetural (Modelo C4 - Structurizr)

O código-fonte da modelagem arquitetural encontra-se em [`/docs/c4/workspace.dsl`](./docs/c4/). As Decisões Arquiteturais (ADRs) estão documentadas em [`/docs/adr/`](./docs/adr/).

### 3.1. C4 Nível 1: Diagrama de Contexto
<!-- [ESPAÇO RESERVADO - DUPLA C]
Inserir imagem exportada de /docs/c4 e parágrafo explicativo dos fluxos e protocolos.
-->

### 3.2. C4 Nível 2: Diagrama de Container
<!-- [ESPAÇO RESERVADO - DUPLA C]
Inserir imagem exportada de /docs/c4 e parágrafo explicativo detalhando os containers e os protocolos (AMQP, JDBC e HTTPS).
-->

## 4. Guia Passo a Passo de Execução do Projeto

> *Nota: Os comandos abaixo descrevem o procedimento completo de execução da implementação parcial do fluxo principal (prevista para a Entrega da Etapa 3 em 01/12).*

### Pré-requisitos
* **Docker** e **Docker Compose**
* **Java JDK 17+** e **Maven**
* **Python 3.10+** (para execução do Simulador IoT)

### 4.1. Subir a Infraestrutura (RabbitMQ e PostgreSQL)
Na raiz do repositório, inicie os containers do Message Broker e do Banco de Dados via Docker Compose:
```bash
docker compose up -d

````

- **RabbitMQ (AMQP):** `localhost:5672` | **Painel Web:** `http://localhost:15672`
- **PostgreSQL:** `localhost:5432`

### 4.2. Executar o Serviço Core (Spring Boot)

Acesse o diretório do serviço principal em `/src` e inicie a aplicação:

Bash
```
cd src
./mvnw spring-boot:run

```

### 4.3. Executar o Simulador IoT (Python)

Em outro terminal, instale a biblioteca de conexão AMQP e execute o script simulador para publicar payloads JSON de sobrecarga elétrica na fila `telemetry.readings` do RabbitMQ:

Bash
```
cd src/simulator
pip install pika
python simulator.py

```

## 5. Cronograma e Divisão de Atividades da Equipe

**Integrantes (Equipe 10):** Felipe Maia, João Vitor, Maria José, Cauan, Clidenor e Pablo.

| **Etapa**   | **Prazo Oficial** | **Dupla Responsável**               | **Entregável Principal**        | **Foco Técnico da Frente**                                                                                                                                                                       |
| ----------- | ----------------- | ----------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Etapa 1** | 16/11             | **Dupla A:** Felipe Maia e Clidenor | Repositório GitHub e Estilos    | Criar repo, adicionar equipe, estruturar pastas (`/docs/c4`, `/docs/adr`, `/src`), justificar Event-Driven + Clean Arch no `README.md`, guia de execução e importar dependências do Spring Boot. |
| **Etapa 1** | 16/11             | **Dupla B:** *Pablo e Maria*          | Escopo EcoGrid e Requisitos     | Documentar o problema em Escolas/UBS, atores, funcionalidades (RF01-RF05) e fluxo principal no `README.md`.                                                                                      |
| **Etapa 1** | 16/11             | **Dupla C:** *Cauan Ricardo e João Vitor*          | Diagramas C4 Níveis 1 e 2       | Configurar Structurizr DSL (`workspace.dsl`) e gerar os diagramas de Contexto e Container alinhados ao `README.md`.                                                                              |
| **Etapa 2** | 23/11             | **Dupla A:** *Felipe Maia e Clidenor*          | C4 Nível 3 (Ingestão/Eventos)   | Modelar os componentes internos do Container de Ingestão IoT, filas do Broker e Notificações.                                                                                                    |
| **Etapa 2** | 23/11             | **Dupla B:** *Pablo e Maria*          | C4 Nível 3 (Core Clean Arch)    | Modelar os componentes internos do Serviço Core (Controllers, Use Cases, Entities, Gateways).                                                                                                    |
| **Etapa 2** | 23/11             | **Dupla C:** *Cauan Ricardo e João Vitor*          | C4 Nível 4 (Código) e ADRs      | Modelar o diagrama de classes do fluxo de sobrecarga e redigir as Decisões Arquiteturais (ADRs 01, 02 e 03) em `/docs/adr`.                                                                      |
| **Etapa 3** | 01/12             | **Dupla A:** *Felipe Maia e Clidenor*          | Infra Docker e Simulador IoT    | Subir Docker Compose (RabbitMQ + PostgreSQL) e criar script Python simulador enviando leituras de Escola e UBS.                                                                                  |
| **Etapa 3** | 01/12             | **Dupla B:** *Pablo e Maria*          | Serviço Core (Clean Arch)       | Implementar o fluxo principal (detecção de anomalia + disparo de evento de corte de carga) em conformidade com os níveis 3 e 4.                                                                  |
| **Etapa 3** | 01/12             | **Dupla C:** *Cauan Ricardo e João Vitor*          | Receptor, Conformidade e Slides | Implementar consumidor de alertas/atuador, auditar conformidade código x Structurizr e preparar apresentação.                                                                                    |