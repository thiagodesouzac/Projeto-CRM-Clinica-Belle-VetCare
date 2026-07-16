# Flow: Schedule Appointment

## 1. Propósito

Automatizar o agendamento de consultas/atendimentos para pets, validando previamente se o tutor (owner) e o pet existem no sistema e se o horário solicitado está disponível, antes de criar o registro de Appointment (Agendamento).

## 2. Tipo de Flow

**Autolaunched Flow** (Flow autoiniciado), projetado para ser invocado por outro processo, componente ou integração (ex.: um bot/agente), recebendo parâmetros de entrada e retornando variáveis de saída.

## 3. Estrutura do Flow

O flow segue uma sequência de validações em cascata, cada uma com um ponto de decisão que pode encerrar o processo antecipadamente em caso de erro:

1. **Start** → Início do flow autoiniciado.

2. **Find Pet Owner** (Get Records) → Busca o tutor na tabela PetOwner filtrando por 
`CPF = inCPF` (apenas o primeiro registro).

3. **Pet Owner Found?** (Decision) → Verifica se o tutor foi encontrado (Record ID não nulo).

   - **Not Found** → **PetOwner Not Found** (Assignment): limpa o Record ID (valor vazio).

4. **Find Pet** (Get Records) → Busca o pet na tabela Pet filtrando por `Pet Name = inPetName` E `PetOwner = Record ID do tutor encontrado`.

5. **Pet Found?** (Decision) → Verifica se o pet foi encontrado.

   - **Pet Not Found** → **Pet Not Found** (Assignment): define `outSuccess = False` e 
   `outMensagem = "Pet não localizado para este tutor."` → **End**.

6. **Find Time** (Get Records) → Busca registros de Appointment filtrando por `Date = inDate` E 
`Time = inTime`, para checar conflito de horário.

7. **Available Time?** (Decision) → Verifica se não existe agendamento no horário (registro nulo = disponível).

   - **Busy schedule** → **Busy** (Assignment): define `outSuccess = False` e `outMensagem = "Este horário já está reservado. Escolha outro horário."`.

8. **Create Appointment** (Create Records) → Cria um novo registro de Appointment com os campos:

   - `CPF Tutor` = inCPF
   - `Date` = inDate
   - `PetOwner` = ID do tutor (via Pet > PetOwner)
   - `Pet` = ID do pet encontrado
   - `Service Type` = inServiceType
   - `Status` = "Agendado"
   - `Time` = inTime
   - Este elemento possui um caminho de **Fault** (erro).

9. **Success Return** (Assignment) → Em caso de sucesso: `outSuccess = True`, 
`outMensagem = "Consulta agendada com sucesso!"`, 
`botAppointmentId` = Record ID do agendamento criado.

10. **Error Appointment** (Assignment, caminho de Fault) → Em caso de falha na criação: 
`outSuccess = False`, `outMensagem = "Não foi possível concluir o agendamento."`

11. **End** → Encerramento do flow em todos os caminhos.

## 4. Variáveis de Entrada

| Variável| Descrição |
|---------|------------------------------------------------|
| `inCPF` | CPF do tutor (usado para localizar o PetOwner) |
| `inPetName` | Nome do pet a ser localizado |
| `inDate` | Data desejada para o agendamento |
| `inTime` | Horário desejado para o agendamento |
| `inServiceType` | Tipo de serviço/atendimento solicitado |

## 5. Variáveis de Saída

| Variável | Descrição |
|----------|-------------------------------------------------------------------|
| `outSuccess` | Booleano indicando se o agendamento foi concluído com sucesso |
| `outMensagem` | Mensagem de retorno (sucesso ou motivo da falha) |
| `botAppointmentId` | Record ID do agendamento criado (preenchido apenas em caso de sucesso) |

## 6. Lógica de Negócio

O flow implementa uma validação sequencial em três etapas antes de efetivar o agendamento:

1. **Existência do Tutor**: sem tutor cadastrado com o CPF informado, o fluxo segue adiante mas a busca de pet falhará (Record ID vazio), levando à mensagem de "pet não localizado".

2. **Existência do Pet**: o pet deve pertencer ao tutor identificado; caso contrário, o processo é interrompido com mensagem específica.

3. **Disponibilidade de Horário**: verifica se já existe um agendamento para a mesma Data/Hora; se houver, o processo é interrompido informando que o horário está ocupado.

4. **Criação do Agendamento**: somente após passar pelas três validações, o registro de Appointment é criado com status "Agendado". Caso ocorra erro técnico na criação (Fault), uma mensagem de erro genérica é retornada.

Em todos os caminhos de falha, o flow segue para o elemento **End**, retornando `outSuccess = False` e uma mensagem explicativa, permitindo que o sistema/bot que invocou o flow trate o retorno adequadamente.

## 7. Casos de Uso

- Um bot/assistente virtual de atendimento veterinário recebe do cliente o CPF, nome do pet, data, hora e tipo de serviço, e aciona este flow para tentar agendar a consulta automaticamente.
- Validação automática de conflitos de agenda antes de confirmar um horário para o cliente.
- Impedir agendamentos para pets/tutores não cadastrados no sistema, orientando o usuário a realizar cadastro prévio.

## 9. Resumo

O flow **Schedule Appointment** é um processo autoiniciado que orquestra o agendamento de consultas para pets. Ele valida, em sequência, a existência do tutor (por CPF), a existência do pet vinculado a esse tutor e a disponibilidade do horário solicitado. 

Somente quando todas as validações são bem-sucedidas, um novo registro de Appointment é criado com status "Agendado". 

O flow retorna sempre três variáveis de saída (`outSuccess`, `outMensagem` e, em caso de sucesso, `botAppointmentId`), garantindo que o sistema chamador saiba exatamente o resultado da operação e, quando aplicável, o identificador do agendamento criado.
