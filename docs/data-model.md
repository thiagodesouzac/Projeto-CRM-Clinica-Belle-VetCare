# Data Model — Belle VetCare CRM

## Visão Geral da Modelagem

A modelagem de dados do Belle VetCare CRM foi criada para representar a operação de uma clínica veterinária dentro do Salesforce de forma estruturada, organizada e escalável.

A solução foi construída com base em quatro objetos principais:

- `Tutor__c`
- `Pet__c`
- `Vet__c`
- `Appointment__c`

Esses objetos sustentam os principais processos do CRM:

- cadastro de tutores;
- cadastro de pets;
- gestão de veterinários;
- agendamento de consultas;
- relacionamento entre cliente, animal, profissional e atendimento.

---

# Objetos do Projeto

## 1. Pet_Owner__c

### Objetivo
Armazenar os dados dos responsáveis pelos pets atendidos pela clínica.

O objeto `Pet_Owner__c` concentra as informações cadastrais do cliente e serve como base para a jornada de atendimento, validação de CPF e relacionamento com os pets.

### Campos criados

| Campo | Tipo |
|---|---|
| Name | Text |
| CPF | Text com fórmula de validação |
| Address | Text || 
| Phone | Phone |
| Email | Email |
| CEP | Text com fórmula de validação |
| Quantity Pet | Number |
| Pet | Lookup Relationship |

### Papel no processo
O tutor é o ponto de entrada do relacionamento com a clínica. Seu cadastro é utilizado tanto no fluxo operacional da recepção quanto na jornada automatizada do bot.

---

## 2. Pet__c

### Objetivo
Armazenar as informações clínicas e cadastrais dos animais atendidos pela clínica.

O objeto `Pet__c` foi criado para registrar os dados do animal e manter seu vínculo com o tutor e, quando aplicável, com o veterinário.

### Campos criados

| Campo | Tipo |
|---|---|
| Age | Number |
| Breed | Text |
| Name | Text |
| Species | Text |
| Sex | Text |
| Weight | Number |
| Pet Owner | Lookup Relationship |
| Vet | Lookup Relationship |

### Papel no processo
O pet representa o paciente da clínica. Ele é vinculado ao tutor e pode ser associado a um veterinário, servindo como base para os agendamentos e histórico operacional da clínica.

---

## 3. Vet__c

### Objetivo
Gerenciar os profissionais veterinários da clínica.

O objeto `Vet__c` concentra os dados dos veterinários, permitindo o controle de especialidade, disponibilidade e status operacional.

### Campos criados

| Campo | Tipo |
|---|---|
| Name | Text |
| Phone | Phone |
| Pet | Lookup Relationship |
| Email | Email |
| Specialty | Picklist |
| CRMV | Text |
| Available Days | Picklist |
| Status | Picklist |

### Papel no processo
O veterinário é o profissional relacionado aos atendimentos da clínica. Seus dados são utilizados na operação de agendamento e nas automações de comunicação.

---

## 4. Appointment__c

### Objetivo
Registrar os agendamentos da clínica.

O objeto `Appointment__c` centraliza os dados de atendimento, conectando o tutor, o pet, a data, a hora e o tipo de atendimento.

### Campos criados

| Campo | Tipo |
|---|---|
| Date | Date |
| Time | Time |
| Service Type | Picklist |
| Species | Picklist |
| Pet | Lookup Relationship |
| Tutor | Lookup Relationship |

### Papel no processo

O agendamento representa o evento operacional mais importante da jornada da clínica. É a partir dele que a recepção organiza os atendimentos, o veterinário é acionado e os relatórios operacionais são alimentados.

---

# Relacionamentos do Projeto

## Relacionamento entre Tutor__c e Pet__c
O relacionamento principal da solução foi modelado por meio do campo **Tutor** no objeto `Pet__c`, permitindo vincular cada pet ao seu responsável.

### Regra funcional
- um tutor pode estar relacionado a um ou mais pets;
- cada pet precisa estar associado ao seu responsável no processo da clínica.

---

## Relacionamento entre Pet__c e Vet__c
O objeto `Pet__c` pode ser relacionado a um veterinário por meio do campo Vet.

### Regra funcional
Esse relacionamento permite associar o animal a um profissional da clínica dentro da estrutura adotada no projeto.

---

## Relacionamento entre Appointment__c, Tutor__c e Pet__c
O objeto `Appointment__c` foi desenhado para conectar o agendamento ao tutor e ao pet.

### Regra funcional
Esse vínculo garante rastreabilidade do atendimento e permite que o agendamento seja analisado dentro da jornada operacional da clínica.

---

# Estrutura Funcional da Modelagem

A modelagem foi criada para sustentar diretamente os principais processos do CRM:

## Cadastro do tutor
O tutor é registrado com seus dados cadastrais e passa a fazer parte da base da clínica.

## Cadastro do pet
O pet é cadastrado com suas informações clínicas e associado ao tutor.

## Gestão de profissionais veterinários
Os veterinários são cadastrados com seus dados profissionais, especialidade e disponibilidade.

## Agendamento de consultas
O atendimento é registrado no objeto `Appointment__c`, vinculando tutor, pet e dados da consulta.

---

# Visão Arquitetural da Modelagem

A estrutura de dados do Belle VetCare CRM foi desenhada para conectar os principais elementos da operação da clínica dentro do Salesforce:

- **Tutor** → responsável pelo atendimento;
- **Pet** → paciente da clínica;
- **Vet** → profissional responsável pelo cuidado;
- **Appointment** → registro do atendimento agendado.

Essa modelagem organiza a operação de ponta a ponta e cria uma base sólida para automações, segurança, analytics e atendimento digital via bot.