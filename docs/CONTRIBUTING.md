# Contribuindo com o EcoGrid Público

Este documento define o fluxo de trabalho da equipe no repositório do **EcoGrid Público (Smart Grid para Escolas Públicas e UBS)**: estratégia de branches, padrão de commits, registro de autoria em dupla e regras de Pull Request. Todo integrante deve seguir estas diretrizes para manter o histórico rastreável no GitHub e garantir total conformidade entre o código-fonte e os diagramas C4.

## 1. Estratégia de Branches

| Branch | Papel Principal | Regra de Merge |
| :--- | :--- | :--- |
| main | Versão estável para entrega | Recebe merge de develop |
| develop | Integração de docs e código | Recebe PRs de trabalho |
| docs/nome-da-tarefa | Modelagem C4, README e ADRs | Criada a partir de develop |
| feat/nome-da-tarefa | Código Core, Simulador e Infra | Criada a partir de develop |

Como o projeto possui frentes de documentação arquitetural (Structurizr DSL e ADRs) e frentes de implementação parcial (Infra Docker, Simulador Python e Serviço Core em Spring Boot), utilize prefixos claros ao nomear sua branch[cite: 1, 2]:

* **Documentação e C4:** `docs/c4-contexto-container`, `docs/c4-componentes-core`, `docs/adr-escolhas-arquiteturais`
* **Infraestrutura e Mensageria:** `feat/infra-docker-rabbitmq`, `feat/infra-postgres-schema`
* **Simulador e Receptores:** `feat/simulador-leitura-ubs`, `feat/receptor-alertas-console`
* **Serviço Central (Clean Arch):** `feat/core-entidades-circuito`, `feat/core-usecase-sobrecarga`

### Fluxo na prática

```text
docs/c4-contexto-container    ──┐
feat/infra-docker-rabbitmq    ──┼──►  Pull Request  ──►  develop  ──►  (acompanhamento/entrega)  ──►  main
feat/core-usecase-sobrecarga  ──┘
```

1. Nunca faça commit diretamente nas branches principais (`main` ou `develop`).
2. Antes de iniciar uma tarefa do cronograma, atualize sua base local e crie a branch: `git checkout develop` seguido de `git pull` e `git checkout -b prefixo/nome-da-tarefa`.
3. Ao concluir a entrega da sua dupla, abra um Pull Request da sua branch para a `develop`.
4. Pelo menos 1 integrante de outra dupla deve revisar o PR antes do merge (verificando se os nomes batem com o modelo C4).
5. O merge de `develop` para `main` ocorre ao fechar cada marco oficial da disciplina (Acompanhamento 1 em 16/11, Acompanhamento 2 em 23/11 e Entrega Final em 01/12).

## 2. Padrão de Commits (Conventional Commits)

Formato obrigatório: `tipo: descrição breve no imperativo`

| Tipo | Uso no EcoGrid Público | Etapa Principal |
| :--- | :--- | :--- |
| docs | Diagramas Structurizr, ADRs e README | Etapas 1 e 2 |
| feat | Novos módulos, casos de uso e scripts | Etapa 3 |
| fix | Correção de bugs em código ou DSL | Todas |
| refactor | Ajuste de camadas Clean Architecture | Etapa 3 |
| chore | Setup de Docker, Maven e dependências | Etapas 1 e 3 |

### Exemplos aplicados ao escopo do EcoGrid Público

```text
docs: adiciona diagramas de contexto e container no Structurizr
docs: documenta ADR 01 sobre adocao do RabbitMQ no estilo Event-Driven
docs: detalha requisitos RF01 a RF05 e escopo social de escolas e UBS
chore: importa dependencias do Spring Boot para RabbitMQ e PostgreSQL
chore: configura containers do RabbitMQ e PostgreSQL no Docker Compose
feat: implementa script simulador de sobrecarga na camara de vacinas (RF01)
feat: implementa ProcessTelemetryReadingUseCase no servico core (RF03)
feat: publica eventos nas filas optimization.commands e alerts.critical (RF04)
refactor: isola LoadSheddingPolicyService e CircuitEntity na camada de dominio
```

### Boas práticas

* Escreva o verbo sempre no **imperativo** ("adiciona", "modela", "implementa", e não "adicionado" ou "implementando").
* Mantenha **uma entrega lógica por commit**, evitando misturar alterações na DSL do Structurizr com código Java ou Python no mesmo commit.
* Referencie o requisito funcional (RF01 a RF05) ou a decisão arquitetural (ADR 01 a ADR 03) sempre que o commit tiver relação direta com um item do escopo.

### Trabalho em Dupla (Pair Programming — Co-authored-by)

Como o cronograma do projeto é dividido em duplas, sempre que os dois integrantes trabalharem juntos na mesma máquina (presencialmente ou via tela compartilhada/Live Share), adicionem o rodapé `Co-authored-by:` no final da mensagem de commit (deixando uma linha em branco antes dele):

```text
feat: implementa ProcessTelemetryReadingUseCase no servico core (RF03)

Co-authored-by: Nome do Colega <email-do-github@exemplo.com>
```

Para fazer isso direto pelo terminal, basta usar dois parâmetros `-m`:

```bash
git commit -m "docs: adiciona diagramas de contexto e container no Structurizr" -m "Co-authored-by: Nome do Colega <email-do-github@exemplo.com>"
```

## 3. Pull Requests e Conformidade C4

* O título do Pull Request deve seguir o padrão do Conventional Commits (ex.: `feat: implementa caso de uso de deteccao de sobrecarga (RF03)`).
* Descreva de forma objetiva o que foi modelado ou codificado e como testar (ex.: comando para subir o Structurizr ou para testar o envio de JSON na fila `telemetry.readings`).
* **Regra de Conformidade C4 (Obrigatória):** Na Etapa 3, qualquer classe, pacote ou componente criado no código (`TelemetryConsumerController`, `ProcessTelemetryUseCase`, `LoadSheddingPolicyService`, `CircuitEntity`, `UnitRepositoryPort`, `EventPublisherAdapter`) deve possuir exatamente a mesma nomenclatura definida nos diagramas de Nível 3 e Nível 4. Se a dupla alterar o nome de uma classe ou fila no código, deve atualizar a DSL do Structurizr no mesmo Pull Request.
* Se a alteração mudar o formato do payload JSON entre o Simulador Python, o RabbitMQ e o Serviço Core em Spring Boot, destaque a mudança de contrato na descrição do PR.