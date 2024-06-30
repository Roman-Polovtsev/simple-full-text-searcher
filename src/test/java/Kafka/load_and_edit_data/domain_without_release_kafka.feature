@indexer @kafka
Feature: Индексированный поиск. Проверка взаимодействия с Kafka Synapse

  Background:
    * configure connectTimeout = 15000
     # Использование по дефолту эндпоинта Indexer
    * url indexerBaseUri
    # Использование по дефолту таких имён для переменных проекта и домена
    * def project_id = 'auto'
    * def domain_id = 'auto'
    * def alias_id = 'auto_alias'
    * def data_group = 'clients-dossier'
    # Пост-условие. Удаление тестового проекта данных
    * configure afterFeature = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }

    # Для отправки запросов в Kafka Synapse
    * def properties = { topicName: #(topicName), bootstrapAddress: #(kafkaBootstrapAddress), trustStoreLocation: #(trustStoreLocation), trustStorePassword: #(trustStorePassword), keyStoreLocation: #(keyStoreLocation), keyStorePassword: #(keyStorePassword) }
    * def KafkaConfig = Java.type('tests.Kafka.producer.KafkaConfig');
    * def configProducer = new KafkaConfig(properties);
    # Отправка запроса в Кафку без задержки
    * def sendData =
    """
    function send(data) {
    var KafkaProducer = Java.type('tests.Kafka.producer.CustomKafkaProducer');
    var kp = new KafkaProducer(configProducer);
    kp.send(data);}
    """
    # Отправка запроса в Кафку с задержкой
    * def sendDelayedData =
      """
      function send(data) {
        var KafkaProducer = Java.type('tests.Kafka.producer.CustomKafkaProducer');
        var kp = new KafkaProducer(configProducer);
        kp.delayedSend(data, 3000);}
      """
    # Для вычитки сообщений из Kafka Synapse
    * def errorProperties = { errorTopicName: #(errorTopicName), bootstrapAddress: #(kafkaBootstrapAddress), trustStoreLocation: #(trustStoreLocation), trustStorePassword: #(trustStorePassword), keyStoreLocation: #(keyStoreLocation), keyStorePassword: #(keyStorePassword), groupIdName: #(groupIdName) }
    * def KafkaConsumerConfig = Java.type('tests.Kafka.consumer.ConsumerKafkaConfig');
    * def configConsumer = new KafkaConsumerConfig(errorProperties);
    * def receiveData =
      """
      function receive() {
        var KafkaConsumer = Java.type('tests.Kafka.consumer.CustomKafkaConsumer');
        var kc = new KafkaConsumer(configConsumer);
        return kc.receive();}
      """
    * def receiveNData =
      """
      function receiveN() {
        var KafkaConsumer = Java.type('tests.Kafka.consumer.CustomKafkaConsumer');
        var FullTextSearch = Java.type('tests.Kafka.fts.FullTextSearchImpl');
        var kc = new KafkaConsumer(configConsumer);
        var result = kc.receiveLastNRecords(5);
        var fts = new FullTextSearch(result);
        return fts.search("hostName");}
      """


#  @TmsLink=IDXS-T843
  Scenario: IDXS-8800
    # Создание домена данных
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в домен данных
#    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "documents": [ { "id": 1, "operation": "save", "fields": { "test": "example" } }, { "id": 2, "operation": "save", "fields": { "test": "example_2" } }, { "id": 3, "operation": "save", "fields": { "test": "пример" } }, { "id": 4, "operation": "save", "fields": { "test": "пример_2" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    * string error_message_kafka = call receiveNData


     # IDXS-T843 Consumer. BATCH. Проверка операций save, partUpdate, delete для метода batch
  @TmsLink=IDXS-T843
  Scenario: IDXS-T843 Consumer. BATCH. Проверка операций save, partUpdate, delete для метода batch
  # Создание домена данных
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
  # Проверка создания тестового домена
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/domains/' + domain_id + '/exist'
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "exist": true } }
  # Загрузка данных с операцией save
    * def request_kafka = call sendData '{"body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '", "documents": [ {"id": 1,"operation": "save","fields": {"test": "example"}}, {"id": 2,"operation": "save","fields": {"test": "example_2"}}, {"id": 3,"operation": "save","fields": {"test": "пример"}}, {"id": 4,"operation": "save","fields": {"test": "пример_2"}}]}, "header": {"evtType": "Тип события","evtVersion": "Версия схемы события","srcModule": "Код АС-источника события","evtID": "Уникальный идентификатор события","evtDate": "Время возникновения события","sndDate": "Время отправки события источником","parentID": "Идентификатор события-родителя","prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
  # Поиск по домену данных. Проверка загрузки документов с операцией save
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '/search'
    * request
    """
    {"query":"example","fields":["*"]}
    """
    When method POST
    Then status 200
    * match response ==  {"success":true,"body":{"coverage":{"documents":2,"full":true},"results":[{"id":"1","ranking":1.8828506,"fields":{"test":"example"}},{"id":"2","ranking":1.6709665,"fields":{"test":"example_2"}}]}}
  # Загрузка данных с операцией partUpdate
    * def request_kafka = call sendData '{"header": {"evtType": "Тип события","evtVersion": "Версия схемы события","srcModule": "Код АС-источника события","evtID": "Уникальный идентификатор события","evtDate": "Время возникновения события","sndDate": "Время отправки события источником","parentID": "Идентификатор события-родителя","prevEvtID": "Идентификтор предыдущего события АС-источника"}, "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '", "documents":[ {"id": 3,"operation": "partUpdate","fields": {"test": "example_3"}}, {"id": 4,"operation": "partUpdate","fields": {"test": "example_4"}}]}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
  # Поиск по домену данных. Проверка загрузки документов с операцией partUpdate
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '/search'
    * request
    """
    {"query":"example","fields":["*"]}
    """
    When method POST
    Then status 200
    * match response == {"success":true,"body":{"coverage":{"documents":4,"full":true},"results":[{"id":"1","ranking":1.5811061,"fields":{"test":"example"}},{"id":"2","ranking":1.4492586,"fields":{"test":"example_2"}},{"id":"3","ranking":1.4492586,"fields":{"test":"example_3"}},{"id":"4","ranking":1.4492586,"fields":{"test":"example_4"}}]}}
  # Загрузка данных с операцией delete
    * def request_kafka = call sendData '{"header": {"evtType": "Тип события","evtVersion": "Версия схемы события","srcModule": "Код АС-источника события","evtID": "Уникальный идентификатор события","evtDate": "Время возникновения события","sndDate": "Время отправки события источником","parentID": "Идентификатор события-родителя","prevEvtID": "Идентификтор предыдущего события АС-источника"}, "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '", "documents": [ {"id": 1,"operation": "save","fields": {"test": "example"}}, {"id": 2,"operation": "delete","fields": {"test": "example_2"}}, {"id": 3,"operation": "delete","fields": {"test": "example_3"}}, {"id": 4,"operation": "delete","fields": {"test": "example_4"}}]}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
  # Поиск по домену данных. Проверка загрузки документов с операцией delete
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/auto/search'
    * request
    """
    {"query":"example","fields":["*"]}
    """
    When method POST
    Then status 200
    * match response ==  {"success":true,"body":{"coverage":{"documents":1,"full":true},"results":[{"id":"1","ranking":1.4841912,"fields":{"test":"example"}}]}}
  # Удаление домена данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}



