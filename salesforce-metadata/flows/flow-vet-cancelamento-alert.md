# Vet Cancellation Alert - V3

## 1. Propósito

O Flow tem como objetivo notificar automaticamente o veterinário responsável quando um agendamento (Appointment) é cancelado, enviando um alerta por e-mail. O Flow é disparado sempre que um registro de Appointment é atualizado, verifica se há um veterinário vinculado ao agendamento e, em caso positivo, dispara o envio do e-mail de cancelamento.

## 2. Tipo de Flow

- **Categoria:** Record-Triggered Flow (Flow disparado por registro)
- **Objeto:** Appointment
- **Gatilho (Trigger):** A record is updated (quando um registro é atualizado)
- **Condições de entrada:** 1 condição configurada
- **Otimizado para:** Actions and Related Records
- **Modo de execução:** Run Immediately (execução imediata, síncrona)
- **Status:** Active

## 3. Estrutura do Flow

```
Início (Record-Triggered: Appointment atualizado)
        │
        ▼
   Run Immediately
        │
        ▼
  Decision: "Do Vet exist"
        │
   ┌────┴─────┐
   │          │
Vet Found   Vet Not Found
   │          │
   ▼          ▼
Cancellation   End
Alert (Email)
   │
   ▼
  End
```

**Elementos do Flow:**
1. **Start** – Record-Triggered Flow no objeto Appointment.
2. **Decision "Do Vet exist"** – elemento de decisão com dois desfechos: *Vet Found* e *Vet Not Found*.
3. **Action "Cancellation Alert"** – Email Alert (nome da API: `Cancellation_Alert`) disparado apenas no caminho *Vet Found*.
4. **End** – elementos de encerramento em ambos os caminhos (com e sem veterinário encontrado).

## 4. Variáveis de Entrada

| Campo/Recurso | Origem | Descrição |
|---|---|---|
| `Appointment__c > Vet > Vet Name` | Registro disparador (Appointment) | Utilizado na condição da Decision para verificar se existe um veterinário vinculado ao agendamento |
| `Triggering Appointment__c > Record ID` | Registro disparador (Appointment) | ID do registro de Appointment, usado como input para o Email Alert |

## 5. Variáveis de Saída / Lógica de Negócio

**Decision: "Do Vet exist"**
- **Outcome "Vet Found"**
  - Condição: `Vet Name` **Is Null** = **False** (ou seja, o campo Vet Name **não está nulo**)
  - Regra de execução: Todas as condições devem ser atendidas (AND)
  - Quando executar: Se os requisitos da condição forem atendidos
- **Outcome "Vet Not Found"** (caminho padrão/else)
  - Executado quando a condição de "Vet Found" não é satisfeita (Vet Name está nulo)

**Ação "Cancellation Alert" (Email Alert – "Vet Appointment Canceled")**
- Nome da API: `Cancellation_Alert`
- Input obrigatório: **Record ID** = ID do Appointment que disparou o Flow
- Saída: Envio de e-mail de notificação de cancelamento (não armazena valores de retorno em variáveis)

## 6. Casos de Uso

1. **Cancelamento de agendamento com veterinário associado:** Quando um Appointment é atualizado e possui um veterinário vinculado (Vet Name preenchido), o Flow envia automaticamente um e-mail de alerta de cancelamento para o veterinário responsável.
2. **Cancelamento de agendamento sem veterinário associado:** Quando o Appointment atualizado não possui veterinário vinculado (Vet Name nulo), o Flow simplesmente encerra sem enviar nenhum e-mail, evitando notificações inválidas ou erros de envio.

## 7. Resumo

O Flow **"Vet Cancellation Alert - V3"** é um Record-Triggered Flow ativo no objeto Appointment, disparado sempre que um agendamento é atualizado. Sua lógica central consiste em uma verificação condicional (Decision "Do Vet exist") que checa se existe um veterinário associado ao agendamento. Caso exista, um Email Alert ("Cancellation_Alert") é disparado, enviando a notificação "Vet Appointment Canceled" com base no ID do registro do Appointment. Caso não exista veterinário vinculado, o Flow é encerrado sem nenhuma ação adicional. Trata-se, portanto, de uma automação simples e objetiva voltada para garantir que veterinários sejam avisados sobre cancelamentos de consultas/agendamentos.
