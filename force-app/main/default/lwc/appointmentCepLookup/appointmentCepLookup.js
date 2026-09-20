import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordCreateDefaults } from 'lightning/uiRecordApi';
import findAddress from '@salesforce/apex/ViaCepController.findAddress';

// Ajuste aqui se os nomes de API forem diferentes no seu projeto.
const OBJECT_API_NAME = 'Appointment__c';
const FIELD = {
    ZIP_CODE: 'CEP__c',
    STREET: 'Street__c',
    NEIGHBORHOOD: 'Neighborhood__c',
    CITY: 'City__c',
    STATE: 'State__c'
};
const ADDRESS_FIELDS = Object.values(FIELD);

// true  -> grava o CEP como 01001-000 (campo de texto com pelo menos 9 caracteres)
// false -> grava somente os dígitos: 01001000
const FORMAT_ZIP_CODE_WITH_HYPHEN = true;

const ZIP_CODE_LENGTH = 8;
const ADDRESS_SECTION_HEADING = 'Pet Owner Address';

const buildFieldConfig = (apiName, required) => ({
    apiName,
    required: Boolean(required),
    isZipCode: apiName === FIELD.ZIP_CODE
});

// Seção usada ao editar um registro existente: somente os campos de endereço.
const ADDRESS_ONLY_SECTIONS = [
    {
        key: 'section-address',
        heading: null,
        fields: ADDRESS_FIELDS.map((apiName) => buildFieldConfig(apiName, false))
    }
];

/**
 * Converte o layout de criação do objeto (mesmo layout do botão New padrão)
 * em uma lista de seções e campos para o template.
 */
function buildSectionsFromLayout(layout) {
    const sections = [];
    const includedFields = new Set();

    (layout?.sections || []).forEach((section, index) => {
        const fields = [];
        (section.layoutRows || []).forEach((row) => {
            (row.layoutItems || []).forEach((item) => {
                // Ignora campos somente leitura na criação (ex.: Owner, fórmulas).
                if (!item.editableForNew) {
                    return;
                }
                (item.layoutComponents || []).forEach((component) => {
                    if (component.componentType === 'Field' && component.apiName) {
                        fields.push(buildFieldConfig(component.apiName, item.required));
                        includedFields.add(component.apiName);
                    }
                });
            });
        });

        if (fields.length > 0) {
            sections.push({
                key: `section-${index}`,
                heading: section.useHeading ? section.heading : null,
                fields
            });
        }
    });

    // Garante que os campos de endereço apareçam mesmo que não estejam no layout.
    const missingFields = ADDRESS_FIELDS.filter((apiName) => !includedFields.has(apiName));
    if (missingFields.length > 0) {
        sections.push({
            key: 'section-address',
            heading: ADDRESS_SECTION_HEADING,
            fields: missingFields.map((apiName) => buildFieldConfig(apiName, false))
        });
    }

    return sections;
}

export default class AppointmentCepLookup extends NavigationMixin(LightningElement) {
    /** Preenchido automaticamente quando o componente está numa Record Page. */
    @api recordId;

    appointmentObject = OBJECT_API_NAME;

    isLoading = false;
    zipCodeMessage = '';
    zipCodeMessageIsError = false;
    lastQueriedZipCode = '';

    layoutSections;
    layoutFailed = false;
    layoutErrorMessage =
        'Could not load the appointment form. Reload the page or fill in the address below.';

    // ------------------------------------------------------------------
    // Layout (somente ao criar um novo registro)
    // ------------------------------------------------------------------

    /** Sem recordId o wire é executado; com recordId o parâmetro fica undefined e o wire não roda. */
    get layoutObjectApiName() {
        return this.recordId ? undefined : OBJECT_API_NAME;
    }

    @wire(getRecordCreateDefaults, { objectApiName: '$layoutObjectApiName' })
    wiredCreateDefaults({ data, error }) {
        if (data) {
            this.layoutSections = buildSectionsFromLayout(data.layout);
            this.layoutFailed = false;
        } else if (error) {
            this.layoutFailed = true;
        }
    }

    get isNewMode() {
        return !this.recordId;
    }

    get cardTitle() {
        return this.isNewMode ? 'New Appointment' : ADDRESS_SECTION_HEADING;
    }

    get isLayoutLoading() {
        return this.isNewMode && !this.layoutSections && !this.layoutFailed;
    }

