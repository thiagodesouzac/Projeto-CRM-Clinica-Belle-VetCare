# Clínica Belle VetCare CRM

**Solução CRM Customizada em Salesforce para Clínica Veterinária**

---

## Visão Geral

O Belle VetCare é um projeto de CRM desenvolvido em Salesforce que estrutura e automatiza a operação completa de uma clínica veterinária. A solução centraliza o cadastro de tutores, pets, veterinários e consultas em uma única plataforma, implementando automações operacionais, segurança de dados e experiência de atendimento digital.

Este projeto demonstra domínio prático em **Salesforce Administration**, **Salesforce Development**, modelagem de dados customizados, automação com Flow, segurança e implementação de bot (Agentforce) de atendimento.

---

## Contexto do Projeto

### Desafio de Negócio

A operação de uma clínica veterinária enfrenta desafios operacionais significativos:

- Desorganização de informações dispersas entre tutor, pet e consulta
- Falta de padronização no processo de agendamento
- Dependência de ações manuais para comunicação com veterinários
- Ausência de indicadores para acompanhamento da rotina clínica
- Necessidade de triagem automatizada para reduzir erros no atendimento

### Solução Proposta

Uma plataforma CRM centralizada que:

- Organiza cadastro de tutores e pets de forma estruturada
- Automatiza o processo de agendamento com validações
- Notifica veterinários automaticamente sobre consultas
- Fornece visibilidade operacional através de relatórios e dashboards
- Oferece atendimento inicial automatizado com bot inteligente

---

## Arquitetura da Solução

### Estrutura de Objetos Customizados

A solução foi construída sobre quatro objetos principais que representam a jornada operacional da clínica:

```
Tutor__c ←→ Pet__c
  ↓           ↓
Appointment__c ←→ Vet__c
```

#### 1. Tutor__c (Responsável pelo Pet)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Name | Text | Nome do responsável |
| CPF | Text | CPF com validation rules |
| Email | Email | Email de contato |
| Phone | Phone | Telefone para comunicação |
| Address | Text | Endereço residencial |
| CEP | Text | CEP com validation rules |
| Quantity Pet | Number | Quantidade de pet do tutor |

#### 2. Pet__c (Paciente)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Pet Name | Text | Nome do animal |
| Pet Species | Picklist | Tipo de animal (cachorro, gato, coelho, etc) |
| Breed | Text | Raça do animal |
| Age | Number | Idade |
| Sex | Picklist | Sexo do animal |
| Weight | Number | Peso em kg |
| Tutor | Lookup (Tutor) | Referência ao Tutor__c |
| Vet | Lookup (Vet) | Veterinário responsável |

#### 3. Vet__c (Veterinário)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Vet Name | Text | Nome do veterinário |
| CRMV | Text | Registro profissional |
| Email | Email | Email corporativo |
| Phone | Phone | Telefone para contato |
| Specialty | Picklist | Campo de especialização |
| Available Days | Picklist (multi-select) | Dias de atendimentos |
| Status | Picklist | Ativo ou Inativo |
| Veterinary User | Lookup (User) | 

#### 4. Appointment__c (Agendamento)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Canceled by | Text | Cancelado por (Atendente ou Bot) |
| CPF Tutor | Text | CPF do Tutor |
| Date | Date | Data da consulta
| Email Vet | Email | Email do veterinário |
| Notes | Text Area | Campo de observação |
| Pet | Lookup(Pet) | Animal a ser atendido |
| Reference | Auto Number | Nome/Número do prontuário |
| Service Type | Picklist | Tipo de atendimento (Consulta, Vacinação, Exames, etcs) |
| Species | Picklist | Espécies (Cachorro, Gato, Coelho, etcs) |
| Status | Picklist | Ativo ou Inativo |
| Time | Picklist | Horário do atendimento padronizado |
| Tutor | Lookup(Tutor) | Responsável pelo pet |
| Vet | Lookup(Vet) | Animal a ser atendido |

