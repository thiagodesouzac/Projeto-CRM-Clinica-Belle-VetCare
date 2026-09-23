@IsTest
private class AppointmentCEPServiceTest {

    private static final String SUCCESS_JSON =
        '{' +
        '"cep":"01001-000",' +
        '"logradouro":"Praça da Sé",' +
        '"complemento":"lado ímpar",' +
        '"unidade":"",' +
        '"bairro":"Sé",' +
        '"localidade":"São Paulo",' +
        '"uf":"SP",' +
        '"estado":"São Paulo",' +
        '"regiao":"Sudeste",' +
        '"ibge":"3550308",' +
        '"gia":"1004",' +
        '"ddd":"11",' +
        '"siafi":"7107"' +
        '}';

    private class ViaCepMock implements HttpCalloutMock {
        public Integer statusCode = 200;
        public String body = '';
        public Boolean shouldThrow = false;
        public String receivedEndpoint;
        public String receivedMethod;

        public HttpResponse respond(HttpRequest request) {
            receivedEndpoint = request.getEndpoint();
            receivedMethod = request.getMethod();

            if (shouldThrow) {
                throw new CalloutException('Simulated timeout');
            }

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(statusCode);
            response.setBody(body);
            return response;
        }
    }

    private static ViaCepMock setUpMock(Integer statusCode, String body) {
        ViaCepMock mock = new ViaCepMock();
        mock.statusCode = statusCode;
        mock.body = body;
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static void assertError(String zipCode, String expectedFragment) {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AppointmentCEPService.getAddressByZipCode(zipCode);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            Assert.isTrue(
                e.getMessage().containsIgnoreCase(expectedFragment),
                'Unexpected message: ' + e.getMessage()
            );
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'An AuraHandledException was expected for ZIP code: ' + zipCode);
    }

    @IsTest
    static void shouldReturnAddressForValidZipCode() {
        ViaCepMock mock = setUpMock(200, SUCCESS_JSON);

        Test.startTest();
        AppointmentCEPService.AddressDTO result = AppointmentCEPService.getAddressByZipCode('01001-000');
        Test.stopTest();

        Assert.areEqual('01001-000', result.cep);
        Assert.areEqual('Praça da Sé', result.logradouro);
        Assert.areEqual('Sé', result.bairro);
        Assert.areEqual('São Paulo', result.localidade);
        Assert.areEqual('SP', result.uf);
        Assert.areEqual('GET', mock.receivedMethod);
        Assert.areEqual('https://viacep.com.br/ws/01001000/json/', mock.receivedEndpoint);
    }

    @IsTest
    static void shouldAcceptZipCodeWithoutMask() {
        ViaCepMock mock = setUpMock(200, SUCCESS_JSON);

        Test.startTest();
        AppointmentCEPService.AddressDTO result = AppointmentCEPService.getAddressByZipCode('01001000');
        Test.stopTest();

        Assert.areEqual('SP', result.uf);
        Assert.areEqual('https://viacep.com.br/ws/01001000/json/', mock.receivedEndpoint);
    }

    @IsTest
    static void shouldReturnEmptyStreetAndNeighborhoodForGenericZipCode() {
        setUpMock(
            200,
            '{"cep":"12345-000","logradouro":"","bairro":"","localidade":"Small Town","uf":"MG"}'
        );

        Test.startTest();
        AppointmentCEPService.AddressDTO result = AppointmentCEPService.getAddressByZipCode('12345000');
        Test.stopTest();

        Assert.areEqual('', result.logradouro);
        Assert.areEqual('', result.bairro);
        Assert.areEqual('Small Town', result.localidade);
        Assert.areEqual('MG', result.uf);
    }

    @IsTest
    static void shouldThrowWhenZipCodeNotFound() {
        setUpMock(200, '{"erro": true}');
        assertError('99999999', 'not found');
    }

    @IsTest
    static void shouldThrowWhenErrorFlagIsString() {
        setUpMock(200, '{"erro": "true"}');
        assertError('99999999', 'not found');
    }

    @IsTest
    static void shouldThrowForNullZipCode() {
        assertError(null, 'Invalid ZIP code');
    }

    @IsTest
    static void shouldThrowForBlankZipCode() {
        assertError('   ', 'Invalid ZIP code');
    }

    @IsTest
    static void shouldThrowForShortZipCode() {
        assertError('123', 'Invalid ZIP code');
    }

    @IsTest
    static void shouldThrowForLongZipCode() {
        assertError('123456789', 'Invalid ZIP code');
    }

    @IsTest
    static void shouldThrowForZipCodeWithLetters() {
        assertError('abcdefgh', 'Invalid ZIP code');
    }

    @IsTest
    static void shouldThrowWhenApiReturns400() {
        setUpMock(400, '');
        assertError('01001000', 'invalid format');
    }

    @IsTest
    static void shouldThrowWhenApiReturns500() {
        setUpMock(500, 'Internal Server Error');
        assertError('01001000', 'unavailable');
    }

    @IsTest
    static void shouldThrowWhenResponseIsNotJson() {
        setUpMock(200, '<html>not json</html>');
        assertError('01001000', 'Unexpected response');
    }

    @IsTest
    static void shouldThrowWhenCalloutFails() {
        ViaCepMock mock = new ViaCepMock();
        mock.shouldThrow = true;
        Test.setMock(HttpCalloutMock.class, mock);

        assertError('01001000', 'Could not look up');
    }
}