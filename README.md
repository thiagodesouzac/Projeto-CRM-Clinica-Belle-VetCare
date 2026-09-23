# Clínica Belle VetCare CRM

**CRM customizado em Salesforce para gestão de clínica veterinária, combinando Salesforce Administration, automação declarativa, Apex, SOQL, Lightning Web Components (LWC), segurança, analytics e atendimento digital.**

---

## Visão Geral

O **Belle VetCare CRM** é um projeto de portfólio desenvolvido em Salesforce para estruturar e automatizar a operação de uma clínica veterinária.

A solução centraliza o cadastro de **tutores, pets, veterinários e consultas** em uma única plataforma, implementando automações operacionais, validações, segurança de dados, relatórios, dashboards e atendimento digital.

O projeto evoluiu de uma arquitetura predominantemente declarativa para uma solução que também utiliza **Apex e LWC** para resolver regras de negócio que exigem lógica programática.

> **Objetivo técnico:** demonstrar, em um único case, competências práticas de Salesforce Administration e Salesforce Development, desde modelagem e segurança até implementação de regras de negócio, testes automatizados e componentes Lightning.

---

## Problema de Negócio

Uma clínica veterinária pode enfrentar problemas como:

- Informações dispersas entre tutor, pet e consulta;
- Falta de padronização no processo de agendamento;
- Dependência de ações manuais para comunicação com veterinários;
- Ausência de indicadores operacionais;
- Necessidade de triagem e cadastro automatizados;
- **Overbooking**, quando dois compromissos são criados para o mesmo veterinário, data e horário.

### Problema técnico crítico

O modelo declarativo não impedia que dois compromissos fossem registrados para o mesmo veterinário no mesmo horário.

Para resolver esse cenário, foi criada uma **regra de negócio em Apex** que valida conflitos antes da inserção ou atualização de `Appointment__c`.

---

# Arquitetura da Solução

## Modelo de Dados

A solução utiliza quatro objetos principais:

```text
PetOwner__c ←→ Pet__c
     ↓           ↓
Appointment__c ←→ Vet__c
```

### PetOwner__c — Responsável pelo Pet

| Campo | Tipo | Descrição |
|---|---|---|
| Name | Text | Nome do responsável |
| CPF | Text | CPF com fórmula/validação |
| Email | Email | E-mail de contato |
| Phone | Phone | Telefone |
| Address | Text | Endereço residencial |
| CEP | Text | CEP com fórmula/validação |
| Quantity Pet | Number | Total de animais do tutor |

### Pet__c — Paciente

| Campo | Tipo | Descrição |
|---|---|---|
| PetName | Text | Nome do animal |
| Species | Picklist | Tipo de animal |
| Breed | Text | Raça |
| Age | Number | Idade em anos |
| Sex | Text | Sexo |
| Weight | Number | Peso em kg |
| Pet Owner | Lookup | Referência ao tutor |
| Vet | Lookup | Veterinário responsável |

### Vet__c — Veterinário

| Campo | Tipo | Descrição |
|---|---|---|
| VetName | Text | Nome do veterinário |
| CRMV | Number | Registro profissional |
| Email | Email | E-mail corporativo |
| Phone | Phone | Telefone |
| Specialty | Picklist | Especialidade |
| Available Days | Picklist | Dias de atendimento |
| Status | Picklist | Status operacional |

### Appointment__c — Agendamento

| Campo | Tipo | Descrição |
|---|---|---|
| Date | Date | Data da consulta |
| Time | Picklist | Horário padronizado |
| PetOwner | Lookup | Responsável pelo pet |
| Pet | Lookup | Animal atendido |
| Service Type | Picklist | Tipo de atendimento |
| CEP | Text | CEP do tutor (obrigatório), usado na busca automática de endereço |
| Street | Text Area | Logradouro, preenchido automaticamente via ViaCEP |
| Neighborhood | Text | Bairro, preenchido automaticamente via ViaCEP |
| City | Text | Cidade, preenchida automaticamente via ViaCEP |
| State | Picklist | UF, preenchida automaticamente via ViaCEP |