| Tipo de Atendimento | Picklist | Consulta, vacinação, cirurgia, exames, internação, emergência |

---

## Funcionalidades Principais



### Flow 1. Automação de Notificações

#### Vet Appointment Alert

**Tipo:** Record-Triggered Flow

Executado automaticamente após a criação de um registro de consulta (`Appointment`).

**Responsabilidades:**

- Valida a existência de um veterinário vinculado ao agendamento.
- Envia uma notificação por e-mail ao veterinário responsável.
- Inclui no e-mail as informações da consulta:
  - Pet;
  - Tutor;
  - Data;
  - Horário;
  - Tipo de atendimento.

---

#### Vet Cancellation Alert

**Tipo:** Record-Triggered Flow

Executado automaticamente quando uma consulta é cancelada.

**Responsabilidades:**

- Valida o relacionamento entre a consulta e o veterinário responsável.
- Envia uma notificação por e-mail informando o cancelamento da consulta.

---

### Flow 2. Automação do Bot

#### 2. Bot Tutor Pet Registration (Cadastro)

**Tipo:** Autolaunched Flow

Flow responsável pelo cadastro de tutores e pets, acionado pelo chatbot.

**Responsabilidades:**

- Verifica a existência do tutor por meio do CPF informado.
- Consulta o registro do tutor utilizando o identificador (`Id`).
- Caso o tutor não exista:
  - Cria o registro do tutor com os seguintes campos:
    - Nome;
    - CPF;
    - E-mail;
    - Endereço;
    - CEP.
- Realiza a validação para confirmar a criação do cadastro.
- Implementa tratamento de exceções utilizando caminhos **Fault**.

---

#### 3. Bot Scheduling (Agendamento de Consulta)

**Tipo:** Autolaunched Flow

Flow responsável pelo agendamento de consultas, acionado pelo chatbot.

**Responsabilidades:**

- Valida o CPF informado, garantindo a padronização em 11 dígitos.
- Verifica a existência do tutor e do pet cadastrados.
- Cria o registro da consulta preenchendo os seguintes campos:
  - Pet;
  - Tutor;
  - Data;
  - Horário;
  - Tipo de atendimento;
  - Status **Agendado**.
- Implementa tratamento de exceções (**Fault**) com retorno da mensagem:
  - *"Ocorreu um erro interno. Tente novamente."*
- Retorna mensagem de confirmação após a conclusão do processo:
  - *"Agendamento realizado com sucesso."*

---

#### 4. Bot Cancel Appointment (Cancelamento de Consulta)

**Tipo:** Autolaunched Flow

Flow responsável pelo cancelamento de consultas, acionado pelo chatbot.

**Responsabilidades:**

- Localiza a consulta utilizando os seguintes critérios:
  - CPF do tutor;
  - Nome do pet;
  - Status **Agendado**;
  - Data;
  - Horário.
- Valida se a consulta já foi cancelada anteriormente.
- Efetua o cancelamento da consulta quando elegível.
- Retorna uma mensagem de confirmação contendo os dados da consulta cancelada.

---

## 2. Validação de Dados

O projeto implementa validações robustas para garantir integridade cadastral:

- **Validação de CPF**: Fórmula de validação automática do documento.

    • Ex: Informe 11 números ou utilize o formato 000.000.000-00.

- **Validação de CEP**: Validação de formato postal
      
    • O formato correto deve ser 99999-999.
      
- **Regras de Relacionamento**: Garante que agendamento tenha tutor e pet válidos
      
    • Validação de campos obrigatórios (Required)
---

## 3. Lightning App Customizado

Interface de navegação organizada para operação da clínica com tabs:

- **Pets**: Gerenciamento de pacientes
- **Tutors**: Cadastro de responsáveis
- **Vets**: Quadro de veterinários
- **Appointment**: Agendamentos e consultas
- **Reports**: Relatórios operacionais
- **Dashboards**: Indicadores gerenciais

