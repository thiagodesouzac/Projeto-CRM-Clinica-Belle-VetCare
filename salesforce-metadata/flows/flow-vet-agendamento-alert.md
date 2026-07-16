# Documentação — Vet Appointment Flow (V14)

## 1. Propósito
O flow tem como objetivo notificar automaticamente o veterinário responsável por e-mail sempre que uma nova consulta (Appointment) for agendada no sistema, informando os dados do pet, do tutor, a data e o horário do atendimento.

## 2. Tipo de Flow
- **Tipo:** Record-Triggered Flow (Flow Autolançado, disparado por registro)
- **Objeto:** Appointment
- **Gatilho (Trigger):** A record is created (quando um registro é criado)
- **Otimização:** Actions and Related Records
- **Execução:** Run Immediately (execução síncrona, imediata)

## 3. Estrutura do Flow
O flow segue uma sequência linear simples:

1. **Start** — Disparado na criação de um registro de Appointment
2. **Get Vet** (Get Records) — Busca o registro do veterinário vinculado à consulta
3. **Send Vet Email** (Action) — Envia e-mail ao veterinário com os detalhes da consulta
4. **End** — Encerramento do flow

Não há elementos de decisão (Decision), loops ou caminhos agendados (Scheduled Paths) configurados.

## 4. Variáveis de Entrada
- **$Record** (registro de Appointment que disparou o flow), contendo:
  - `Vet__c` — utilizado como filtro no elemento *Get Vet* (Record ID igual a Appointment__c > Vet)
  - `Pet__r.Name` — nome do pet
  - `PetOwners__r.Name` — nome do tutor
  - `Date__c` — data da consulta
  - `Time__c` — horário da consulta

## 5. Variáveis de Saída
- **Get Vet** (registro do veterinário):
  - Armazena apenas o primeiro registro encontrado (Only the first record)
  - Todos os campos são armazenados automaticamente (Automatically store all fields)
  - Utilizado posteriormente para obter o **Nome** e o **E-mail** do veterinário
- O flow não produz variáveis de saída para uso externo; o resultado final é o envio do e-mail.

## 6. Lógica de Negócio
1. Ao criar um novo Appointment, o flow é disparado imediatamente.
2. O elemento **Get Vet** busca o registro do veterinário cujo ID corresponde ao campo de lookup do Appointment (`Vet__c`), retornando apenas o primeiro registro (sem ordenação definida).
3. O elemento **Send Vet Email** monta e envia um e-mail para o endereço do veterinário obtido na etapa anterior, com:
   - **Assunto:** "Consulta agendada"
   - **Corpo:** saudação personalizada com o nome do veterinário, seguida dos dados do pet, tutor, data e hora da consulta, finalizando com a assinatura da "Clínica Belle VetCare".
4. O flow é encerrado após o envio do e-mail.

## 7. Casos de Uso
- Notificação automática do veterinário no momento em que uma nova consulta é registrada no Salesforce, evitando a comunicação manual.
- Garantia de que o profissional responsável tenha, de forma rápida e padronizada, todas as informações essenciais da consulta (pet, tutor, data e horário).
- Redução de falhas de comunicação e retrabalho administrativo na clínica veterinária.

## 8. Resumo
O **Vet Appointment Flow** é um flow autolançado e síncrono, disparado na criação de registros de Appointment, que busca o veterinário vinculado à consulta e envia automaticamente um e-mail de notificação com os detalhes do agendamento. Sua estrutura é simples e linear (Start → Get Vet → Send Vet Email → End), sem lógica condicional, focado exclusivamente em automatizar a comunicação inicial entre o sistema e o veterinário responsável.
