/**
 * Classe: AppointmentTriggerHandler
 *
 * Responsabilidade: validar se já existe um agendamento para o mesmo
 * veterinário, na mesma data e no mesmo horário, evitando conflito
 * de agenda (overbooking).
 *
 * Escrita para funcionar corretamente em operações bulk (bulkificada),
 * respeitando governor limits (uma única query fora de loop).
 *
 * IMPORTANTE: este método espera ser chamado a partir do contexto de
 * trigger (before insert / before update), onde oldMap, quando não nulo,
 * sempre contém a entrada correspondente a cada registro de newRecords.
 */
public with sharing class AppointmentTriggerHandler {

    public static void validateNoConflict(List<Appointment__c> newRecords, Map<Id, Appointment__c> oldMap) {

        Set<Id> vetIds = new Set<Id>();
        Set<Date> dates = new Set<Date>();

        // 1) Coleta os dados necessários para a query, sem repetir queries em loop
        for (Appointment__c appt : newRecords) {

            Boolean isRelevantForCheck = appt.Vet__c != null
                && appt.Date__c != null
                && appt.Time__c != null;

            Boolean changedRelevantFields = oldMap == null
                || !oldMap.containsKey(appt.Id)
                || appt.Vet__c != oldMap.get(appt.Id).Vet__c
                || appt.Date__c != oldMap.get(appt.Id).Date__c
                || appt.Time__c != oldMap.get(appt.Id).Time__c;

            if (isRelevantForCheck && changedRelevantFields) {
                vetIds.add(appt.Vet__c);
                dates.add(appt.Date__c);
            }
        }

        if (vetIds.isEmpty()) {
            return;
        }

        /*2) Uma única consulta SOQL busca todos os agendamentos existentes
             para os veterinários/datas envolvidos neste bulk
        */
        Map<String, Appointment__c> existingAppointments = new Map<String, Appointment__c>();

        for (Appointment__c existing : [
            SELECT Id, Vet__c, Date__c, Time__c
            FROM Appointment__c
            WHERE Vet__c IN :vetIds
            AND Date__c IN :dates
        ]) {
            String chave = buildKey(existing.Vet__c, existing.Date__c, existing.Time__c);
            existingAppointments.put(chave, existing);
        }

        /*3) Detecta conflitos DENTRO do próprio lote (newRecords).
            Necessário porque, em um insert bulk, dois registros novos
            conflitantes entre si ainda não existem no banco no momento
            da query acima — então a query sozinha não os pegaria.
        */
        Map<String, Appointment__c> keysInBatch = new Map<String, Appointment__c>();

        // 4) Valida cada registro do bulk (contra o banco e contra o próprio lote)
        for (Appointment__c appt : newRecords) {

            if (appt.Vet__c == null || appt.Date__c == null || appt.Time__c == null) {
                continue;
            }

            String currentKey = buildKey(appt.Vet__c, appt.Date__c, appt.Time__c);

            // 4a) Conflito contra registros já existentes no banco
            Appointment__c conflict = existingAppointments.get(currentKey);
            Boolean isMesmoRegistro = conflict != null && conflict.Id == appt.Id;

            if (conflict != null && !isMesmoRegistro) {
                appt.addError(
                    'Este veterinário já possui um agendamento nesta data e horário. ' +
                    'Escolha outro horário ou outro profissional.'
                );
                continue;
            }

            // 4b) Conflito contra outro registro do mesmo lote (ex: insert bulk)
            if (keysInBatch.containsKey(currentKey)) {
                appt.addError(
                    'Já existe outro agendamento neste mesmo envio (lote) para este ' +
                    'veterinário, nesta data e horário. Ajuste os registros antes de salvar.'
                );
                continue;
            }

            keysInBatch.put(currentKey, appt);
        }
    }

    private static String buildKey(Id vetId, Date data, Time hora) {
        return vetId + '_' + String.valueOf(data) + '_' + String.valueOf(hora);
    }
}