---

## Camada de Segurança e Governança

## Objetivo

Implementar uma camada de segurança seguindo as melhores práticas do Salesforce para garantir que cada perfil de usuário visualize apenas as informações necessárias para desempenhar suas funções dentro da clínica veterinária.

A arquitetura foi projetada para proteger dados sensíveis, controlar o acesso aos registros e proporcionar uma experiência adequada para cada tipo de usuário, sem comprometer a produtividade da equipe.

- Administradores possuam controle total sobre toda a aplicação;
- Veterinários tenham acesso às informações necessárias para atendimento clínico;
- Recepcionistas consigam realizar agendamentos e localizar veterinários sem acesso a informações administrativas ou confidenciais.

---

## Arquitetura Final de Segurança

A camada de segurança foi construída utilizando múltiplos recursos nativos do Salesforce, formando uma arquitetura de acesso em diferentes níveis.

| Camada | Configuração |
|---------|--------------|
| **Profile** | Standard Platform User |
| **Permission Set** | Recepcionista |
| **Organization-Wide Defaults (OWD)** | Private |
| **Role Hierarchy** | CEO → Veterinarian → Receptionist |
| **Sharing Rules** | Read Only para Receptionists |
| **Field-Level Security (FLS)** | Apenas Vet Name e Email visíveis |
| **Dynamic Forms** | Seções exibidas conforme perfil/permissão |
| **CRUD** | Apenas Read no objeto Vet |
| **View All** | Não |
| **Modify All** | Não |

Essa combinação garante que o acesso aos dados seja controlado desde o nível do objeto até a visualização individual dos campos, seguindo uma estratégia de segurança em camadas (*Layered Security*).

---

## Modelo de Controle de Acesso

### Perfil Padrão

Foi utilizado apenas um perfil padrão (**Standard Platform User**) como configuração inicial de acesso.

Essa abordagem reduz a quantidade de perfis na organização e segue uma das recomendações da arquitetura moderna do Salesforce, onde o perfil concede apenas permissões básicas e os acessos específicos são distribuídos através de **Permission Sets**.

### Permission Set — Recepcionista

Foi criado um **Permission Set** específico para os usuários responsáveis pelo atendimento da recepção.

#### Permissões concedidas

- Criar Tutores;
- Editar Tutores;
- Criar Pets;
- Editar Pets;
- Criar Agendamentos;
- Editar Agendamentos;
- Visualizar informações básicas dos veterinários.

#### Restrições

- Sem permissão para excluir registros;
- Sem permissão para criar veterinários;
- Sem permissão para editar veterinários;
- Sem permissão para acessar informações administrativas;
- Sem permissões **View All** ou **Modify All**.

Essa estratégia torna a administração de permissões mais flexível, reutilizável e escalável, evitando a criação de múltiplos perfis para diferentes funções.

---

## Organização da Segurança

### Organization-Wide Defaults (OWD)

O **Organization-Wide Defaults (OWD)** foi configurado como **Private** para o objeto **Vet**, estabelecendo o nível mais restritivo de acesso aos registros.

Com essa configuração:

- Nenhum usuário visualiza registros automaticamente;
- Todo acesso depende de regras adicionais de compartilhamento;
- A exposição indevida de informações é reduzida;
- A segurança da aplicação passa a ser controlada por camadas superiores.

Essa configuração representa a base da política de governança adotada no projeto.

---

### Role Hierarchy

A **Role Hierarchy** foi implementada para representar a estrutura organizacional da clínica veterinária.

```text
CEO
│
├── Veterinarian
│
└── Receptionist
```

Essa organização permite que a hierarquia reflita as responsabilidades reais da empresa e facilita a administração das permissões conforme o crescimento da organização.

---

### Sharing Rules

O **OWD** foi definido como **Private**, e **Sharing Rules** para conceder acesso controlado aos registros do objeto **Vet**.

A regra criada:

- **Read Only**
- Grupo de destino: **Receptionists**

Dessa forma, a recepcionista consegue localizar veterinários durante o processo de agendamento sem receber permissões de edição ou administração.

Esse modelo mantém a segurança dos registros enquanto fornece o acesso mínimo necessário para execução das atividades operacionais.

---

## Segurança em Nível de Campo

### Field-Level Security (FLS)

Mesmo possuindo acesso ao registro do veterinário, a recepcionista não visualiza todos os campos.

Foi aplicada uma configuração de **Field-Level Security (FLS)** permitindo acesso apenas às informações indispensáveis para o atendimento.

#### Campos visíveis

- Nome do Veterinário;
- E-mail.

#### Campos ocultos

- CRMV;
- Telefone;
- Especialidade;
- Dias Disponíveis;
- Status;
- Campos administrativos.

Essa camada garante que informações sensíveis permaneçam protegidas independentemente do acesso concedido ao registro.

---

## Personalização da Interface

### Dynamic Forms

Os **Dynamic Forms** foram implementados para personalizar dinamicamente a interface do objeto **Vet**, exibindo apenas as informações relevantes de acordo com o perfil funcional e as permissões atribuídas ao usuário.

Essa abordagem permitiu segmentar a visualização dos campos sem a necessidade de múltiplos Page Layouts, proporcionando uma interface mais intuitiva, organizada e alinhada às responsabilidades de cada função dentro da aplicação.

> **Observação:** Os Dynamic Forms foram utilizados em conjunto com **Field-Level Security (FLS)**. Enquanto os Dynamic Forms controlam a experiência de visualização da interface, o FLS garante a proteção efetiva dos dados em nível de campo.

### Page Layout

O **Lightning Record Page** do objeto **Vet** foi configurado utilizando **Dynamic Forms**, criando seções específicas para diferentes tipos de usuários.

Campos (Field Section) criados:

    • Basic Information: Adicionados Vet Name e Email. Filtro criado apenas para visualização de Standart Platform User.
      
    • Administrative Information: Adicionados os demais campos que foram ocultados. Filtro criado apenas para visualização de System Administrator


Para o perfil de **Recepcionista**, a interface foi simplificada para exibir exclusivamente os campos necessários ao processo de agendamento de consultas:

- **Vet Name**
- **Email**

Os demais campos permanecem ocultos para esse perfil, reduzindo a exposição de informações administrativas e sensíveis, sem comprometer a funcionalidade do campo **Lookup** utilizado no objeto **Appointment**.
---

## Governança de Permissões

Toda a arquitetura foi construída utilizando uma estratégia em camadas:

1. **Profile** define permissões básicas;
2. **Permission Sets** concedem permissões adicionais específicas;
3. **Organization-Wide Defaults (OWD)** restringe o acesso aos registros;
4. **Role Hierarchy** organiza a estrutura corporativa;
5. **Sharing Rules** compartilham apenas os registros necessários;
6. **Field-Level Security (FLS)** protege informações sensíveis;
7. **Dynamic Forms** personalizam a interface para cada usuário.

---

## Princípio do Menor Privilégio (Least Privilege)

Toda a arquitetura de segurança foi desenvolvida com base no **Princípio do Menor Privilégio (Least Privilege)**.

Cada usuário recebe apenas as permissões estritamente necessárias para executar suas atividades, reduzindo riscos de acesso indevido e fortalecendo a governança da aplicação.

---

## Conclusão

A camada de segurança do **Belle VetCare CRM** foi projetada utilizando uma arquitetura baseada em múltiplos mecanismos nativos do Salesforce, combinando **Organization-Wide Defaults (OWD)**, **Role Hierarchy**, **Sharing Rules**, **Permission Sets**, **Field-Level Security (FLS)** e **Dynamic Forms** para garantir proteção em diferentes níveis.

---

## Análise e Relatórios

### Custom Report Type

Baseado no objeto Appointment__c para estruturar dados analíticos.

