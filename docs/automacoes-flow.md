# Automações com Flow — Belle VetCare CRM

## Visão Geral

O Belle VetCare CRM utiliza **Salesforce Flow** para automatizar processos operacionais da clínica, reduzindo trabalho manual e melhorando a comunicação com os profissionais envolvidos no atendimento.

As automações do projeto foram estruturadas em duas frentes:

- **automações operacionais da clínica**, relacionadas ao agendamento e à comunicação com veterinários;
- **automações do bot**, responsáveis pelo cadastro, validação e agendamento na jornada digital do cliente.

---

# 1. Flows Operacionais da Clínica

## 1.1 Flow Vet Appointment Alert

### Tipo
**Record-Triggered Flow**

### Objetivo
Notificar automaticamente o veterinário responsável quando um novo agendamento é criado no objeto `Appointment__c`.

### Cenário de uso
Quando a recepção agenda uma consulta, o sistema deve comunicar o veterinário com os dados do atendimento, sem necessidade de envio manual.

### Lógica do flow
1. Um registro é criado em `Appointment__c`;
2. O flow é disparado automaticamente;
3. Uma decisão valida se existe veterinário relacionado ao agendamento;
4. Se existir veterinário vinculado, o flow executa a ação de envio de e-mail;
5. O veterinário recebe a notificação com os dados da consulta.

### Informações enviadas no e-mail
- dados da consulta;
- nome do pet;
- nome do tutor;
- tipo de atendimento;
- data;
- hora.

### Resultado funcional
Essa automação reduz dependência de comunicação manual e melhora a visibilidade do profissional sobre os atendimentos agendados.

---

## 1.2 Flow Vet Cancellation Alert

### Tipo
**Record-Triggered Flow**

### Objetivo
Notificar automaticamente o veterinário responsável quando uma consulta é cancelada.

### Cenário de uso
Se um atendimento for cancelado, o profissional precisa ser informado para evitar inconsistências operacionais na agenda.

### Lógica do flow
1. Uma consulta é cancelada no objeto `Appointment__c`;
2. O flow é disparado;
3. Uma decisão valida se existe veterinário vinculado ao atendimento;
4. A ação de envio de e-mail é executada;
5. O veterinário recebe a notificação de cancelamento.

### Resultado funcional
A automação melhora a comunicação da clínica e reduz risco de falhas operacionais relacionadas à agenda médica.

---

# 2. Flows do Einstein Bot

Além dos flows operacionais da clínica, o projeto utiliza **Autolaunched Flows** para sustentar a jornada do atendimento digital via bot.

---

## 2.1 Flow Bot Register PetOwner Pet

### Tipo
**Autolaunched Flow**

### Objetivo
Criar o cadastro do tutor diretamente pela jornada do bot.

### Campos utilizados
- Nome
- CPF
- Email
- Telefone
- Endereço
- CEP
- Nome do pet
- Espécie do pet

### Papel na jornada
Esse flow permite que o usuário realize o cadastro do responsável pelo pet sem depender de atendimento manual da recepção.

---

## 2.2 Flow Bot Validate PetOwner CPF

### Tipo
**Autolaunched Flow**

### Objetivo
Busca e verifica o CPF se o tutor existe na jornada do bot.

### Campos utilizados
- Número do CPF

### Papel na jornada
Esse flow apenas faz a verificação se o tutor existe no sistema pelo número do CPF.

---

## 2.3 Flow Bot Schedule Appointment

### Tipo
**Autolaunched Flow**

### Objetivo
Realizar o agendamento do atendimento por meio do bot, validando previamente os dados do tutor e do pet.

### Estrutura do flow
- captura do CPF para verificação;
- busca do tutor por CPF;
- captura do nome do pet;
- captura da espécie;
- captura do tipo de atendimento;
- captura da data do atendimento;
- captura da hora do atendimento.

### Papel na jornada
Esse flow executa a parte central da jornada digital, permitindo que o cliente conclua o agendamento de forma automatizada.

---

# 3. Papel das Automações na Solução

As automações do Belle VetCare CRM cumprem funções diferentes dentro do projeto:

## Automação operacional
Responsável por notificar profissionais e reduzir tarefas manuais da clínica.

## Automação de atendimento digital
Responsável por conduzir o cliente na jornada de cadastro, validação e agendamento.

## Automação de consistência do processo
Responsável por garantir que a regra de negócio seja respeitada, como a exigência de cadastro prévio do tutor antes do agendamento.

---

# 4. Competências Demonstradas com Flow

A camada de automação do projeto evidencia domínio de recursos importantes da plataforma Salesforce, incluindo:

- desenho de lógica de negócio com Flow;
- implementação de **Record-Triggered Flows**;
- construção de **Autolaunched Flows**;
- uso de decisões para controle da jornada;
- automação de comunicação operacional;
- suporte à jornada digital do cliente via bot.

---

# 5. Resultado da Camada de Automação

A estrutura de automações do Belle VetCare CRM conecta a operação da clínica com a experiência digital do cliente, garantindo:

- maior organização do processo de agendamento;
- comunicação automatizada com veterinários;
- cadastro guiado pelo bot;
- validação de tutor por CPF;
- agendamento automatizado;
- integração entre atendimento digital e operação interna da clínica.