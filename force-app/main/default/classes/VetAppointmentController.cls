/**
 * Classe Controladora que expõe dados de agendamento para o
 * vetDailyAppointment Lightning Web Component.
 */
public with sharing class VetAppointmentController {

    /**
     * Retorna todos os agendamentos para uma determinada data, respeitando
     * as permissões de objeto e campo do usuário ativo.
     *
     * @param selectedDate  the date to filter appointments by
     * @return List<Appointment__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getAppointmentsByDate(Date selectedDate) {

        if (selectedDate == null) {
            selectedDate = Date.today();
        }

        try {
            return [
                SELECT Id, Name, Vet__c, Vet__r.Name, Date__c, Time__c,
                       Service_Type__c, Species__c
                FROM Appointment__c
                WHERE Date__c = :selectedDate
                WITH SECURITY_ENFORCED
                ORDER BY Time__c ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Não foi possível carregar os agendamentos: ' + e.getMessage());
        }
    }
}