    get showSpinner() {
        return this.isLoading || this.isLayoutLoading;
    }

    get sections() {
        if (this.isNewMode && !this.layoutFailed) {
            return this.layoutSections || [];
        }
        return ADDRESS_ONLY_SECTIONS;
    }

    get zipCodeMessageClass() {
        const color = this.zipCodeMessageIsError ? 'slds-text-color_error' : 'slds-text-color_success';
        return `${color} slds-text-body_small slds-m-top_xx-small`;
    }

    // ------------------------------------------------------------------
    // Eventos do formulário
    // ------------------------------------------------------------------

    /**
     * Ao editar um agendamento existente, guarda o CEP já salvo para não
     * sobrescrever o endereço se o campo disparar "change" durante o carregamento.
     */
    handleLoad(event) {
        if (!this.recordId) {
            return;
        }
        const record = event.detail?.records?.[this.recordId];
        const savedZipCode = record?.fields?.[FIELD.ZIP_CODE]?.value;
        if (savedZipCode) {
            this.lastQueriedZipCode = this.onlyDigits(savedZipCode);
        }
    }

    handleFieldChange(event) {
        if (event.target.dataset.field !== FIELD.ZIP_CODE) {
            return;
        }

        const digits = this.onlyDigits(event.detail.value);

        if (digits.length < ZIP_CODE_LENGTH) {
            // Ainda digitando: cancela qualquer consulta pendente e limpa a mensagem.
            this.lastQueriedZipCode = '';
            this.isLoading = false;
            this.setMessage('', false);
            return;
        }

        if (digits.length > ZIP_CODE_LENGTH) {
            this.lastQueriedZipCode = '';
            this.setMessage('ZIP code must have 8 digits.', true);
            return;
        }

        if (digits !== this.lastQueriedZipCode) {
            this.lookupZipCode(digits);
        }
    }

    handleSubmit() {
        this.isLoading = true;
    }

    handleSuccess(event) {
        this.isLoading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Appointment saved',
                message: 'The appointment was saved successfully.',
                variant: 'success'
            })
        );

        // Em modo de criação, abre o registro recém-criado.
        if (this.isNewMode) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.detail.id,
                    objectApiName: OBJECT_API_NAME,
                    actionName: 'view'
                }
            });
        }
    }

    handleError() {
        // A mensagem detalhada é exibida pelo <lightning-messages>.
        this.isLoading = false;
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: OBJECT_API_NAME,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    // ------------------------------------------------------------------
    // Consulta do CEP
    // ------------------------------------------------------------------

    async lookupZipCode(digits) {
        this.lastQueriedZipCode = digits;
        this.isLoading = true;
        this.setMessage('', false);

        try {
            const address = await findAddress({ zipCode: digits });

            // Ignora respostas de consultas antigas (usuário mudou o CEP no meio da chamada).
            if (digits !== this.lastQueriedZipCode) {
                return;
            }

            this.fillFields(digits, address);
            this.setMessage('Address filled in automatically.', false);
        } catch (error) {
            if (digits !== this.lastQueriedZipCode) {
                return;
            }
            this.setMessage(this.extractErrorMessage(error), true);
        } finally {
            if (digits === this.lastQueriedZipCode) {
                this.isLoading = false;
            }
        }
    }

    fillFields(digits, address) {
        this.setFieldValue(FIELD.ZIP_CODE, this.formatZipCode(digits));
        this.setFieldValue(FIELD.STREET, address.street);
        this.setFieldValue(FIELD.NEIGHBORHOOD, address.neighborhood);
        this.setFieldValue(FIELD.CITY, address.city);
        this.setFieldValue(FIELD.STATE, address.state);
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    setFieldValue(fieldApiName, value) {
        const field = this.template.querySelector(`[data-field="${fieldApiName}"]`);
        if (field) {
            field.value = value || '';
        }
    }

    setMessage(text, isError) {
        this.zipCodeMessage = text;
        this.zipCodeMessageIsError = isError;
    }

    onlyDigits(value) {
        return (value || '').replace(/\D/g, '');
    }

    formatZipCode(digits) {
        return FORMAT_ZIP_CODE_WITH_HYPHEN ? `${digits.slice(0, 5)}-${digits.slice(5)}` : digits;
    }

    extractErrorMessage(error) {
        return (
            error?.body?.message ||
            error?.message ||
            'Could not look up the ZIP code. Fill in the address manually.'
        );
    }
}
