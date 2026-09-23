/**
 * Consulta de endereço na API pública ViaCEP (https://viacep.com.br).
 *
 * Usada pelo LWC appointmentForm para preencher automaticamente
 * Street__c, Neighborhood__c, City__c e State__c do Appointment__c
 * a partir do CEP digitado (CEP__c).
 *
 * O DTO devolvido usa os mesmos nomes de campo do JSON do ViaCEP
 * (logradouro, bairro, localidade, uf) porque é exatamente isso
 * que o appointmentForm.js espera ao ler o resultado.
 *
 * Requisitos:
 *  - Remote Site Setting "ViaCEP" ativo (https://viacep.com.br)
 *  - Permission Set "AppointmentCEP_Access" atribuído ao usuário
 */
public with sharing class AppointmentCEPService {

    private static final String VIACEP_BASE_URL = 'https://viacep.com.br/ws/';
    private static final Integer TIMEOUT_MS = 10000;
    private static final Integer ZIP_CODE_LENGTH = 8;

    /**
     * Estrutura devolvida ao LWC (nomes iguais ao JSON do ViaCEP).
     */
    public class AddressDTO {
        @AuraEnabled public String cep;
        @AuraEnabled public String logradouro;
        @AuraEnabled public String bairro;
        @AuraEnabled public String localidade;
        @AuraEnabled public String uf;
    }

    /**
     * Busca o endereço correspondente ao CEP informado.
     *
     * @param zipCode CEP com ou sem hífen (ex.: 01001-000 ou 01001000)
     * @return AddressDTO com cep, logradouro, bairro, localidade e uf
     * @throws AuraHandledException quando o CEP é inválido, não existe ou o serviço falha
     */
    @AuraEnabled
    public static AddressDTO getAddressByZipCode(String zipCode) {
        String cleanZipCode = sanitizeZipCode(zipCode);

        if (String.isBlank(cleanZipCode) || cleanZipCode.length() != ZIP_CODE_LENGTH) {
            throw buildError('Invalid ZIP code. Enter the 8 digits.');
        }

        HttpResponse response = executeCallout(cleanZipCode);

        if (response.getStatusCode() == 400) {
            throw buildError('ZIP code has an invalid format. Check the digits entered.');
        }
        if (response.getStatusCode() != 200) {
            throw buildError(
                'ZIP code lookup service is unavailable right now (HTTP ' +
                response.getStatusCode() + '). Fill in the address manually or try again.'
            );
        }

        Map<String, Object> payload;
        try {
            payload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } catch (Exception e) {
            throw buildError('Unexpected response from the ZIP code service. Please try again.');
        }

        // O ViaCEP responde 200 com {"erro": true} (ou "true") quando o CEP não existe.
        if ('true'.equalsIgnoreCase(String.valueOf(payload.get('erro')))) {
            throw buildError('ZIP code not found. Check the number or fill in the address manually.');
        }

        AddressDTO address = new AddressDTO();
        address.cep = readText(payload, 'cep');
        address.logradouro = readText(payload, 'logradouro');
        address.bairro = readText(payload, 'bairro');
        address.localidade = readText(payload, 'localidade');
        address.uf = readText(payload, 'uf');
        return address;
    }

    // ------------------------------------------------------------------
    // Auxiliares
    // ------------------------------------------------------------------

    private static HttpResponse executeCallout(String cleanZipCode) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VIACEP_BASE_URL + cleanZipCode + '/json/');
            request.setMethod('GET');
            request.setHeader('Accept', 'application/json');
            request.setTimeout(TIMEOUT_MS);
            return new Http().send(request);
        } catch (Exception e) {
            throw buildError(
                'Could not look up the ZIP code right now. Try again shortly. (' + e.getMessage() + ')'
            );
        }
    }

    private static String sanitizeZipCode(String zipCode) {
        if (zipCode == null) {
            return null;
        }
        return zipCode.replaceAll('[^0-9]', '');
    }

    private static String readText(Map<String, Object> payload, String key) {
        Object rawValue = payload.get(key);
        return rawValue == null ? null : String.valueOf(rawValue);
    }

    private static AuraHandledException buildError(String message) {
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);
        return error;
    }
}