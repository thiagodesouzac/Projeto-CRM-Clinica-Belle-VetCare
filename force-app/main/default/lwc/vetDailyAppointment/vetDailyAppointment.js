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
            this.errorMessage =
                'Não foi possível carregar os agendamentos. Tente novamente.';

            console.error(
                'Erro ao buscar agendamentos:',
                error
            );
        }
    }

    handleDateChange(event) {
        this.selectedDate = event.target.value;
    }

    get hasAppointments() {
        return this.appointments && this.appointments.length > 0;
    }

    getTodayLocalISODate() {
        const today = new Date();

        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');

        return `${year}-${month}-${day}`;
    }

    formatTime(rawTime) {
        if (!rawTime) {
            return '';
        }

        const [hours, minutes] = rawTime.split(':');

        return `${hours}:${minutes}`;
    }
}