### Relatórios Implementados

#### Consultas por Dia

- Exibe volume diário de consultas
- Útil para acompanhamento operacional

#### Consultas por Mês

- Agrega dados mensais
- Identifica tendências de atendimento

#### Consultas por Veterinário

- Distribuição de carga de trabalho
- Identifica especialista mais demandado

#### Tipos de Atendimento por Mês

- Categoriza atendimentos (consulta, vacinação, cirurgia, exames, emergência)
- Oferece visão de demanda por tipo de serviço

### Dashboard Operacional

Componentes gráficos para gestão em tempo real:

| Componente | Tipo | Métrica |
|-----------|------|--------|
| Line Chart | Gráfico de linha | Quantidade de consultas por dia |
| Metric Chart | Card | Total de consultas no mês |
| Bar Chart | Gráfico de barras | Veterinário com mais consultas |
| Donut Chart | Gráfico de pizza | Distribuição de tipos de atendimento |

---

## Stack Tecnológico

| Componente | Tecnologia |
|-----------|-----------|
| Plataforma | Salesforce |
| Automação | Flow (Record-Triggered e Autolaunched) |
| Interface | Lightning (App, Pages, Components, Layout) |
| Relatórios | Salesforce Reports & Dashboards |
| Bot | Salesforce Enhanced Bot |
| Banco de Dados | Salesforce Objects e Fields |

---

## Fluxo Operacional Completo

### 1. Primeiro Contato

Cliente entra em contato através do bot ou recepção:

```
Cliente → Bot/Atendente (Recepcionista) → Validação CPF → Cadastro ou Agendamento
```

### 2. Cadastro

Se novo cliente:

```
Criar Tutor__c → Criar Pet__c → Validar dados → Ativar perfil
```

### 3. Agendamento

Cliente marca consulta:

```
Informações da consulta: Tipo de atendimento → Status → Data → Hora → Veterinário → Email Veterinário → CPF Tutor 
Informações do Pet: Nome do pet → Espécie → Tutor → Confirmar
                                              ↓
                                    Appointment__c criado
                                              ↓
                                    Record-Triggered Flow dispara
                                              ↓
                                    E-mail enviado ao Vet
```

## Fluxo do Chatbot 

O chatbot da Belle VetCare foi desenvolvido para automatizar o atendimento inicial da clínica veterinária, permitindo que tutores realizem cadastro, agendamento e cancelamento de consultas de forma autônoma.

O fluxo foi implementado utilizando **Einstein Bot**, integrado aos **Salesforce Flows**, responsáveis pela validação de dados, consulta aos registros e execução das operações no CRM.

---

# Fluxo Principal (Main Menu)

Ao iniciar uma conversa, o chatbot apresenta uma mensagem de boas-vindas e exibe o menu principal.

## Mensagem Inicial

> Olá! Seja bem-vindo(a) à **Belle VetCare**.
>
> Como posso ajudar você hoje?

### Opções disponíveis

| Opção | Funcionalidade |
|--------|----------------|
| **1** | Cadastro de Tutor e Pet |
| **2** | Agendamento de Consulta |
| **3** | Cancelamento de Consulta |
| **4** | Atendimento Humano |
| **5** | Encerrar Conversa |

---

# Fluxo 1 — Cadastro de Tutor e Pet

## Objetivo

Realizar o cadastro completo do tutor e do respectivo pet no Salesforce.

## Coleta de Dados do Tutor

O chatbot solicita as seguintes informações:

- Nome completo
- CPF
- E-mail
- Telefone
- Endereço
- CEP

## Coleta de Dados do Pet

Após concluir o cadastro do tutor, são solicitados os dados do animal.

Campos coletados:

- Nome do pet
- Espécie

---

## Confirmação dos Dados

Antes da gravação dos registros, o bot apresenta um resumo das informações coletadas para validação do usuário.

### Exemplo

