# Flow: Route to Belle Chat

## 1. Propósito

O flow tem como objetivo direcionar (rotear) o atendimento de mensagens recebidas via Omni-Channel para o bot avançado **Belle Chat**, garantindo que as interações de mensagens sejam tratadas automaticamente por esse bot no momento em que o trabalho entra na fila.

## 2. Tipo de Flow

- **Omni-Channel Flow** (Flow do tipo "Start" com evento de disparo Omni-Channel).
- Utilizado como flow de roteamento de trabalho (Routing Flow), acionado quando um novo item de trabalho é criado no Omni-Channel.

## 3. Estrutura do Flow

O flow é composto por três elementos sequenciais:

1. **Start (Omni-Channel Flow)** – ponto de entrada do flow.

2. **Route to Belle Chat (Route Work)** – elemento central responsável pela lógica de roteamento.
   - Label: `Route to Belle Chat`
   - API Name: `RoutingAction`
   - Descrição: "Routes all messages to your enhanced bot."

3. **End** – encerramento do flow.

## 4. Variáveis de Entrada

Definidas no elemento **Route to Belle Chat**:

| Campo | Valor                            |
|-------|----------------------------------|
| How Many Work Records to Route? | Single |
| Record ID Variable | `{!recordId}` |
| Service Channel | Messaging |
| Route To | Queue |
| Enhanced Bot | Belle VetCare Queue |

## 5. Variáveis de Saída

O elemento **Route Work** não expõe variáveis de saída explícitas visíveis na configuração — sua função é executar a ação de roteamento do item de trabalho para o bot definido, não retornar dados para uso posterior no flow.

## 6. Lógica de Negócio

- O flow recebe um registro de trabalho (via `recordId`) do canal de **Messaging**.

- Roteia esse único registro (`Single`) diretamente para o **Enhanced Bot "Belle Chat"**, responsável por conduzir a conversa automatizada.

- O roteamento feito com **Queue** utilizando a configuração de fila "5".

## 7. Casos de Uso

- Atendimento automatizado de mensagens recebidas via canais de Messaging (ex.: WhatsApp, chat, SMS) direcionadas ao bot Belle Chat.

- Cenários em que a empresa deseja que o primeiro contato do cliente seja tratado por um bot avançado antes de, eventualmente, escalar para um agente humano (via fila de fallback).

## 9. Resumo

O flow **"Route to Belle Chat - V1"** é um flow de roteamento Omni-Channel simples e direto, com apenas três etapas (Start → Route Work → End). 

Sua função é enviar mensagens recebidas pelo canal de Messaging para o bot **Belle Chat**. 

O flow está **ativo**, mas possui uma pendência importante: o **Fallback Queue ID** ainda não foi configurado (mantém o valor padrão `[REPLACE ME]`), o que pode comprometer o atendimento em casos de falha no roteamento para o bot.
