/**
 * Trigger para agendamento.
 * Toda a regra de negócio está implementada em AppointmentTriggerHandler.
 */
trigger AppointmentTrigger on Appointment__c (before insert, before update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            AppointmentTriggerHandler.validateNoConflict(Trigger.new, null);
        }
        if (Trigger.isUpdate) {
            AppointmentTriggerHandler.validateNoConflict(Trigger.new, Trigger.oldMap);
        }
    }
}