```text
Tutor: Thiago Developer

CPF: 12365478900

E-mail: thiagodev@gmail.com

Telefone: (41) 99999-9999

Endereço:
Rua Testador, 100

CEP:
80111-222

Pet:
Spike

Espécie:
Cachorro
```

O usuário deve confirmar:

| Opção | Ação |
|--------|------|
| **1 - Sim** | Executa o Flow responsável pela criação dos registros no Salesforce. |
| **2 - Não** | Descarta as informações coletadas e retorna ao Menu Principal para reiniciar o cadastro. |

---

## Cadastro realizado com sucesso

Após a criação dos registros, o chatbot informa:

```text
Cadastro realizado com sucesso!

Tutor:
Thiago Developer

Pet:
Spike

Agora você já pode realizar agendamentos diretamente pelo chatbot.
```
---

# Fluxo 2 — Agendamento de Consulta

## Objetivo

Permitir que um tutor já cadastrado realize o agendamento de uma consulta para um de seus pets.

---

## Validação do Tutor

O processo inicia solicitando o CPF do responsável.

```text
Informe seu CPF (somente números).
```

O Flow consulta o Salesforce para localizar:

- Tutor
- Pet vinculado ao tutor

---

## Dados do Agendamento

Após localizar o cadastro, o chatbot solicita:

- Nome do pet
- Data desejada
- Horário disponível
- Tipo de atendimento

### Horários disponíveis

| Código | Horário |
|---------|----------|
| 1 | 08:00 |
| 2 | 09:00 |
| 3 | 10:00 |
| 4 | 11:00 |
| 5 | 14:00 |
| 6 | 15:00 |
| 7 | 16:00 |
| 8 | 17:00 |

---

### Tipo de Atendimento

| Código | Atendimento |
|---------|--------------|
| 1 | Consulta |
| 2 | Vacinação |
| 3 | Cirurgia |
| 4 | Exames |
| 5 | Emergência |

---

## Confirmação do Agendamento

Após a criação do registro **Appointment**, o chatbot apresenta um resumo.

### Exemplo

```text
Consulta agendada com sucesso.

Pet:
Spike

Data:
01/07/2026

Horário:
10:00

Caso seja necessário alterar ou cancelar o agendamento futuramente, basta iniciar uma nova conversa com o chatbot.
```

---

## Próxima ação

Ao final do processo, o usuário pode escolher:

| Opção | Ação |
|--------|------|
| **1** | Retornar ao Menu Principal |
| **2** | Encerrar atendimento |

---

# Fluxo 3 — Cancelamento de Consulta

## Objetivo

Permitir o cancelamento de uma consulta previamente agendada.

---

## Localização do Agendamento

O chatbot solicita:

```text
Informe o CPF do responsável.
```

O Flow consulta os registros de **Appointment** vinculados ao tutor informado.

---

## Cenário 1 — Consulta Encontrada

Caso exista um agendamento válido:

- O chatbot apresenta os dados da consulta.
- Solicita confirmação do cancelamento.
- Executa o Flow responsável pela exclusão ou atualização do status do agendamento.
- Exibe mensagem de sucesso.

---

## Cenário 2 — Consulta Não Encontrada

Caso não exista agendamento para o CPF informado:

```text
Não foi localizada nenhuma consulta agendada para o CPF informado.
```

O usuário poderá escolher:

| Opção | Ação |
|--------|------|
| **1** | Informar outro CPF |
| **2** | Retornar ao Menu Principal |

---

# Fluxo 4 — Atendimento Humano

## Objetivo

Transferir o atendimento para um colaborador da clínica.

Mensagem apresentada:

```text
Estou transferindo sua conversa para um atendente.

Por favor, aguarde alguns instantes.
```

Nesta etapa o chatbot encerra seu fluxo automatizado e direciona o usuário ao atendimento humano.

---

# Fluxo 5 — Encerramento da Conversa

Quando o usuário seleciona a opção **Encerrar**, o chatbot finaliza a sessão.