#    # IDXS-T897 Consumer Kafka. Создание домена данных с выбором количества шардов ElasticSearch (release 1.5)
#  @TmsLink=IDXS-T897
#  Scenario Outline: IDXS-T897 Consumer Kafka. Создание домена данных с выбором количества шардов ElasticSearch (release 1.5)
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain", "rn_id": "<project_id>", "domain_name": "<domain_id>", "number_of_shards": "<shards>" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Запрос информации о домене данных
#    Given path '/api/v2.1/projects/<project_id>/domains/<domain_id>'
#    * request
#    When method GET
#    Then status 200
#    * match response contains { success: true }
#    * def id = get response.body.id
#    # Провека в ElasticSearch сколько шардов задействуется в созданном домене данных
#    Given url elasticBaseUri + '$idxs$<project_id>$<domain_id>$' + id + '/_stats'
#    * header Authorization = call read('classpath:globals_js/elastic-authIDXS.js')
#    When method GET
#    * print response
#    * match response._shards.total == <shards>  * 3
#    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_domain.feature'); }
#    Examples:
#      | project_id | domain_id   | shards |
#      | auto       | auto_shards | 3      |
#      | auto       | auto_shards | 50     |
#      | auto       | auto_shards | 99     |
#     # Проверка запроса на создание домена данных без использования параметра numberOfShards
#  @TmsLink=IDXS-T897
#  Scenario Outline: IDXS-T897 Consumer Kafka. Создание домена данных с выбором количества шардов ElasticSearch (release 1.5)
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain", "rn_id": "<project_id>", "domain_name": "<domain_id>"}, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Запрос информации о домене данных
#    Given path '/api/v2.1/projects/<project_id>/domains/<domain_id>'
#    * request
#    When method GET
#    Then status 200
#    * match response contains { success: true }
#    * def id = get response.body.id
#    # Провека в ElasticSearch сколько шардов задействуется в созданном домене данных
#    Given url elasticBaseUri + '$idxs$<project_id>$<domain_id>$' + id + '/_stats'
#    * header Authorization = call read('classpath:globals_js/elastic-authIDXS.js')
#    When method GET
#    * print response
#    * match response._shards.total == 9
#    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_domain.feature'); }
#    Examples:
#      | project_id | domain_id   |
#      | auto       | auto_shards |
#     # Проверка невалидных значений numberOfShards
#  @TmsLink=IDXS-T897
#  Scenario Outline: IDXS-T897 Consumer Kafka. Создание домена данных с выбором количества шардов ElasticSearch (release 1.5)
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain", "rn_id": "<project_id>", "domain_name": "<domain_id>", "number_of_shards": "<shards>" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания домена
#    Given url elasticBaseUri + '_cat/indices'
#    * header Authorization = call read('classpath:globals_js/elastic-authIDXS.js')
#    * request
#    When method GET
#    Then status 200
#    * match response !contains '$<domain_id>$'
#    Examples:
#      | project_id | domain_id   | shards |
#      | auto       | auto_shards | 2      |
#      | auto       | auto_shards | 100    |
#      | auto       | auto_shards | 0      |




     # IDXS-T832 Consumer. CREATE_DOMAIN. Создание индекса
  @TmsLink=IDXS-T832
  Scenario: IDXS-T832 Consumer. CREATE_DOMAIN. Создание индекса
    * def project_id = 'auto'
    * def domain_id = 'auto_create'
  # Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
  # Проверка создания тестового домена
    Given path '/api/v2.1/projects/' + project_id + '/domains/' + domain_id + '/exist'
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "exist": true } }
  # Проверка создания тестового домена
    Given path '/api/v2.1/projects/' + project_id + '/domains/' + domain_id
    * request
    When method GET
    Then status 200
    * match response contains { success: true }
    * match response.body.id == '#regex [a-z,A-Z,0-9]{7}'
    * def created = get response.body.createdAt
    * def createdAt = created + ''
    * match createdAt ==  '#regex [0-9]{13}'
    * match response.body.docs.count == '#number'
    * match response.body.aliases[*] == '#notnull'
