# Dashboards & Reports — Belle VetCare CRM

## Visão Geral

Para dar visibilidade à operação da clínica e permitir acompanhamento dos atendimentos, o Belle VetCare CRM incluiu uma camada de análise composta por:

- **Custom Report Type**
- **Relatórios operacionais**
- **Dashboard com indicadores da clínica**

Essa camada foi criada para transformar os dados de agendamento em informações úteis para acompanhamento da rotina da Belle VetCare.

---

# 1. Objetivo da Camada Analítica

A estrutura de relatórios e dashboard foi desenvolvida para permitir o monitoramento de indicadores operacionais da clínica, especialmente relacionados aos agendamentos.

Os objetivos principais foram:

- acompanhar o volume de consultas;
- visualizar a distribuição dos atendimentos ao longo do tempo;
- identificar o volume de consultas por veterinário;
- analisar os tipos de atendimento realizados;
- apoiar a leitura operacional da clínica em um único painel.

---

# 2. Custom Report Type

## Estrutura criada
Foi criado um **Custom Report Type** com base no objeto `Appointment__c`.

## Finalidade
Esse report type foi utilizado como base para estruturar os relatórios e componentes do dashboard, organizando os dados de agendamento que seriam consumidos pela camada analítica.

---

# 3. Relatórios Criados

## 3.1 Consultas por dia

### Objetivo
Visualizar as consultas cadastradas diariamente.

### Uso operacional
Permite acompanhar o comportamento diário dos atendimentos e a movimentação da agenda da clínica.

---

## 3.2 Consultas por mês

### Objetivo
Acompanhar os agendamentos realizados ao longo do mês.

### Uso operacional
Oferece uma visão consolidada do volume mensal de consultas registradas na clínica.

---

## 3.3 Consultas por veterinário

### Objetivo
Visualizar a quantidade de consultas realizadas por veterinário ao longo do mês.

### Uso operacional
Permite acompanhar a distribuição da agenda entre os profissionais da clínica.

---

## 3.4 Tipos de atendimento por mês

### Objetivo
Analisar os tipos de atendimento realizados no mês.

### Uso operacional
Ajuda a identificar quais categorias de atendimento aparecem com maior frequência na operação da clínica.

---

# 4. Dashboard da Belle VetCare

Foi criado um dashboard para consolidar os principais indicadores operacionais da clínica em uma visualização única.

## Objetivo do dashboard
Facilitar a leitura dos dados de atendimento, oferecendo uma visão rápida sobre o comportamento da operação.

---

# 5. Componentes do Dashboard

## 5.1 Line Chart — Quantidade de consultas por dia
Componente utilizado para visualizar a evolução diária das consultas registradas.

## 5.2 Horizontal Bar Chart — Quantidade de consultas no mês
Componente utilizado para destacar o total de consultas realizadas no período mensal.

## 5.3 Horizontal Bar Chart — Veterinário com maior número de consultas
Componente utilizado para comparar o volume de atendimentos entre os profissionais.

## 5.4 Donut Chart — Tipos de atendimento realizados no mês
Componente utilizado para visualizar a distribuição dos tipos de atendimento realizados na clínica.

---

# 6. Papel da Camada de Analytics no Projeto

A camada de relatórios e dashboard complementa a operação do CRM ao transformar os registros da clínica em indicadores visuais.

Essa estrutura permite que a solução não se limite ao cadastro e automação, mas também ofereça suporte à análise operacional da Belle VetCare.

---

# 7. Competências Demonstradas

A construção da camada analítica do projeto demonstra competências importantes de Salesforce Administrator, incluindo:

- criação de **Custom Report Types**;
- construção de relatórios operacionais;
- organização de métricas de atendimento;
- montagem de dashboard com diferentes visualizações;
- uso de analytics para leitura da operação da clínica.

---

# 8. Resultado da Camada Analítica

Com a implementação dos relatórios e do dashboard, o Belle VetCare CRM passa a oferecer uma visão mais completa da operação, permitindo acompanhar:

- volume de consultas;
- distribuição dos atendimentos ao longo do tempo;
- carga de atendimento por veterinário;
- perfil dos tipos de atendimento realizados.

Essa camada reforça o projeto como uma solução de CRM funcional, com foco não apenas em execução operacional, mas também em monitoramento e tomada de decisão.