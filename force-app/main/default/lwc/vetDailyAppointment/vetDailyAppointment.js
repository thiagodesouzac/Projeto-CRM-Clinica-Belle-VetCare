import { LightningElement, wire } from 'lwc';
import getAppointmentsByDate from '@salesforce/apex/VetAppointmentController.getAppointmentsByDate';

const COLUMNS = [
    { label: 'Time', fieldName: 'FormattedTime', type: 'text' },
    { label: 'Vet', fieldName: 'VetName', type: 'text' },
    { label: 'Service Type', fieldName: 'Service_Type__c', type: 'text' },
    { label: 'Species', fieldName: 'Species__c', type: 'text' }
];

export default class VetDailyAppointment extends LightningElement {

    columns = COLUMNS;
    selectedDate = this.getTodayLocalISODate();
    appointments = [];
    errorMessage;

    @wire(getAppointmentsByDate, { selectedDate: '$selectedDate' })
    wiredAppointments({ data, error }) {
        if (data) {
            this.appointments = data.map((appt) => ({
                ...appt,
                VetName: appt.Vet__r ? appt.Vet__r.Name : '',
                FormattedTime: this.formatTime(appt.Time__c)
            }));
            this.errorMessage = undefined;
        } else if (error) {
            this.appointments = [];
            this.errorMessage = 'Não foi possível carregar os agendamentos. Tente novamente.';
            // eslint-disable-next-line no-console
            console.error('Erro ao buscar agendamentos:', error);
        }
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }

    get hasAppointments() {
        return this.appointments && this.appointments.length > 0;
    }

    /**
     * Retorna a data local de hoje no formato YYYY-MM-DD, sem passar por UTC.
     * Evita o bug de toISOString() mostrar o dia errado dependendo do
     * fuso horário do usuário (ex: horários próximos da meia-noite).
     */
    getTodayLocalISODate() {
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    /**
     * Formata um valor de campo Time (ex: '09:00:00.000Z') para exibição
     * amigável (ex: '09:00'). Ajuste o formato conforme a necessidade do
     * time (12h/24h, exibir segundos, etc.).
     */
    formatTime(rawTime) {
        if (!rawTime) {
            return '';
        }
        // Campos Time do Salesforce chegam como string, ex: '09:00:00.000Z'
        const [hours, minutes] = rawTime.split(':');
        return `${hours}:${minutes}`;
    }
}