#    * match response.body.synonyms[*] == '#notnull'
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_load_for_group_indices.feature'); }


     # IDXS-T863 Consumer. CREATE_GROUP. Проверка создания группы индексов
  @TmsLink=IDXS-T863
  Scenario: IDXS-T863 Consumer. CREATE_GROUP. Проверка создания группы индексов
    # Создание группы доменов
    * call read('classpath:globals_features/glob_create_group_indices.feature')
    # Загрузка данных в домены данных
    * call read('classpath:globals_features/glob_load_for_group_indices.feature')
    # Создание группы "индексов" через Kafka
    * def request_kafka = call sendData '{ "body": { "action": "create_group", "rn_id": "' + project_id + '", "alias": "' + alias_id + '", "domains": [ { "name": "' + domain_id + '_1" }, { "name": "' + domain_id + '_2" }, { "name": "' + domain_id + '_3" } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка создания группы индексов
    Given path '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [ { "name": "auto_1" },{ "name": "auto_2" },{ "name": "auto_3" } ] } }
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 18
    * match each response.body.results[*].index == '#notnull'
    # Создание домена данных с алиасом через Kafka
    * def request_kafka = call sendData '{ "body": { "action": "create_domain_with_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_4", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка создания группы индексов
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [ { "name": "auto_1" },{ "name": "auto_2" },{ "name": "auto_3" },{ "name": "auto_4" } ] } }
    # Загрузка документов в созданный индекс через Kafka
    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/testlin_clients_1.txt')
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 30
    * match each response.body.results[*].index == '#notnull'
    # Удаление домена данных через Kafka
    * def request_kafka = call sendData ' { "body": { "action": "delete_domain", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка количества документов в группе индексов
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [ { "name": "auto_2" },{ "name": "auto_3" },{ "name": "auto_4" } ] } }
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 24
    * match each response.body.results[*].index == '#notnull'
    # Удаление созданного домена данных
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }



     # IDXS-T866 Consumer. DELETE_ALIAS. Проверка удаления домена из группы индексов.
  @TmsLink=IDXS-T866
  Scenario: IDXS-T866 Consumer. DELETE_ALIAS. Проверка удаления домена из группы индексов.
    # Создание группы доменов
    * call read('classpath:globals_features/glob_create_group_indices.feature')
    # Загрузка данных в домены данных
    * call read('classpath:globals_features/glob_load_for_group_indices.feature')
    # Создание группы "индексов" через Kafka
    * def request_kafka = call sendData '{ "body": { "action": "create_group", "rn_id": "' + project_id + '", "alias": "' + alias_id + '", "domains": [ { "name": "' + domain_id + '_1" }, { "name": "' + domain_id + '_2" }, { "name": "' + domain_id + '_3" } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка создания группы индексов
    Given path '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [ { "name": "auto_1" },{ "name": "auto_2" },{ "name": "auto_3" } ] } }
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 18
    * match each response.body.results[*].index == '#notnull'
    # Удаление домена данных через Kafka
    * def request_kafka = call sendData ' { "body": { "action": "delete_domain", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка количества доменов в группе индексов
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [{ "name": "auto_2" },{ "name": "auto_3" } ] } }
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 12
    * match each response.body.results[*].index == '#notnull'
    # Удаление домена данных через Kafka
    * def request_kafka = call sendData ' { "body": { "action": "delete_domain", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_2" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка количества доменов в группе индексов
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
    * request
    When method GET
    Then status 200
    * match response == { "success": true, "body": { "indices": [{ "name": "auto_3" } ] } }
    # Проверка поиска по группе индексов
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
    * request
    """
    {"size":1000}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == 6
    * match each response.body.results[*].index == '#notnull'
    # Удаление созданного домена данных
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }
#
#
#      # IDXS-T865 Consumer. CREATE_DOMAIN_WITH_ALIAS. Проверка создания домена с кастомным алиасом.
#  @TmsLink=IDXS-T865
#  Scenario: IDXS-T865 Consumer. CREATE_DOMAIN_WITH_ALIAS. Проверка создания домена с кастомным алиасом.
#    # Создание домена данных с алиасом через Kafka
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain_with_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/clients-dossier_1.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка поиска по группе индексов
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 6
#    * match each response.body.results[*].index == domain_id + '_1'
#    # Проверка количества доменов в группе индексов
#    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": {"indices":[{ "name": "auto_1" }]}}
#    # Создание домена данных с алиасом через Kafka
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain_with_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_2", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания группы индексов
#    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": { "indices": [ { "name": "auto_1" },{ "name": "auto_2" }] } }
#    # Создание домена данных с алиасом через Kafka
#    * def request_kafka = call sendData '{ "body": { "action": "create_domain_with_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_4", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/testlin_clients_1.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка поиска по группе индексов
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 18
#    # Проверка создания группы индексов
#    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": {"indices":[{ "name": "auto_1" },{ "name": "auto_2" },{ "name": "auto_4" }]}}
#    # Удаление созданного домена данных
#    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }
#

#
#     # IDXS-T864 Consumer. SET_ALIAS. Проверка добавления домена в группу индексов
#  @TmsLink=IDXS-T864
#  Scenario: IDXS-T864 Consumer. SET_ALIAS. Проверка добавления домена в группу индексов
#    # Создание домена данных 1
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Создание домена данных 2
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_2" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Создание домена данных 3
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_3" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс 1 через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/clients-dossier_1.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс 2 через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/clients-dossier_2.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс 3 через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/clients-dossier_3.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Добавление алиаса домену данных 1
#    * def request_kafka = call sendData '{ "body": { "action": "set_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Добавление алиаса домену данных 2
#    * def request_kafka = call sendData '{ "body": { "action": "set_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_2", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка поиска по группе индексов
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 12
#    * match each response.body.results[*].index == '#notnull'
#    # Проверка создания группы индексов
#    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": {"indices":[{ "name": "auto_1" },{ "name": "auto_2" }]}}
#    # Добавление алиаса домену данных 3
#    * def request_kafka = call sendData '{ "body": { "action": "set_alias", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_3", "alias": "' + alias_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка поиска по группе индексов
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/group/' + alias_id
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 18
#    * match each response.body.results[*].index == '#notnull'
#    # Проверка создания группы индексов
#    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/alias/' + alias_id
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": {"indices":[{ "name": "auto_1" },{ "name": "auto_2" },{ "name": "auto_3" }]}}
#    # Удаление созданного домена данных
#    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }



     # IDXS-T831 Consumer. DELETE_DOMAIN. Удаление индекса
  @TmsLink=IDXS-T831
  Scenario: IDXS-T831 Consumer. DELETE_DOMAIN. Удаление индекса
    # Создание домена данных 1
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Создание домена данных 2
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_2" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Создание домена данных 3
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_3" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response.body.domains[*].name == ["auto_1","auto_2","auto_3"]
    # Удаление домена данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response.body.domains[*].name == ["auto_2","auto_3"]
    # Удаление домена данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_2" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response.body.domains[*].name == ["auto_3"]
    # Удаление домена данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_3" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response contains { success: false }
    * match response.error.code == "PROJECT_NOT_FOUND"
    * match response.error.title == "Проект не найден"
    * match response.error.text == 'Проект [' + project_id + '] не найден'


     # IDXS-T842 Consumer. DELETE_RN. Проверка удаление проекта
  @TmsLink=IDXS-T842
  Scenario: IDXS-T842 Consumer. DELETE_RN. Проверка удаление проекта
    # Создание домена данных 1
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Создание домена данных 2
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_2" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Создание домена данных 3
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_3" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response.body.domains[*].name == ["auto_1","auto_2","auto_3"]
    # Удаление проекта данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{ "body": { "action": "delete_rn", "rn_id": "' + project_id + '" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка списка доменов данных
    Given path '/api/v2.1/projects/' + project_id + '/domains:list'
    * request
    When method GET
    Then status 200
    * match response contains { success: false }
    * match response.error.code == "PROJECT_NOT_FOUND"
    * match response.error.title == "Проект не найден"
    * match response.error.text == 'Проект [' + project_id + '] не найден'



#     # IDXS-T857 Consumer. BATCH. Проверка лимита загрузки документов в индекс
#  @TmsLink=IDXS-T857
#  Scenario: IDXS-T857 Consumer. BATCH. Проверка лимита загрузки документов в индекс
#    # Создание домена данных 1
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Загрузка документов в созданный индекс через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/1000docs.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 5000}
#    # Проверка поиска в домене данных
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_1/search'
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 1000
#    # Загрузка документов в созданный индекс 1 через Kafka
#    * def request_kafka = call sendData read ('classpath:test-data/upload_indices/indices_for_alias_kafka/1001docs.txt')
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка поиска в домене данных
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_1/search'
#    * request
#    """
#    {"size":1000}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == 1000
#    # Удаление созданного домена данных
#    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }


     # IDXS-T873 Consumer. Проверка аудита события при отправке запросов через Kafka
  @TmsLink=IDXS-T873
  Scenario: IDXS-T873 Consumer. Проверка аудита события при отправке запросов через Kafka
    # DOMAIN_CREATE
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"auto", "domain_name":"auto_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # LOAD_BATCH
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "auto", "domain_name": "auto_1", "documents": [ { "id": 1, "operation": "save", "fields": { "test": "example" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # DOMAIN_CREATE_WITH_ALIAS
    * def request_kafka = call sendData '{ "body": { "action": "create_domain_with_alias", "rn_id": "auto", "domain_name": "auto_2", "alias": "auto_alias"}, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # GROUP_CREATE
    * def request_kafka = call sendData '{ "body": { "action": "create_group", "rn_id": "auto", "alias": "auto_create_alias", "domains": [ { "name": "auto_1" }, { "name": "auto_2" } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # ALIAS_SET
    * def request_kafka = call sendData '{ "body": { "action": "set_alias", "rn_id": "auto", "domain_name": "auto_1", "alias": "auto_set_alias" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # ALIAS_DELETE
    * def request_kafka = call sendData '{ "body": { "action": "delete_domain_from_alias", "rn_id": "auto", "domain_name": "auto_1", "alias": "auto_set_alias" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # DOMAIN_DELETE
    * def request_kafka = call sendData '{ "body": { "action": "delete_domain", "rn_id": "auto", "domain_name": "auto_2" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # PROJECT_DELETE
    * def request_kafka = call sendData '{ "body": { "action": "delete_rn", "rn_id": "auto" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Задержка, чтобы события ушли в ФП Аудит
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 90000}
    # Авторизация в БД Аудита
    * def dbConfig = { username: #(DatabaseUser), password: #(DatabasePass), url: #(auditDatabaseUri), driverClassName: #(DatabaseDrv) }
    * def DbUtils = Java.type('db.DbUtils')
    * def db = new DbUtils(dbConfig)
    # Авторизация во второй БД Аудита
    * def secondTableSuffix = { username: #(DatabaseUser), password: #(DatabasePass), url: #(secondAuditDatabaseUri), driverClassName: #(DatabaseDrv), tableSuffix: #(secondTableSuffix) }
    * db.initDb(secondTableSuffix)
    # Проверка аудита запроса CREATE
    * def answer_db1 = db.readSortedRows("SELECT  DISTINCT(EVENT_CODE) FROM UFS_AUDIT_{tableSuffix}.AUDIT_EVENT WHERE EVENT_DATE_TIME > SYSDATE - INTERVAL '10' MINUTE AND IS_SUCCESS = '1' AND SUBSYSTEM_CODE = 'BFS_INDEX_SEARCH' AND SERVER_LOCATION = '" + serverPath + "' AND EAR_NAME = 'ufs-index-search-indexer' AND EAR_VERSION = 'R4.6.1' AND (EVENT_CODE = 'DOMAIN_CREATE' OR EVENT_CODE = 'LOAD_BATCH' OR EVENT_CODE = 'DOMAIN_DELETE' OR EVENT_CODE = 'PROJECT_DELETE' OR EVENT_CODE = 'GROUP_CREATE' OR EVENT_CODE = 'DOMAIN_CREATE_WITH_ALIAS' OR EVENT_CODE = 'ALIAS_SET' OR EVENT_CODE = 'ALIAS_DELETE')", "EVENT_CODE")
    * print answer_db1
    * match answer_db1 ==  [{"EVENT_CODE":"ALIAS_DELETE"},{"EVENT_CODE":"ALIAS_SET"},{"EVENT_CODE":"DOMAIN_CREATE"},{"EVENT_CODE":"DOMAIN_CREATE_WITH_ALIAS"},{"EVENT_CODE":"DOMAIN_DELETE"},{"EVENT_CODE":"GROUP_CREATE"},{"EVENT_CODE":"LOAD_BATCH"},{"EVENT_CODE":"PROJECT_DELETE"}]


     # IDXS-T845 Consumer. Проверка соблюдения порядка обработки сообщений через Kafka
  @TmsLink=IDXS-T845
  Scenario: IDXS-T845 Consumer. Проверка соблюдения порядка обработки сообщений через Kafka
    # Создание домена данных
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_1" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка документов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "documents": [ { "id": 1, "operation": "save", "fields": { "test": "example" } }, { "id": 2, "operation": "save", "fields": { "test": "example_2" } }, { "id": 3, "operation": "save", "fields": { "test": "пример" } }, { "id": 4, "operation": "save", "fields": { "test": "пример_2" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка поиска в домене данных
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_1/search'
    * request
    """
    {"query": "example","fields": ["*"]}
    """
    When method POST
    Then status 200
    * match response == { "success": true, "body": { "coverage": { "documents": 2, "full": true }, "results": [ { "id": "1", "ranking": 1.8828506, "fields": { "test": "example" } }, { "id": "2", "ranking": 1.6709665, "fields": { "test": "example_2" } } ] }}
    # Загрузка документов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "documents": [ { "id": 3, "operation": "partUpdate", "fields": { "test": "example_3" } }, { "id": 4, "operation": "partUpdate", "fields": { "test": "example_4" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка поиска в домене данных
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_1/search'
    * request
    """
    {"query": "example","fields": ["*"]}
    """
    When method POST
    Then status 200
    * match response == { "success": true, "body": { "coverage": { "documents": 4, "full": true }, "results": [ { "id": "1", "ranking": 1.5811061, "fields": { "test": "example" } }, { "id": "2", "ranking": 1.4492586, "fields": { "test": "example_2" } }, { "id": "3", "ranking": 1.4492586, "fields": { "test": "example_3" } }, { "id": "4", "ranking": 1.4492586, "fields": { "test": "example_4" } } ] } }
    # Загрузка документов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_1", "documents": [ { "id": 1, "operation": "save", "fields": { "test": "example" } }, { "id": 2, "operation": "delete", "fields": { "test": "example_2" } }, { "id": 3, "operation": "delete", "fields": { "test": "example_3" } }, { "id": 4, "operation": "delete", "fields": { "test": "example_4" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Проверка поиска в домене данных
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_1/search'
    * request
    """
    {"query": "example","fields": ["*"]}
    """
    When method POST
    Then status 200
    * match response == { "success": true, "body": { "coverage": { "documents": 1, "full": true }, "results": [ { "id": "1", "ranking": 1.4841912, "fields": { "test": "example" } } ] } }
    # Удаление созданного домена данных
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }



     # IDXS-T908 Consumer. Проверка добавления синонимов в индекс
  @TmsLink=IDXS-T908
  Scenario Outline: IDXS-T908 Consumer. Проверка добавления синонимов в индекс
    # Создание домена данных
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_synonyms" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка синонимов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch_synonyms", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон", "догонялки, прятки, салочки, войнушка", "Сбербанк, СберТех, СберМегаМаркет, СберМаркет, СберЗвук, СберВидео", "стол, стул, комод, шкаф, тумба, диван", "ноутбук, ноут, комп, компьютер, ЭВМ, лаптоп, laptop", "дуб, берёза, дерево, сосна, ива, каштан, ель, пихта, яблоня, груша", "разработчик, тестировщик, аналитик, девопсер, дата-сатанист, владелец продукта, лидер", "красный, бурый, бордовый, багровый", "1, 90", "2021-10-20T23:10:30Z, 2000-02-01T23:10:30Z, 2222-02-01T23:10:30Z"] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка документов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_synonyms", "documents": [ { "id": "0001", "operation": "save", "fields": { "technic": "Ноут", "furniture": "стол, стул", "companies": "Сбертех", "trees": "Дуб", "specialists": "лидер разработчик", "games": "Прятки", "sports": "Футбол", "colors": "Багровый красный", "age": 1, "phrases": "Шёл по лесу и увидел дуб" } }, { "id": "0002", "operation": "save", "fields": { "technic": "Комп", "furniture": "Диван", "companies": "Сбертехи", "trees": "Дубы", "specialists": "Тестировщик", "games": "Догонялки", "sports": "Баскетбол", "colors": "Багровый", "age": "1", "phrases": "На холме росла высокая липа" } }, { "id": "0003", "operation": "save", "fields": { "technic": "Компутер", "furniture": "Комод", "companies": "Сбербанк", "trees": "Берёза", "specialists": "уборщик", "games": "Войнушки", "sports": "Футбол, баскетбол", "colors": "Красный", "age": 90, "phrases": "Проходя мимо дерева не забудь сказать ива" } }, { "id": "0004", "operation": "save", "fields": { "technic": "Планшет", "furniture": "Комод и стул", "companies": "Сберзвук", "trees": "Ива", "specialists": "Тестер", "games": "Войнушка", "sports": "Пинг-понг", "colors": "Бурый", "age": "90", "phrases": "Берёза достигает в высоту небывалых размеров" } }, { "id": "0005", "operation": "save", "fields": { "technic": "Лаптоп", "furniture": "Барная стойка", "companies": "СберВидео", "trees": "Каштан", "specialists": "Владелец продукта", "games": "Догоняйки", "sports": "Гольф", "colors": "Зелёный", "age": -1, "phrases": "Дуб достигает в высоту небывалых размеров" } }, { "id": "0006", "operation": "save", "fields": { "technic": "Laptop", "furniture": "Шкаф шкаф и ещё раз шкаф", "companies": "СберДруг", "trees": "Боярышник", "specialists": "дата-сатанист", "games": "Вышибалы", "sports": "Настольный теннис", "colors": "Бордовый", "age": 2130, "phrases": "Фикус так-то забавный предмет. Вроде он дерево, а вроде и нет" } }, { "id": "0007", "operation": "save", "fields": { "technic": "laptOp", "furniture": "Столы", "companies": "СберАналитика", "trees": "Липа", "specialists": "Аналитик", "games": "Вышибалы", "sports": "Футболы", "colors": "Бордовый бурый", "age": 999, "phrases": "Какие-то неправильные пчёлы растут на вашем Дубе" } }, { "id": "0008", "operation": "save", "fields": { "technic": "ноУТБУки", "furniture": "Стулья", "companies": "СберМобайл", "trees": "Елка", "specialists": "Девопёс", "games": "Вышибалы", "sports": "Легкая атлетика", "colors": "Жёлтый", "age": 1.91, "phrases": "Гарри Поттер впаялся в плакучую Иву" } }, { "id": "0009", "operation": "save", "fields": { "technic": "ЭВМ", "furniture": "Стол", "companies": "СберБанк Онлайн", "trees": "Сирень", "specialists": "Стажёр", "games": "Вышибалы", "sports": "Гандбол", "colors": "Сиреневый", "age": 3213, "phrases": "В офисе стоял аромат свежесорванной Сирени" } }, { "id": "0010", "operation": "save", "fields": { "technic": "Телевизор", "furniture": "Табурет", "companies": "Сберегательный банк", "trees": "Фикус", "specialists": "Джун", "games": "Вышибалы", "sports": "Гандбол", "colors": "Фиолетовый", "age": 439, "phrases": "Осьминоги такие создания, что если увидят фикус, то сразу ничего не делают" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Запрос информации о домене данных
    Given path '/api/v2.1/projects/' + project_id + '/domains/' + domain_id + '_synonyms'
    * request
    When method GET
    Then status 200
    * match response contains { success: true }
    * match response.body.id == '#regex [a-z,A-Z,0-9]{7}'
    * def created = get response.body.createdAt
    * def createdAt = created + ''
    * match createdAt ==  '#regex [0-9]{13}'
    * match response.body.synonyms[*] == ["футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон", "догонялки, прятки, салочки, войнушка", "Сбербанк, СберТех, СберМегаМаркет, СберМаркет, СберЗвук, СберВидео", "стол, стул, комод, шкаф, тумба, диван", "ноутбук, ноут, комп, компьютер, ЭВМ, лаптоп, laptop", "дуб, берёза, дерево, сосна, ива, каштан, ель, пихта, яблоня, груша", "разработчик, тестировщик, аналитик, девопсер, дата-сатанист, владелец продукта, лидер", "красный, бурый, бордовый, багровый", "1, 90", "2021-10-20T23:10:30Z, 2000-02-01T23:10:30Z, 2222-02-01T23:10:30Z"]
    # Проверка поиска в домене данных
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_synonyms/search'
    * request
    """
    {"query": "<query>","fields": ["*"]}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == <docs>
    # Удаление созданного домена данных
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }
    Examples:
      | query   | docs |
      | Сбертех | 6    |



     # IDXS-T909 Consumer. Проверка удаления синонимов из индекса
  @TmsLink=IDXS-T909
  Scenario Outline: IDXS-T909 Consumer. Проверка удаления синонимов из индекса
    # Создание домена данных
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '_synonyms" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка синонимов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch_synonyms", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон", "догонялки, прятки, салочки, войнушка", "Сбербанк, СберТех, СберМегаМаркет, СберМаркет, СберЗвук, СберВидео", "стол, стул, комод, шкаф, тумба, диван", "ноутбук, ноут, комп, компьютер, ЭВМ, лаптоп, laptop", "дуб, берёза, дерево, сосна, ива, каштан, ель, пихта, яблоня, груша", "разработчик, тестировщик, аналитик, девопсер, дата-сатанист, владелец продукта, лидер", "красный, бурый, бордовый, багровый", "1, 90", "2021-10-20T23:10:30Z, 2000-02-01T23:10:30Z, 2222-02-01T23:10:30Z"] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка документов в домен данных
    * def request_kafka = call sendData '{ "body": { "action": "batch", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_synonyms", "documents": [ { "id": "0001", "operation": "save", "fields": { "technic": "Ноут", "furniture": "стол, стул", "companies": "Сбертех", "trees": "Дуб", "specialists": "лидер разработчик", "games": "Прятки", "sports": "Футбол", "colors": "Багровый красный", "age": 1, "phrases": "Шёл по лесу и увидел дуб" } }, { "id": "0002", "operation": "save", "fields": { "technic": "Комп", "furniture": "Диван", "companies": "Сбертехи", "trees": "Дубы", "specialists": "Тестировщик", "games": "Догонялки", "sports": "Баскетбол", "colors": "Багровый", "age": "1", "phrases": "На холме росла высокая липа" } }, { "id": "0003", "operation": "save", "fields": { "technic": "Компутер", "furniture": "Комод", "companies": "Сбербанк", "trees": "Берёза", "specialists": "уборщик", "games": "Войнушки", "sports": "Футбол, баскетбол", "colors": "Красный", "age": 90, "phrases": "Проходя мимо дерева не забудь сказать ива" } }, { "id": "0004", "operation": "save", "fields": { "technic": "Планшет", "furniture": "Комод и стул", "companies": "Сберзвук", "trees": "Ива", "specialists": "Тестер", "games": "Войнушка", "sports": "Пинг-понг", "colors": "Бурый", "age": "90", "phrases": "Берёза достигает в высоту небывалых размеров" } }, { "id": "0005", "operation": "save", "fields": { "technic": "Лаптоп", "furniture": "Барная стойка", "companies": "СберВидео", "trees": "Каштан", "specialists": "Владелец продукта", "games": "Догоняйки", "sports": "Гольф", "colors": "Зелёный", "age": -1, "phrases": "Дуб достигает в высоту небывалых размеров" } }, { "id": "0006", "operation": "save", "fields": { "technic": "Laptop", "furniture": "Шкаф шкаф и ещё раз шкаф", "companies": "СберДруг", "trees": "Боярышник", "specialists": "дата-сатанист", "games": "Вышибалы", "sports": "Настольный теннис", "colors": "Бордовый", "age": 2130, "phrases": "Фикус так-то забавный предмет. Вроде он дерево, а вроде и нет" } }, { "id": "0007", "operation": "save", "fields": { "technic": "laptOp", "furniture": "Столы", "companies": "СберАналитика", "trees": "Липа", "specialists": "Аналитик", "games": "Вышибалы", "sports": "Футболы", "colors": "Бордовый бурый", "age": 999, "phrases": "Какие-то неправильные пчёлы растут на вашем Дубе" } }, { "id": "0008", "operation": "save", "fields": { "technic": "ноУТБУки", "furniture": "Стулья", "companies": "СберМобайл", "trees": "Елка", "specialists": "Девопёс", "games": "Вышибалы", "sports": "Легкая атлетика", "colors": "Жёлтый", "age": 1.91, "phrases": "Гарри Поттер впаялся в плакучую Иву" } }, { "id": "0009", "operation": "save", "fields": { "technic": "ЭВМ", "furniture": "Стол", "companies": "СберБанк Онлайн", "trees": "Сирень", "specialists": "Стажёр", "games": "Вышибалы", "sports": "Гандбол", "colors": "Сиреневый", "age": 3213, "phrases": "В офисе стоял аромат свежесорванной Сирени" } }, { "id": "0010", "operation": "save", "fields": { "technic": "Телевизор", "furniture": "Табурет", "companies": "Сберегательный банк", "trees": "Фикус", "specialists": "Джун", "games": "Вышибалы", "sports": "Гандбол", "colors": "Фиолетовый", "age": 439, "phrases": "Осьминоги такие создания, что если увидят фикус, то сразу ничего не делают" } } ] }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Запрос информации о домене данных
    Given url indexerBaseUri +'/api/v2.1/projects/' + project_id + '/domains/' + domain_id + '_synonyms'
    * request
    When method GET
    Then status 200
    * match response contains { success: true }
    * match response.body.id == '#regex [a-z,A-Z,0-9]{7}'
    * def created = get response.body.createdAt
    * def createdAt = created + ''
    * match createdAt ==  '#regex [0-9]{13}'
    * match response.body.synonyms[*] == ["футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон", "догонялки, прятки, салочки, войнушка", "Сбербанк, СберТех, СберМегаМаркет, СберМаркет, СберЗвук, СберВидео", "стол, стул, комод, шкаф, тумба, диван", "ноутбук, ноут, комп, компьютер, ЭВМ, лаптоп, laptop", "дуб, берёза, дерево, сосна, ива, каштан, ель, пихта, яблоня, груша", "разработчик, тестировщик, аналитик, девопсер, дата-сатанист, владелец продукта, лидер", "красный, бурый, бордовый, багровый", "1, 90", "2021-10-20T23:10:30Z, 2000-02-01T23:10:30Z, 2222-02-01T23:10:30Z"]
    # Проверка поиска в домене данных
    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_synonyms/search'
    * request
    """
    {"query": "<query>","fields": ["*"]}
    """
    When method POST
    Then status 200
    * match response contains { success: true }
    * match response.body.coverage.documents == <docs_with_synonyms>
    # Удаление синонимов из домена данных
    * def request_kafka = call sendData '{ "body": { "action": "batch_synonyms", "rn_id": "' + project_id + '", "domain_name": "' + domain_id + '_synonyms", "operation": "delete"}, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Запрос информации о домене данных
    Given url indexerBaseUri + '/api/v2.1/projects/' + project_id + '/domains/' + domain_id + '_synonyms'
    * request
    When method GET
    Then status 200
    * match response contains { success: true }
    * match response.body.id == '#regex [a-z,A-Z,0-9]{7}'
    * def created = get response.body.createdAt
    * def createdAt = created + ''
    * match createdAt ==  '#regex [0-9]{13}'
    * match response.body.synonyms[*] == []
#    # Проверка поиска в домене данных
#    Given url proxyBaseUri + '/api/v2/projects/' + project_id + '/domains/' + domain_id + '_synonyms/search'
#    * request
#    """
#    {"query": "<query>","fields": ["*"]}
#    """
#    When method POST
#    Then status 200
#    * match response contains { success: true }
#    * match response.body.coverage.documents == <docs_without_synonyms>
    # Удаление созданного домена данных
    * configure afterScenario = function(){ karate.call('classpath:globals_features/glob_remove_project.feature'); }
    Examples:
      | query   | docs_with_synonyms | docs_without_synonyms |
      | Сбертех | 6                  | 3                     |



#     # IDXS-T836 Consumer. CREATE_domain. Проверка валидации {schema} (\, /, *, ?, ", <, >, |, (запятая), #, :, $, @, ` ` (пробел))
#  @TmsLink=IDXS-T836
#  Scenario Outline: IDXS-T836 Consumer. CREATE_domain. Проверка валидации {schema}
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"<project_id>", "domain_name":"auto" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания домена
#    Given url indexerBaseUri + '/api/v2.1/projects/<project_id>/domains/auto/exist'
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": { "exist": true } }
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"<project_id>", "domain_name":"auto" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка удаления домена
#    Given url indexerBaseUri + '/api/v2.1/projects/<project_id>/domains/auto/exist'
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": { "exist": false } }
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/positive_project.csv') |

#     # IDXS-T837 Consumer. CREATE_domain. Проверка валидации {name} (\, /, *, ?, ", <, >, |, (запятая), #, :, $, @, ` ` (пробел))
#  @TmsLink=IDXS-T837
#  Scenario Outline: IDXS-T837 Consumer. CREATE_domain. Проверка валидации {name}
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"auto", "domain_name":"<domain_id>" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания домена
#    Given url indexerBaseUri + '/api/v2.1/projects/auto/domains/<domain_id>/exist'
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": { "exist": true } }
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"auto", "domain_name":"<domain_id>" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка удаления домена
#    Given url indexerBaseUri + '/api/v2.1/projects/auto/domains/<domain_id>/exist'
#    * request
#    When method GET
#    Then status 200
#    * match response == { "success": true, "body": { "exist": false } }
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/positive_domain.csv') |

#    # IDXS-T833 Consumer. CREATE_domain. Проверка валидации {name} и {schema} (120 символов)
#    # IDXS-T834 Consumer. CREATE_domain. Проверка валидации {name} и {schema} (начинается с -,_,+,.)
#    # IDXS-T838 Consumer. CREATE_domain. Проверка валидации {schema} и {name} (а-я, А-Я, A-Z)
#  Scenario Outline: KAFKA  Создание домена. Негатив project_id. T833, T834, T838
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"<project_id>", "domain_name":"auto" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания домена
#    Given url elasticBaseUri + '_cat/indices'
#    * header Authorization = call read('classpath:globals_js/elastic-authIDXS.js')
#    * request
#    When method GET
#    Then status 200
#    * match response !contains '$<project_id>$'
#    @TmsLink=IDXS-T833
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_project_for_ALPHA_120symb.csv') |
#    @TmsLink=IDXS-T834
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_project_for_ALPHA-_+.csv') |
#    @TmsLink=IDXS-T838
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_project_for_ALPHA.csv') |
#
#    # IDXS-T833 Consumer. CREATE_domain. Проверка валидации {name} и {schema} (120 символов)
#    # IDXS-T834 Consumer. CREATE_domain. Проверка валидации {name} и {schema} (начинается с -,_,+,.)
#    # IDXS-T838 Consumer. CREATE_domain. Проверка валидации {schema} и {name} (а-я, А-Я, A-Z)
#  Scenario Outline: KAFKA  Создание домена. Негатив domain. T833, T834, T838
#    # Отправка запроса в Kafka Synapse
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"auto", "domain_name":"<domain_id>" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
#    # Проверка создания домена
#    Given url elasticBaseUri + '_cat/indices'
#    * header Authorization = call read('classpath:globals_js/elastic-authIDXS.js')
#    * request
#    When method GET
#    Then status 200
#    * match response !contains '$<domain_id>$'
#    @TmsLink=IDXS-T833
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_domain_for_ALPHA_120symb.csv') |
#    @TmsLink=IDXS-T834
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_domain_for_ALPHA-_+.csv') |
#    @TmsLink=IDXS-T838
#    Examples:
#      | read('classpath:test-data/ufs-index-search-indexer/create_indices_validation/negative_domain_for_ALPHA.csv') |


#     # IDXS-T839 Producer. CREATE/DELETE. Проверка отправки ошибок в топик Kafka
#  @TmsLink=IDXS-T839
#  Scenario: IDXS-T839 Producer. CREATE/DELETE. Проверка отправки ошибок в топик Kafka
#  # Создание домена данных
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Повторное создание домена данных
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-description:Domain [' + domain_id + '] in [' + project_id + '] project already exists'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Удаление домена данных
#    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Повторное удаление домена данных
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOMAIN_NOT_FOUND'
#    * match error_message_kafka contains 'dlt-exception-description:Domain or project not found.'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Cоздание домена данных c некорректным именем
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '_Bad_request", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-description:Name [' + project_id + '_Bad_request] is invalid'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '_Bad_request", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#
#
#
#     # IDXS-T841 Producer. BATCH. Проверка отправки ошибок по загрузке документов в топик Kafka
#  @TmsLink=IDXS-T841
#  Scenario: IDXS-T841 Producer. BATCH. Проверка отправки ошибок по загрузке документов в топик Kafka
#  # Загрузка валидного документа в несуществующий домен
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_valid.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOMAIN_NOT_FOUND'
#    * match error_message_kafka contains 'dlt-exception-description:Domain or project not found.'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_valid.txt')
#  # Создание домена данных
#    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Загрузка документа без поля ID
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_without_id.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOCUMENT_ID_IS_NULL'
#    * match error_message_kafka contains 'dlt-exception-description:Document 0 incorrect. Id is null or blank'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_without_id.txt')
#  # Загрузка документа без поля OPERATION
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_without_operation.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOCUMENT_OPERATION_IS_NULL'
#    * match error_message_kafka contains 'dlt-exception-description:Document 0 incorrect. Operation is null or blank'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_without_operation.txt')
#  # Загрузка документа без поля FIELDS
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_without_fields.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOCUMENT_FIELD_IS_NULL'
#    * match error_message_kafka contains 'dlt-exception-description:Document 0 incorrect. Field is null or empty'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_without_fields.txt')
#  # Загрузка документа с ID > 512 символов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_id_more_512.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOCUMENT_ID_IS_TOO_LONG'
#    * match error_message_kafka contains 'dlt-exception-description:Document 0 incorrect. Id is too long, must be no longer than 512 bytes'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_id_more_512.txt')
#  # Загрузка документа с глубиной подполей более 16
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_deep_more_16.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:TOO_DEEP_DOCUMENT'
#    * match error_message_kafka contains 'dlt-exception-description:Document [0] is too deep. Max: 16'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_deep_more_16.txt')
#  # Загрузка документов с 100 уникальными полями
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_100_unique_fields.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:TOO_MANY_FIELDS'
#    * match error_message_kafka contains 'dlt-exception-description:BatchErrorDocuments'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_100_unique_fields.txt')
#  # Удаление домена данных
#    * def request_kafka = call sendData '{"body" : { "action" : "delete_domain", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Загрузка 1001 документов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/batch/batch_1001_docs.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:REQUEST_SIZE_EXCEEDED'
#    * match error_message_kafka contains 'dlt-exception-description:Request size exceeded. Limit [1000]'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/batch/batch_1001_docs.txt')



#     # IDXS-T840 Producer. VALIDATION. Проверка отправки валидационных ошибок в топик Kafka
#  @TmsLink=IDXS-T840
#  Scenario: IDXS-T840 Producer. VALIDATION. Проверка отправки валидационных ошибок в топик Kafka
#  # Некорректное поле action
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "test", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:PARSING_OBJECT'
#    * match error_message_kafka contains 'dlt-exception-description:Action [test] is invalid'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "test", "rn_id" :"' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Некорректное имя проекта
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "create_domain", "rn_id" :"_' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_' + project_id + '] is invalid'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "create_domain", "rn_id" :"_' + project_id + '", "domain_name":"' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Некорректное имя домена
#    * def request_kafka = call sendDelayedData '{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"_' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_' + domain_id + '] is invalid'
#    * match error_message_kafka contains 'dlt-original-body:{"body" : { "action" : "create_domain", "rn_id" :"' + project_id + '", "domain_name":"_' + domain_id + '" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'


#     # IDXS-T867 Producer. CREATE_GROUP. Проверка отправки ошибок в топик Kafka
#  @TmsLink=IDXS-T867
#  Scenario: IDXS-T867 Producer. CREATE_GROUP. Проверка отправки ошибок в топик Kafka
#  # Некорректное имя проекта
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_group/create_group_invalid_project_name.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_group/create_group_invalid_project_name.txt')
#  # Некорректное имя "группы индексов"
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_group/create_group_invalid_alias_name.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_group/create_group_invalid_alias_name.txt')
#  # Создание группы с несуществующим доменом
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_group/create_group_wint_notexist_domain.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOMAIN_NOT_FOUND'
#    * match error_message_kafka contains 'dlt-exception-description:Domain or project not found.'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_group/create_group_wint_notexist_domain.txt')


#     # IDXS-T868 Producer. SET_ALIAS. Проверка отправки ошибок в топик Kafka
#  @TmsLink=IDXS-T868
#  Scenario: IDXS-T868 Producer. SET_ALIAS. Проверка отправки ошибок в топик Kafka
#  # Некорректное имя проекта
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_project.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_project.txt')
#  # Некорректное имя домена
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_domain.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_domain.txt')
#  # Некорректное имя "группы" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_alias.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto_alias] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/set_alias/set_alias_invalid_alias.txt')
##  # Добавление алиаса несуществующему домену
##    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/set_alias/set_alias_nonexist_domain.txt')
##  # Вычитать сообщение из топика с ошибками
##    * string error_message_kafka = call receiveData
##    * match error_message_kafka contains 'dlt-exception-code:DOMAIN_NOT_FOUND'
##    * match error_message_kafka contains 'dlt-exception-description:Domain or project not found.'
##    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/set_alias/set_alias_nonexist_domain.txt')



#     # IDXS-T869 Producer. CREATE_DOMAIN_WITH_ALIAS. Проверка отправки ошибок в топик Kafka
#  @TmsLink=IDXS-T869
#  Scenario: IDXS-T869 Producer. CREATE_DOMAIN_WITH_ALIAS. Проверка отправки ошибок в топик Kafka
#  # Создание домена с "группой" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_exist_domain.txt')
#  # Повторное создание домена с "группой" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_exist_domain.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:DOMAIN_EXISTS'
#    * match error_message_kafka contains 'dlt-exception-description:Domain [auto] in [auto] project already exists'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_exist_domain.txt')
#  # Некорректное имя проекта
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_project.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_project.txt')
#  # Некорректное имя домена
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_domain.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_domain.txt')
#  # Некорректное имя "группы" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_alias.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto_alias] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/create_domain_with_release/cdwa_invalid_alias.txt')

#     # IDXS-T870 Producer. DELETE_ALIAS. Проверка отправки ошибок в топик Kafka
#  @TmsLink=IDXS-T870
#  Scenario: IDXS-T870 Producer. DELETE_ALIAS. Проверка отправки ошибок в топик Kafka
#  # Некорректное имя проекта
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_project.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_project.txt')
#  # Некорректное имя домена
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_domain.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_domain.txt')
#  # Некорректное имя "группы" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_alias.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:INVALID_NAME'
#    * match error_message_kafka contains 'dlt-exception-description:Name [_auto_alias] is invalid'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_invalid_alias.txt')
#  # Удаление домена из несуществующей "группы" индексов
#    * def request_kafka = call sendDelayedData read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_nonexist_project.txt')
#  # Вычитать сообщение из топика с ошибками
#    * string error_message_kafka = call receiveData
#    * match error_message_kafka contains 'dlt-exception-code:PROJECT_NOT_FOUND'
#    * match error_message_kafka contains 'dlt-exception-description:Project auto is not found'
#    * match error_message_kafka contains read ('classpath:test-data/Kafka/producer/delete_alias/delete_alias_nonexist_project.txt')
