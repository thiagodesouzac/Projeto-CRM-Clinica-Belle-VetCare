# Security Model — Belle VetCare CRM

## Visão Geral

O modelo de segurança do **Belle VetCare CRM** foi projetado seguindo o princípio de **Least Privilege (Menor Privilégio)**, garantindo que cada usuário tenha acesso apenas aos recursos necessários para executar suas atividades.

A arquitetura foi baseada nas recomendações da Salesforce, utilizando **Permission Sets**, **Permission Set Groups**, **Assigned Apps** e **Field-Level Security (FLS)**. Essa abordagem torna a solução mais escalável, reutilizável e de fácil manutenção, evitando a criação de múltiplos perfis personalizados.

---

# 1. Objetivo do Modelo de Segurança

A estratégia de segurança foi desenvolvida para:

* controlar o acesso às funcionalidades da aplicação;
* proteger informações sensíveis;
* organizar permissões por função de negócio;
* facilitar manutenção e auditorias;
* permitir o crescimento da solução sem necessidade de novos Profiles.

O modelo separa autenticação e autorização, tornando a administração mais simples e aderente às boas práticas da plataforma Salesforce.

---

# 2. Arquitetura de Segurança

A segurança da aplicação foi organizada em quatro camadas.

## Usuários

Representam os colaboradores da clínica e são responsáveis pela autenticação na plataforma.

Cada usuário recebe apenas as permissões necessárias para sua função operacional.

### Usuários cadastrados

#### Recepção

* Ana Recepcionista

Responsabilidades:

* cadastrar tutores;
* cadastrar pets;
* agendar consultas;
* consultar informações operacionais;
* visualizar relatórios;
* visualizar dashboards.

#### Veterinárias

* Dra. Cris Vet
* Dra. Laís Vet

Responsabilidades:

* cadastrar veterinários;
* atualizar informações dos veterinários;
* consultar indicadores;
* visualizar relatórios;
* visualizar dashboards.

---

## Permission Sets

Os Permission Sets concentram as permissões de acesso aos objetos, campos e funcionalidades da aplicação.

Ao invés de adicionar permissões diretamente ao Profile, elas são desacopladas e administradas separadamente, facilitando futuras alterações.

Entre as permissões configuradas estão:

* leitura;
* criação;
* edição;
* ausência de permissão para exclusão;
* acesso controlado por objeto.

---

## Permission Set Groups

Os Permission Sets foram agrupados conforme cada função de negócio.

### Reception

Grupo destinado aos atendentes da recepção.

Permissões:

* Appointment
* Pet
* Tutor
* Reports
* Dashboards

Esse grupo permite executar todas as atividades relacionadas ao atendimento da clínica, sem acesso às funcionalidades administrativas dos veterinários.

---

### Veterinarian

Grupo destinado às médicas veterinárias.

Permissões:

* Vet
* Reports
* Dashboards

Esse grupo restringe o acesso apenas ao gerenciamento dos profissionais veterinários e aos indicadores da clínica.

---

## Assigned Apps

Todos os usuários recebem acesso ao aplicativo:

**Belle VetCare**

O uso de Assigned Apps garante que, após o login, o usuário visualize apenas o aplicativo da clínica e suas respectivas abas autorizadas.

Essa configuração reduz a exposição de funcionalidades desnecessárias e melhora a experiência do usuário.

---

# 3. Controle de Acesso aos Objetos

O acesso aos objetos foi organizado conforme a responsabilidade de cada grupo.

## Grupo Reception

Possui acesso aos objetos:

* Appointment
* Pet
* Tutor

Também possui acesso a:

* Reports
* Dashboards

---

## Grupo Veterinarian

Possui acesso ao objeto:

* Vet

Também possui acesso a:

* Reports
* Dashboards

---

# 4. Field-Level Security (FLS)

Além do controle por objeto, foi implementado controle de acesso em nível de campo utilizando **Field-Level Security**.

## Campo protegido

**CRMV** (objeto `Vet__c`)

### Regra aplicada

A recepção não possui permissão para visualizar o campo CRMV.

Essa configuração protege informações profissionais sensíveis e demonstra o uso de segurança em nível de campo.

---

# 5. Restrições Aplicadas

Para garantir maior governança dos dados, algumas restrições foram implementadas.

## Recepção

Pode:

* cadastrar tutores;
* cadastrar pets;
* agendar consultas;
* consultar relatórios;
* visualizar dashboards.