---

# Camadas da Solução

## 1. Salesforce Administration

A base do projeto foi construída utilizando recursos declarativos do Salesforce:

- Objetos e campos customizados;
- Relacionamentos Lookup;
- Fórmulas e validações;
- Lightning App;
- Lightning Record Pages;
- Lightning Pages
- Page Layouts
- Validation Rules
- Dynamic Forms;
- Profiles;
- Permission Sets;
- Organization-Wide Defaults;
- Role Hierarchy;
- Sharing Rules;
- Queues
- Field-Level Security;
- RReports & Dashboards;
- Flows (Autolaunched, Screen Flows, Record-Triggered);

---

## 2. Automação com Salesforce Flow

### Record-Triggered Flows

#### Vet Appointment Alert

Executado após a criação de um `Appointment__c`, acionando a comunicação automática com o veterinário responsável.

#### Vet Cancellation Alert

Realiza as validações necessárias e envia uma notificação por e-mail ao veterinário, contendo informações como:

- Pet;
- Tutor;
- Data;
- Horário;
- Tipo de atendimento.

### Autolaunched Flows

Utilizados no atendimento digital:

- `Flow Register PetOwner Pet`
- `Flow Schedule`
- `Flow Validate PetOwner CPF`

---

# Camada de Desenvolvimento — Apex

## AppointmentTrigger

Foi implementado um trigger sobre `Appointment__c` para impedir conflitos de agenda.

```text
AppointmentTrigger
        ↓
AppointmentTriggerHandler
        ↓
Consulta SOQL
        ↓
Identificação de conflito
        ↓
addError()
```

### AppointmentTriggerHandler

A lógica de negócio foi isolada em uma **Handler Class**, mantendo o trigger responsável apenas pelo acionamento.

A validação ocorre antes de:

- `insert`;
- `update`.

O sistema verifica se já existe um compromisso para o mesmo:

- Veterinário;
- Data;
- Horário.

Quando encontra um conflito, o registro é bloqueado utilizando `addError()`.

### Bulkification

A implementação foi estruturada para processamento em lote:

- Consulta SOQL fora de loops;
- Processamento de múltiplos registros;
- Suporte seguro para até 200 registros por transação;
- Respeito aos governor limits do Salesforce.

Essa abordagem demonstra aplicação prática de **Bulkification**, conceito fundamental no desenvolvimento Apex.

---

# Testes Automatizados

## AppointmentTriggerHandlerTest

A classe de teste cobre diferentes cenários da regra de negócio:

| Cenário | Resultado esperado |
|---------|--------------------|
| Criar agendamento sem conflito | Sucesso |
| Criar agendamento com conflito | Falha |
| Atualizar agendamento criando conflito | Falha |
| Processar 200 registros | Sucesso |

A cobertura contempla cenários **positivos, negativos, de atualização e bulk**, demonstrando preocupação com qualidade e confiabilidade do código.

---

# Lightning Web Component

## vetDailyAppointment

O componente **`vetDailyAppointment`** apresenta a agenda diária do veterinário.

### Características

- Lightning Web Component;
- Filtro por data;
- Exibição dos agendamentos do dia;
- `lightning-datatable`;
- Consumo de controlador Apex;
- `@AuraEnabled(cacheable=true)`;
- `@wire` com parâmetro dinâmico;
- Controle de acesso utilizando `WITH SECURITY_ENFORCED`.

### Arquitetura

```text
LWC: vetDailyAppointment
          ↓
        @wire
          ↓
VetAppointmentController
          ↓
        SOQL
          ↓
   Appointment__c
```

O controlador Apex utiliza `WITH SECURITY_ENFORCED` para respeitar as permissões do usuário conectado durante a consulta.

---

# Integração com API Externa — Busca Automática de Endereço (ViaCEP)