Mensagem exibida:

```text
Obrigado por utilizar os serviços da Belle VetCare.

Foi um prazer atendê-lo.

Até a próxima!
```

Após o encerramento, uma nova interação poderá ser iniciada abrindo uma nova conversa.

---

# Resumo da Arquitetura Conversacional

```text
Início

│

├── Menu Principal

│      │

│      ├── Cadastro
│      │       │
│      │       ├── Dados Tutor
│      │       ├── Dados Pet
│      │       ├── Confirmação
│      │       └── Create Records

│      ├── Agendamento
│      │       │
│      │       ├── Validar CPF
│      │       ├── Buscar Tutor
│      │       ├── Buscar Pet
│      │       ├── Dados Consulta
│      │       └── Create Appointment

│      ├── Cancelamento
│      │       │
│      │       ├── Validar CPF
│      │       ├── Buscar Appointment
│      │       └── Cancelar Consulta

│      ├── Atendimento Humano

│      └── Encerrar Conversa
```

---

# Componentes Salesforce Utilizados

| Componente | Finalidade |
|------------|------------|
| **Einstein Bot** | Interface conversacional com o usuário |
| **Dialogs** | Estrutura das conversas |
| **Rules** | Controle de navegação entre diálogos |
| **Variables** | Armazenamento temporário das respostas do usuário |
| **Entities** | Validação e reconhecimento de entradas |
| **Flow Builder** | Automação das regras de negócio |
| **Get Records** | Consulta de registros existentes |
| **Create Records** | Criação de Tutor, Pet e Appointment |
| **Update/Delete Records** | Cancelamento de consultas |
| **Custom Objects** | Tutor, Pet, Vet e Appointment |
---

Gestão operacional:

```
Dashboard mostra volume do dia
Relatório identifica gargalos
Vet recebe alertas automáticos
Sistema registra histórico completo
```
---

## Competências Demonstradas

### Salesforce Administration

- Modelagem de objetos customizados
- Criação e configuração de campos
- Definição de relacionamentos (Lookup)
- Organização de Lightning App Builder
- Configuração de perfil e permission sets
- Implementação de field-level security
- Criação de custom report types
- Design de relatórios e dashboards

### Salesforce Automation & Development

- Construção de lógica de negócio com Flow
- Record-Triggered Flows para notificações
- Autolaunched Flows para bot e atendente
- Integração de e-mail automático
- Validação de dados com CPF e CEP
- Desenho de fluxo de agendamento
- Implementação de atendimento digital com bot

### Visão de Negócio

- Tradução de operação clínica em arquitetura CRM
- Organização de jornada de atendimento
- Separação entre cadastro, agendamento, cancelamento e indicadores
- Aplicação de segurança conforme perfil operacional

---

## Resultados Entregues

O projeto Belle VetCare consolidou em uma única plataforma:

- Cadastro organizado de tutores e pets
- Gerenciamento de quadro veterinário
- Controle centralizado de agendamentos
- Automação de notificações por e-mail
- Segurança granular por perfil
- Visibilidade operacional via relatórios
- Atendimento digital automatizado com bot
- Dashboard para tomada de decisão

---

## Conclusão

O Belle VetCare CRM representa um case completo de desenvolvimento Salesforce que integra modelagem de dados, segurança, automação, analytics e atendimento digital. O projeto posiciona para vagas com foco em **Salesforce Administrator** ou **Salesforce Developer/Automation**, demonstrando domínio prático da plataforma em diferentes camadas da solução.

---

## Informações do Projeto

- **Tipo**: Projeto Portfólio / Case Estudo
- **Plataforma**: Salesforce
- **Escopo**: CRM Customizado
- **Área de Negócio**: Saúde Animal / Clínica Veterinária
- **Status**: Completo e Funcional

---

**Desenvolvido como demonstração prática de competências em Salesforce Administration e Development**

Elaborado por Thiago de Souza – Salesforce Developer & Administrator