Não pode:

* excluir registros;
* visualizar o CRMV;
* alterar registros de veterinários.

---

## Veterinárias

Podem:

* cadastrar veterinários;
* atualizar informações dos veterinários;
* consultar relatórios;
* visualizar dashboards.

Não podem:

* cadastrar tutores;
* cadastrar pets;
* agendar consultas;
* excluir registros.

---

# 6. Processo de Configuração da Segurança

A implementação da segurança foi realizada seguindo as seguintes etapas.

## Etapa 1 — Criação dos Usuários

Foram criados usuários representando os papéis existentes na clínica.

Cada usuário recebeu um Profile básico da Salesforce responsável apenas pela autenticação.

---

## Etapa 2 — Criação dos Permission Sets

Foram criados Permission Sets contendo as permissões específicas de cada função.

As permissões incluem:

* acesso aos objetos;
* criação;
* edição;
* leitura;
* restrições de exclusão;
* controle de acesso aos campos.

---

## Etapa 3 — Organização em Permission Set Groups

Os Permission Sets foram agrupados conforme cada área da clínica.

Foram criados os grupos:

* Reception
* Veterinarian

Essa organização facilita a administração das permissões e o onboarding de novos colaboradores.

---

## Etapa 4 — Atribuição dos Grupos aos Usuários

Cada usuário recebeu apenas o Permission Set Group correspondente à sua função.

Com isso, novos colaboradores podem ser configurados apenas associando o grupo adequado, sem necessidade de criar novos perfis.

---

## Etapa 5 — Configuração do Assigned App

Foi atribuído o aplicativo **Belle VetCare** aos grupos de usuários.

Após o login, cada colaborador acessa somente o aplicativo da clínica e suas funcionalidades autorizadas.

---

## Etapa 6 — Configuração do Field-Level Security

Foi aplicada restrição de acesso ao campo CRMV utilizando Field-Level Security.

Esse controle impede que usuários da recepção visualizem informações profissionais dos veterinários.

---

# 7. Boas Práticas Aplicadas

Durante o desenvolvimento foram adotadas recomendações oficiais da Salesforce.

## Permission Sets

Benefícios:

* desacoplamento das permissões do Profile;
* reutilização;
* menor manutenção;
* facilidade de auditoria;
* escalabilidade.

---

## Permission Set Groups

Benefícios:

* administração simplificada;
* organização das permissões;
* facilidade para onboarding;
* melhor governança da plataforma.

---

## Assigned Apps

Benefícios:

* interface mais limpa;
* acesso apenas ao aplicativo correto;
* melhor experiência do usuário;
* redução do risco de navegação indevida.

---

## Field-Level Security

Benefícios:

* proteção de informações sensíveis;
* controle granular de acesso;
* maior aderência às políticas de segurança.

---

# 8. Benefícios da Arquitetura

A estratégia adotada proporciona:

* aplicação do princípio de menor privilégio (Least Privilege);
* separação entre autenticação e autorização;
* permissões organizadas por função de negócio;
* redução da necessidade de Profiles personalizados;
* facilidade para adicionar novos colaboradores;
* arquitetura escalável;
* maior aderência às boas práticas da Salesforce;
* facilidade de manutenção e auditoria;
* proteção de dados sensíveis.

---

# 9. Cenário Prático

### Ana Recepcionista

Pode:

* cadastrar tutores;
* cadastrar pets;
* agendar consultas;
* consultar relatórios;
* visualizar dashboards.

Não pode:

* visualizar o CRMV;
* alterar registros de veterinários;
* excluir registros.

---

### Dra. Cris Vet

Pode:

* cadastrar veterinários;
* atualizar informações dos veterinários;
* consultar relatórios;
* visualizar dashboards.

Não pode:

* cadastrar tutores;
* cadastrar pets;
* agendar consultas;
* excluir registros.

---

# 10. Resultado do Modelo de Segurança

O modelo de segurança do Belle VetCare CRM equilibra operação, governança e proteção de dados, garantindo que cada colaborador tenha acesso apenas aos recursos necessários para desempenhar suas atividades.

A utilização de **Permission Sets**, **Permission Set Groups**, **Assigned Apps** e **Field-Level Security** demonstra a aplicação das melhores práticas recomendadas pela Salesforce para controle de acesso, escalabilidade e manutenção da plataforma, tornando a solução preparada para o crescimento da clínica e para futuras evoluções do sistema.
