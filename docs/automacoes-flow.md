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

# 2. Flows do Agent Service

Além dos flows operacionais da clínica, o projeto utiliza **Autolaunched Flows** para sustentar a jornada do atendimento digital via bot.

---

## 2.1 Flow Register Owner and Pet

### Tipo
**Autolaunched Flow**

### Objetivo
Criar o cadastro do tutor diretamente pela jornada do agent.

### Campos utilizados
- Nome
- CPF
- Email
- Telefone
- Endereço
- CEP
- Nome do pet
- Espécie do pet
- Raça
- Gênero

### Papel na jornada
Esse flow permite que o usuário realize o cadastro do responsável pelo pet sem depender de atendimento manual da recepção.

---

## 2.2 Flow Validate PetOwner

### Tipo
**Autolaunched Flow**

### Objetivo
Busca e verifica o CPF se o tutor existe na jornada do agent.

### Campos utilizados
- Número do CPF

### Papel na jornada
Esse flow apenas faz a verificação se o tutor existe no sistema pelo número do CPF.

---

## 2.3 Flow Scheduling

### Tipo
**Autolaunched Flow**

### Objetivo
O Flow Schedule Appointment é responsável por realizar o agendamento completo de consultas veterinárias na Clínica Belle VetCare.

Este Flow centraliza toda a lógica de negócio necessária para criar um agendamento, desde a identificação do tutor até a geração da consulta, garantindo que apenas tutores e pets cadastrados possam realizar um agendamento.

### Estrutura do flow

O Flow é responsável por:

- Identificar o tutor a partir do CPF informado.
- Verificar se o tutor possui cadastro ativo.
- Localizar o pet informado pelo usuário.
- Confirmar que o pet pertence ao tutor identificado.
- Criar o registro da consulta veterinária.
- Definir automaticamente o status inicial da consulta.
- Gerar o código de referência do agendamento.
- Retornar o resultado da operação para o agente.

### Papel na jornada
Esse flow executa a parte central da jornada digital, permitindo que o cliente conclua o agendamento de forma automatizada.

---

## 2.4 Flow Cancel Appointment

### Tipo
**Autolaunched Flow**

### Objetivo
O Flow Cancel Appointment é responsável por localizar e cancelar consultas veterinárias previamente agendadas na Clínica Belle VetCare.

O Flow garante que apenas a consulta correta seja cancelada por meio da validação das informações fornecidas pelo usuário, proporcionando maior segurança durante o processo.

### Estrutura do flow

O Flow é responsável por:

- Localizar o agendamento utilizando o código de referência.
- Confirmar que os dados informados correspondem à consulta cadastrada.
- Validar as informações do pet e da consulta.
- Atualizar o status do agendamento para cancelado.
- Retornar o resultado da operação ao agente.

### Papel na jornada
Esse flow executa a parte central da jornada digital, permitindo que o cliente conclua o cancelamento de forma automatizada.

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