## Visão Geral

No cadastro de um agendamento, o CEP do tutor é obrigatório. Para reduzir a digitação manual e evitar erros de endereço, foi implementada uma integração com a API pública **[ViaCEP](https://viacep.com.br)**: ao informar os 8 dígitos do CEP, o sistema consulta o serviço e preenche automaticamente **rua, bairro, cidade e UF** no objeto `Appointment__c`.

### Requisitos atendidos

- Preenchimento automático de `Street__c`, `Neighborhood__c`, `City__c` e `State__c` a partir de `CEP__c`;
- Funcionamento diretamente no botão **New** do `Appointment__c`, sem etapas adicionais para o usuário;
- Aceitação do CEP com ou sem máscara (`80250-070` ou `80250070`);
- Campos preenchidos permanecem editáveis, pois CEPs genéricos de cidades pequenas não possuem logradouro nem bairro;
- Mensagens claras para CEP inválido, inexistente ou serviço indisponível;
- Nenhuma credencial ou dado pessoal enviado à API externa: somente o CEP.

---

## Arquitetura da Integração

```text
Usuário clica em "New" (Appointment__c)
                ↓
Action Override — Aura: appointmentNewOverride
                ↓
LWC: appointmentCepLookup
                ↓  (8 dígitos informados)
Apex: ViaCepController.findAddress(zipCode)
                ↓  HTTP GET · Remote Site Setting "ViaCEP"
API ViaCEP: https://viacep.com.br/ws/{cep}/json/
                ↓
AddressDTO (zipCode, street, neighborhood, city, state)
                ↓
LWC preenche CEP__c · Street__c · Neighborhood__c · City__c · State__c
```

### Componentes

| Componente | Tipo | Responsabilidade |
|---|---|---|
| `ViaCepController` | Apex Class | Valida o CEP, executa o callout, interpreta a resposta e trata erros |
| `ViaCepControllerTest` | Apex Test Class | 14 cenários com `HttpCalloutMock` |
| `appointmentCepLookup` | LWC | Formulário de agendamento, consulta do CEP e preenchimento dos campos |
| `appointmentNewOverride` | Aura Component | Wrapper que permite substituir o botão **New** pelo LWC |
| `ViaCEP` | Remote Site Setting | Autoriza o callout para `https://viacep.com.br` |
| `Appointment_ViaCEP_Access` | Permission Set | Concede acesso à classe `ViaCepController` |

### Mapeamento de campos

| Retorno da API ViaCEP | Campo em `Appointment__c` | Observação |
|---|---|---|
| `cep` | `CEP__c` | Gravado no formato `00000-000` |
| `logradouro` | `Street__c` | Pode vir vazio em CEPs genéricos |
| `bairro` | `Neighborhood__c` | Pode vir vazio em CEPs genéricos |
| `localidade` | `City__c` | |
| `uf` | `State__c` | Picklist com as siglas dos estados (`PR`, `SP`, ...) |

---

## Camada Apex — ViaCepController

```apex
@AuraEnabled
public static AddressDTO findAddress(String zipCode)
```

### Responsabilidades

- Remover caracteres não numéricos do CEP e validar que restaram exatamente 8 dígitos;
- Executar `GET https://viacep.com.br/ws/{cep}/json/` com timeout de 10 segundos;
- Interpretar o JSON com `JSON.deserializeUntyped`, aceitando o indicador `erro` como booleano ou texto;
- Retornar um `AddressDTO` com `zipCode`, `street`, `neighborhood`, `city` e `state`;
- Converter qualquer falha em `AuraHandledException` com mensagem legível (`setMessage`), exibida diretamente ao usuário pelo LWC.

A classe utiliza `with sharing` e não realiza operações DML.

### Tratamento de erros

| Cenário | Mensagem exibida ao usuário |
|---|---|
| CEP nulo, em branco ou diferente de 8 dígitos | `Invalid ZIP code. Enter the 8 digits of the ZIP code.` |
| API retorna HTTP 400 | `ZIP code has an invalid format. Check the digits you entered.` |
| API retorna HTTP 200 com `erro` (CEP inexistente) | `ZIP code not found. Check the number or fill in the address manually.` |
| API retorna HTTP diferente de 200 | `ZIP code lookup service is unavailable right now (HTTP <status>). Fill in the address manually or try again.` |
| Corpo da resposta não é JSON | `Unexpected response from the ZIP code service. Try again.` |
| Exceção no callout (ex.: timeout) | `Could not look up the ZIP code right now. Try again in a moment.` |

---

## Camada Lightning Web Component — appointmentCepLookup

O componente possui **dois modos de operação**, definidos pela presença de `recordId`:

| Modo | Contexto | Comportamento |
|---|---|---|
| **Criação** | Botão **New** (via Action Override) | Carrega o layout de criação do objeto e exibe todas as seções e campos do formulário padrão, com o preenchimento automático de endereço |
| **Edição** | Lightning Record Page do `Appointment__c` | Exibe apenas o bloco **Pet Owner Address** (CEP, Street, Neighborhood, City e State) |

### Principais recursos técnicos

- `lightning-record-edit-form` e `lightning-input-field` para criação e edição do registro;
- `getRecordCreateDefaults` (`lightning/uiRecordApi`) com `@wire` e parâmetro reativo: em modo edição o parâmetro é `undefined` e o wire não é executado;
- Layout dinâmico: campos somente leitura na criação (ex.: `Owner`) são ignorados e, se algum campo de endereço não estiver no Page Layout, ele é adicionado em uma seção própria;
- Chamada Apex imperativa, disparada automaticamente ao completar 8 dígitos;
- Proteção contra respostas obsoletas: `lastQueriedZipCode` descarta o retorno de consultas antigas quando o usuário altera o CEP durante a chamada e evita consultas repetidas para o mesmo CEP;
- Em modo edição, o CEP já salvo é registrado no evento `load`, evitando que o endereço existente seja sobrescrito ao abrir o registro;
- Feedback visual com spinner e mensagem de sucesso ou erro abaixo do campo CEP;
- Após salvar em modo criação, exibe um toast e abre o registro criado com `NavigationMixin`; o botão **Cancel** retorna à lista;
- Fallback: se o layout não puder ser carregado, o componente exibe um aviso e mantém o bloco de endereço utilizável.

### Configuração

As constantes no topo do arquivo `appointmentCepLookup.js` concentram os pontos de ajuste:

| Constante | Função |
|---|---|
| `OBJECT_API_NAME` | API Name do objeto (`Appointment__c`) |
| `FIELD` | API Names dos campos de CEP, rua, bairro, cidade e estado |
| `FORMAT_ZIP_CODE_WITH_HYPHEN` | `true` grava `00000-000` (campo com pelo menos 9 caracteres); `false` grava somente os dígitos |

---

## Camada Aura — Action Override

O menu **Override Properties** (Setup → Object Manager → Buttons, Links, and Actions) lista apenas páginas Visualforce e componentes Aura que implementam `lightning:actionOverride`; um LWC não pode ser selecionado diretamente. Por isso foi criado um wrapper Aura mínimo, que apenas renderiza o LWC:

```xml
<aura:component implements="lightning:actionOverride" access="global">
    <c:appointmentCepLookup />
</aura:component>
```

> **Atenção:** o componente Aura precisa estar na pasta `aura/appointmentNewOverride/`. Arquivos soltos em `aura/` causam erro de deploy e o componente não aparece na lista de override. Como ele aparece no menu de **todos** os objetos, o nome foi mantido explícito.

---

## Estrutura de Arquivos

```text
force-app/main/default/
├── aura/
│   └── appointmentNewOverride/
│       ├── appointmentNewOverride.cmp
│       └── appointmentNewOverride.cmp-meta.xml
├── classes/
│   ├── ViaCepController.cls
│   ├── ViaCepController.cls-meta.xml
│   ├── ViaCepControllerTest.cls
│   └── ViaCepControllerTest.cls-meta.xml
├── lwc/
│   └── appointmentCepLookup/
│       ├── appointmentCepLookup.html
│       ├── appointmentCepLookup.js
│       └── appointmentCepLookup.js-meta.xml
├── permissionsets/
│   └── Appointment_ViaCEP_Access.permissionset-meta.xml
└── remoteSiteSettings/
    └── ViaCEP.remoteSite-meta.xml
```

---

## Implantação e Configuração

1. **Deploy dos metadados**

```bash
sf project deploy start --source-dir force-app/main/default
```

2. **Executar os testes**

```bash
sf apex run test --class-names ViaCepControllerTest --code-coverage --result-format human --wait 10
```

3. **Atribuir o Permission Set** `Appointment - Busca de CEP (ViaCEP)` aos usuários que criam agendamentos: Setup → Permission Sets → Manage Assignments → Add Assignment.

4. **Ativar o Action Override:** Setup → Object Manager → Appointment → Buttons, Links, and Actions → **New** → Edit. Em **Lightning Experience Override**, selecione **Lightning component** e escolha `c:appointmentNewOverride`. Salve e recarregue o Salesforce.

5. **Opcional — Record Page:** no Lightning App Builder, adicione o componente **Appointment ZIP Code Lookup** à Record Page do `Appointment__c` para editar o endereço de agendamentos existentes.

### Uso

1. Acesse **Appointments** e clique em **New**;
2. Preencha os dados do agendamento e digite o CEP do tutor;
3. Ao completar os 8 dígitos, rua, bairro, cidade e UF são preenchidos e a mensagem `Address filled in automatically.` é exibida;
4. Revise os campos, se necessário, e clique em **Save**.

---

## Testes Automatizados — ViaCepControllerTest

Os testes não dependem da API real: o serviço é simulado por um `HttpCalloutMock` configurável (status, corpo e exceção) registrado com `Test.setMock`. Nos cenários de sucesso, também são validados o **endpoint** e o **método HTTP** utilizados no callout.

| Cenário | Resultado esperado |
|---|---|
| CEP válido com máscara (`01001-000`) | Endereço retornado; chamada `GET` para `.../ws/01001000/json/` |
| CEP válido sem máscara | Endereço retornado |
| CEP genérico, sem logradouro e bairro | Rua e bairro vazios; cidade e UF preenchidas |
| CEP inexistente (`{"erro": true}`) | `AuraHandledException` — CEP não encontrado |
| CEP inexistente (`{"erro": "true"}`) | `AuraHandledException` — CEP não encontrado |
| CEP nulo | `AuraHandledException` — CEP inválido |
| CEP em branco | `AuraHandledException` — CEP inválido |
| CEP com menos de 8 dígitos | `AuraHandledException` — CEP inválido |
| CEP com mais de 8 dígitos | `AuraHandledException` — CEP inválido |
| CEP com letras | `AuraHandledException` — CEP inválido |
| API retorna HTTP 400 | `AuraHandledException` — formato inválido |
| API retorna HTTP 500 | `AuraHandledException` — serviço indisponível |
| Resposta que não é JSON | `AuraHandledException` — resposta inesperada |
| Falha na chamada (timeout simulado) | `AuraHandledException` — falha na consulta |

---

## Segurança

- **Least Privilege:** o acesso à classe Apex é concedido por Permission Set dedicado;
- A classe utiliza `with sharing`;
- Somente o CEP trafega para o serviço externo; nome, CPF, e-mail e demais dados do tutor não são enviados;
- O callout fica restrito ao domínio autorizado no Remote Site Setting;
- Timeout de 10 segundos evita que a interface fique bloqueada por indisponibilidade da API.

---

## Decisões Técnicas

| Decisão | Justificativa |
|---|---|
| Callout realizado no Apex, e não pelo navegador | Evita configuração de CSP Trusted Sites, centraliza validação e tratamento de erros |
| Remote Site Setting em vez de Named Credential | API pública, sem autenticação nem segredos |
| `AuraHandledException` com `setMessage` | Sem `setMessage`, a mensagem original não chega ao LWC nem aos testes |
| `JSON.deserializeUntyped` | Permite tratar o campo `erro` como booleano ou texto, sem depender de uma classe de deserialização rígida |
| Layout de criação lido dinamicamente | Mantém paridade com o formulário padrão e evita duplicar a lista de campos no código |
| Wrapper Aura | Único mecanismo aceito pelo menu de override do botão **New** |
| Identificadores em inglês e comentários em português | Padronização do código-fonte |

---

## Solução de Problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `Unauthorized endpoint` | Remote Site Setting inexistente ou inativo | Implantar `ViaCEP.remoteSite-meta.xml` e conferir se está ativo |
| Lista de override exibe apenas `--None--` | Pasta Aura fora de `aura/appointmentNewOverride/` ou deploy não realizado | Corrigir a estrutura de pastas e implantar novamente |
| Erro de acesso à classe Apex | Permission Set não atribuído | Atribuir `Appointment - Busca de CEP (ViaCEP)` ao usuário |
| Campos não aparecem ou dão erro no formulário | API Names diferentes dos utilizados | Ajustar as constantes `OBJECT_API_NAME` e `FIELD` no `.js` e o `.js-meta.xml` |
| `State__c` não é preenchido | Picklist com valores diferentes da sigla da UF | Padronizar os valores do picklist com as siglas (`PR`, `SP`, ...) |
| `value too long` ao salvar | `CEP__c` com menos de 9 caracteres | Aumentar o tamanho do campo ou definir `FORMAT_ZIP_CODE_WITH_HYPHEN = false` |
| Rua e bairro vazios para um CEP | CEP genérico de cidade pequena | Comportamento esperado; preencher manualmente |

---

## Limitações Conhecidas e Evoluções

- O botão **Save & New** não está disponível no formulário substituído;
- Em objetos com mais de um record type, o formulário utiliza o layout do record type padrão;
- A integração depende da disponibilidade do ViaCEP; em caso de falha, o preenchimento manual continua possível.

**Evoluções possíveis:**

- Migrar para **Named Credential** caso seja adotada uma API que exija autenticação;
- Implementar cache das consultas para reduzir chamadas repetidas;
- Mover o mapeamento de campos para **Custom Metadata**;
- Reutilizar o componente no objeto `PetOwner__c`, que também possui o campo CEP.

---

# Jornada Operacional

```text
Cliente
   ↓
Bot / Recepção
   ↓
Validação de CPF
   ↓
Cadastro ou recuperação
   ↓
Seleção do Pet
   ↓
Data + Horário
   ↓
Tipo de Atendimento
   ↓
Appointment__c
   ↓
Validação Apex
   ↓
┌─────────────────────┐
│ Existe conflito?    │
└──────────┬──────────┘
           │
      Sim  │  Não
       ↓   │   ↓
   addError  Registro criado
               ↓
        Record-Triggered Flow
               ↓
        E-mail ao veterinário
```

---

# Atendimento Digital

O projeto utiliza um agente de atendimento como porta de entrada para operações iniciais da clínica.

O fluxo permite:

1. Validar o CPF;
2. Identificar ou cadastrar o tutor;
3. Cadastrar o pet;
4. Realizar o agendamento;
5. Acionar as automações correspondentes.

Essa camada demonstra integração entre **Agent Service, Flow e modelo de dados Salesforce**.

---

# Lightning App

Foi criada uma aplicação Lightning para organizar a operação da clínica.

### Navegação

- **Pets** — gerenciamento de pacientes;
- **Tutors** — cadastro de responsáveis;
- **Vets** — quadro de veterinários;
- **Appointment** — consultas e agendamentos;
- **Reports** — relatórios;
- **Dashboards** — indicadores gerenciais.

---

# Segurança e Governança

A arquitetura utiliza múltiplas camadas de segurança seguindo o princípio de **Least Privilege**.

## Modelo de acesso

```text
Profile
   ↓
Permission Sets
   ↓
OWD
   ↓
Role Hierarchy
   ↓
Sharing Rules
   ↓
Field-Level Security
   ↓
Dynamic Forms
```

### Profile

Foi utilizado o perfil padrão **Standard Platform User** como configuração inicial, mantendo permissões básicas e delegando acessos específicos aos Permission Sets.

### Permission Set — Recepcionista

Permissões concedidas:

- Criar e editar tutores;
- Criar e editar pets;
- Criar e editar agendamentos;
- Visualizar informações básicas dos veterinários.

Restrições:

- Sem exclusão de registros;
- Sem criação ou edição de veterinários;
- Sem acesso administrativo;
- Sem `View All`;
- Sem `Modify All`.

### Organization-Wide Defaults

O objeto `Vet__c` utiliza **OWD = Private**.

Isso restringe o acesso aos registros por padrão e exige mecanismos adicionais de compartilhamento.

### Role Hierarchy

```text
CEO
│
├── Veterinarian
│
└── Receptionist
```

### Sharing Rules

Foi criada uma regra para compartilhar registros de `Vet__c` com o grupo **Receptionists** em modo:

- **Read Only**

### Field-Level Security

Para a recepção, ficam disponíveis apenas informações necessárias ao processo operacional:

**Visíveis:**
- Vet Name;
- Email.

**Ocultos:**
- CRMV;
- Phone;
- Specialty;
- Available Days;
- Status;
- Campos administrativos.

### Dynamic Forms

Dynamic Forms foram utilizados em conjunto com FLS para adaptar a interface conforme o tipo de usuário.

A página de registro possui seções como:

- **Basic Information**;
- **Administrative Information**.

Para a recepção, a interface é simplificada, exibindo somente os campos necessários.

---

# Relatórios e Dashboards

## Custom Report Type

Foi criado um **Custom Report Type** baseado em `Appointment__c` para suportar a análise operacional.

## Relatórios

### Consultas por Dia
Apresenta o volume diário de consultas.

### Consultas por Mês
Permite acompanhar tendências mensais.

### Consultas por Veterinário
Permite analisar a distribuição de carga de trabalho.

### Tipos de Atendimento por Mês
Permite visualizar a demanda por:

- Consulta;
- Vacinação;
- Cirurgia;
- Outros serviços cadastrados.

## Dashboard Operacional

| Componente | Métrica |
|---|---|
| Metric Chart | Consultas por dia |
| Horizontal Bar Chart | Total de consultas no mês |
| Horizontal Bar Chart | Veterinário com mais consultas |
| Donut Chart | Distribuição por tipo de atendimento |

---

# Stack Tecnológico

| Camada | Tecnologia |
|---|---|
| Plataforma | Salesforce |
| Data Model | Custom Objects & Fields |
| Automação | Flow |
| Backend | Apex |
| Integração | Apex Callout (HTTP/REST) · API pública ViaCEP · Remote Site Setting |
| Query Language | SOQL |
| Trigger | Apex Trigger |
| Architecture Pattern | Trigger Handler |
| Testing | Apex Test Classes |
| Frontend | Lightning Web Components |
| Customização de UI | Action Override (wrapper Aura) |
| UI | Lightning App / Lightning Record Pages |
| Segurança | Profiles, Permission Sets, OWD, Sharing Rules, FLS |
| Interface dinâmica | Dynamic Forms |
| Analytics | Reports & Dashboards |
| Atendimento | Salesforce Enhanced Bot / Agent Service |
| E-mail | Salesforce Automation |

---

# Competências Demonstradas

## Salesforce Administration

- Modelagem de dados;
- Objetos e campos customizados;
- Relacionamentos Lookup;
- Lightning App Builder;
- Profiles;
- Permission Sets;
- OWD;
- Role Hierarchy;
- Sharing Rules;
- Field-Level Security;
- Dynamic Forms;
- Reports;
- Dashboards.

## Salesforce Development

- Apex Triggers;
- Trigger Handler Pattern;
- Apex Classes;
- SOQL;
- `WITH SECURITY_ENFORCED`;
- `addError()`;
- Bulkification;
- Governor Limits;
- Apex Test Classes;
- Cenários positivos e negativos;
- Testes de atualização;
- Testes bulk;
- `@AuraEnabled`;
- `@AuraEnabled(cacheable=true)`;
- Lightning Web Components;
- `@wire`;
- `lightning-datatable`;
- Apex Callouts (HTTP) e integração com API REST externa;
- Remote Site Settings;
- `HttpCalloutMock` e `Test.setMock`;
- Tratamento de exceções com `AuraHandledException`;
- Chamadas Apex imperativas em LWC;
- `lightning-record-edit-form` e `lightning-input-field`;
- `getRecordCreateDefaults` (layout dinâmico);
- Action Override com wrapper Aura (`lightning:actionOverride`).

## Automation

- Record-Triggered Flow;
- Autolaunched Flow;
- Automação de e-mails;
- Validação de dados;
- Automação de agendamento;
- Integração entre Flow e atendimento digital.

## Business Analysis

- Tradução de processos de negócio em solução CRM;
- Modelagem da jornada do cliente;
- Controle de agenda;
- Prevenção de overbooking;
- Automação de comunicação;
- Indicadores operacionais;
- Aplicação de segurança baseada em função.

---

# Resultados Entregues

O Belle VetCare CRM consolidou:

- Cadastro estruturado de tutores e pets;
- Gerenciamento de veterinários;
- Controle centralizado de consultas;
- Prevenção de conflito de agenda;
- Validação de regras de negócio com Apex;
- Testes automatizados;
- Agenda diária em LWC;
- Preenchimento automático de endereço por CEP, com integração à API pública ViaCEP;
- Automação de notificações por e-mail;
- Segurança granular;
- Atendimento digital automatizado;
- Relatórios operacionais;
- Dashboard para tomada de decisão.

---

# Diferenciais Técnicos do Projeto

O projeto demonstra uma evolução arquitetural em camadas:

```text
┌───────────────────────────────────────┐
│          Atendimento Digital          │
│        Agent Service / Bot            │
├───────────────────────────────────────┤
│             Lightning UI              │
│       App + Pages + LWC               │
├───────────────────────────────────────┤
│          Business Automation          │
│              Flow                     │
├───────────────────────────────────────┤
│           Programmatic Logic          │
│        Apex + Trigger Handler         │
├───────────────────────────────────────┤
│              Data Layer               │
│       Objects + Fields + SOQL         │
├───────────────────────────────────────┤
│       Security & Governance           │
│ Profile + Permission Set + OWD + FLS  │
└───────────────────────────────────────┘
```

Essa arquitetura permite demonstrar que a solução não depende exclusivamente de configuração declarativa: **Flow é utilizado para automação, enquanto Apex é aplicado quando uma regra de negócio exige processamento programático**, como a prevenção de conflitos de agenda.

---

# Status do Projeto

**Status:** Completo e funcional  
**Tipo:** Projeto de Portfólio / Case Study  
**Plataforma:** Salesforce Developer Org  
**Escopo:** CRM Customizado  
**Área de Negócio:** Saúde Animal / Clínica Veterinária

---

# Autor

**Thiago de Souza**

Projeto desenvolvido como demonstração prática de competências em **Salesforce Administration e Salesforce Development**, com foco em:

**Apex · LWC · SOQL · Flow · Test Class · Segurança · Automação · Reports & Dashboards**

