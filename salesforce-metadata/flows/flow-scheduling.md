# Documentação Técnica: 

## Flow_Scheduling

Esta documentação detalha a arquitetura, lógica e integração do fluxo automatizado desenvolvido no Salesforce para a clínica **Belle VetCare**. O fluxo opera em conjunto com o **Agentforce** para simplificar e automatizar o processo de marcação de consultas e exames de forma autônoma e livre de erros.

---

## 1. Visão Geral do Fluxo

O `Flow_Scheduling` é um **Autolaunched Flow** projetado para funcionar como uma API interna (Action) para o Agentforce. 

### Objetivos Principais:
* **Automação Inteligente**: O agente de IA coleta os dados essenciais com o tutor no chat e delega a execução e a validação lógica para o Flow.
* **Redução de Fricção**: Elimina a necessidade de o atendente virtual ou usuário buscarem ou escolherem manualmente um veterinário disponível.
* **Segurança de Dados**: Realiza validações críticas de banco de dados (existência de CPF e vínculo do Pet) antes de persistir qualquer agendamento.

---

## 2. Interface de Entrada e Saída (Contrato da Ação)

O Agentforce interage com o fluxo exclusivamente através de parâmetros definidos.

### Variáveis de Entrada (Input)
* **`Input_CPF`** *(Text)*: O número de CPF fornecido pelo tutor no chat para validação de identidade.
* **`Input_Nome_Pet`** *(Text)*: O nome do paciente (animal de estimação) a ser atendido.
* **`Input_Date`** *(Date)*: A data escolhida para a consulta/exame.
* **`Input_Time`** *(Time)*: O horário pretendido enviado pela IA em formato ISO (ex: `16:00`).
* **`Input_Service_Type`** *(Text)*: O tipo de procedimento (ex: Vacinação, Exames, Consulta Geral).

### Variáveis de Saída (Output)
* **`Output_Reference`** *(Text)*: Código único e sequencial (`appointment__c`) gerado automaticamente pelo Salesforce após o sucesso da operação.

---

## ⚙️ 3. Arquitetura do Canvas e Passo a Passo Lógico

O fluxo executa uma sequência linear de validações e cruzamento de dados estruturada da seguinte forma:

```
[Início] ──► [Get_Pet_Owner] ──► [Decision: Encontrado?]
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   ▼ (Não)                                     ▼ (Sim)
             [Fim / Erro]                                [Get_Pet]
                                                               │
                                                               ▼
                                                         [Get_Vet (Ativo)]
                                                               │
                                                               ▼
                                                      [Create_Scheduling]
                                                               │
                                                               ▼
                                                    [Recuperar_Agendamento]
                                                               │
                                                               ▼
                                                      [Fórmula_Hora & Output]
                                                               │
                                                               ▼
                                                             [Fim]
```

### Detalhamento dos Elementos:

1. **`Get_Pet_Owner` (Obter Registro)**: 
   Busca no objeto de clientes um registro onde o campo `CPF__c` seja estritamente igual ao `Input_CPF`.
2. **`Pet Owner Found?` (Decisão)**: 
   Avalia se o passo anterior retornou um ID válido. Se o resultado for nulo, o fluxo é interrompido imediatamente para que o Agentforce exiba a mensagem de obrigatoriedade de cadastro prévio.
3. **`Get_Pet` (Obter Registro)**: 
   Busca no objeto `Pet__c` um registro que atenda cumulativamente a duas condições: o campo de relacionamento `PetOwners__c` deve ser igual ao ID encontrado no passo 1, e o nome do Pet deve ser igual ao `Input_Pet_Name`.
4. **`Get_Vet` (Obter Registro)**: 
   Seleciona de forma 100% automatizada no banco de dados o primeiro registro do objeto de profissionais (`Vet__c`) que possua o campo `Status__c` igual a **"Ativo"**. Recupera seu ID, Nome e E-mail de trabalho.
5. **`Create_Scheduling` (Criar Registro)**: 
   Insere um novo registro no objeto customizado `Appointment__c` mapeando os IDs de relacionamento encontrados (Dono, Pet, Veterinário), os dados fornecidos pelo Agentforce (Data e Tipo de Serviço) e força o status inicial para **"Agendado"**.
6. **Atribuição do Output (`Assignment`)**:
   O fluxo lê o campo AutoNumber `appointment__c` gerado nativamente pelo sistema no momento da criação do registro e injeta esse valor na variável `Output_Reference`.

---

## 4. Instruções de Raciocínio para o Agentforce (Reasoning)

Para que o agente de inteligência artificial consuma este fluxo corretamente no **Agent Studio**, a seguinte diretriz deve estar ativa:

* **Etapa 1**: O agente é instruído a colher o CPF primeiro e disparar a validação. Se o retorno indicar ausência de cadastro, o processo de agendamento é bloqueado na hora.
* **Etapa 2**: Se validado, a IA colhe o nome do pet, data/hora e tipo de atendimento. Ela é expressamente proibida de perguntar pelo nome do veterinário, agindo sob a premissa de que a escolha é automatizada pelo sistema.
* **Etapa 3**: Na conclusão, a IA lê o código de retorno e monta um resumo claro e estruturado para o cliente no chat.

---

## 5. Requisitos de Segurança e Permissões

Para o perfeito funcionamento do ecossistema, o usuário de execução da IA (**Belle Assistant** / Perfil Einstein Agent User) necessita obrigatoriamente de permissões de **Leitura (Read)** e **Criação (Create)** gerenciadas via Permission Set (`Permission_Belle_Object_Agentforce`) nos seguintes sObjects:
* `Pet_Owner__c`
* `Pet__c`
* `Vet__c`
* `Appointment__c`

---
