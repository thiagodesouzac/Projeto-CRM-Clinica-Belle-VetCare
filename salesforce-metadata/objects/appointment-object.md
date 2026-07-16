# Appointment Object

## Label

Appointment

## API Name

Appointment__c

## Finalidade

Representa o agendamento de consultas da clínica veterinária.

---

## Campos Principais

| Campo | API | Tipo |
|--------|-----|------|
| Data | Date__c | Date |
| Email Vet | Email_Vet__c | Email |
| Note | Notes__c | Text Area |
| Pet | Pet__c | Lookup(Pet) |
| Reference| Name | Auto Number |
| Service Type | Service_Type__c | Picklist |
| Species | Species__c | Picklist |
| Status | Status__c | Picklist |
| Time | Time__c | Picklist |
| PetOwner | Pet_Owner__c | Lookup(PetOwner) |
| Vet | Vet__c | Lookup(Vet)

---

## Relacionamentos

Appointment → PetOwner

Appointment → Pet

Appointment → Vet (Veterinario)

---

## Utilização

Utilizado pelos Flows e Einstein Bot para criação automática de consultas.