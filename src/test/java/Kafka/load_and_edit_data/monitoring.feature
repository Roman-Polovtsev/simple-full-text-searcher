@indexer @kafka
Feature: Индексированный поиск. Проверка взаимодействия с Kafka Synapse. Мониторинг

  Background:
    * configure connectTimeout = 15000
    # Для отправки запросов в Kafka Synapse
    * def properties = { topicName: #(topicName), bootstrapAddress: #(kafkaBootstrapAddress), trustStoreLocation: #(trustStoreLocation), trustStorePassword: #(trustStorePassword), keyStoreLocation: #(keyStoreLocation), keyStorePassword: #(keyStorePassword) }
    * def KafkaConfig = Java.type('tests.Kafka.producer.KafkaConfig');
    * def config = new KafkaConfig(properties);
    * def sendData =
      """
      function(data) {
        var KafkaProducer = Java.type('tests.Kafka.producer.CustomKafkaProducer');
        var kp = new KafkaProducer(config);
        kp.send(data);
      }
      """
    # Использование по дефолту эндпоинта Indexer
    * url indexerBaseUri
    # Использование по дефолту таких имён для переменных проекта и домена
    * def project_id = 'auto'
    * def domain_id = 'auto'
    * def alias_id = 'auto_alias'
    * def data = 'clients-dossier'
    # Пост-условие. Удаление тестового проекта данных
    * configure afterFeature = function(){ karate.call('classpath:glob_remove_project.feature'); }


    # IDXS-T880 Проверка Kafka метрик запроса "Создание домена данных" (В ELK и БД ФП Мониторинг)
    # IDXS-T876 Проверка Kafka метрик запроса "Создание индекса с алиасом" (В ELK и БД ФП Мониторинг)
    # IDXS-T878 Проверка Kafka метрик запроса "Создание группы индексов" (В ELK и БД ФП Мониторинг)
    # IDXS-T884 Проверка Kafka метрик запроса "Загрузка документов в домен" (В ELK и БД ФП Мониторинг)
    # IDXS-T875 Проверка Kafka метрик запроса "Добавление алиаса индексу" (В ELK и БД ФП Мониторинг)
    # IDXS-T874 Проверка Kafka метрик запроса "Удаление алиаса из группы" (В ELK и БД ФП Мониторинг)
    # IDXS-T882 Проверка Kafka метрик запроса "Удаление домена данных" (В ELK и БД ФП Мониторинг)
    # IDXS-T883 Проверка Kafka метрик запроса "Удаление проекта" (В ELK и БД ФП Мониторинг)
  Scenario Outline: Метрики Indexer (в ELK ФП Мониторинг). Кафка
    # Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '<body>, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    @TmsLink=IDXS-T880
    Examples:
      | body                                                                                              |
      | {"body" : { "action" : "create_domain", "rn_id" :"auto_kafka", "domain_name":"auto_create" }      |
      | {"body" : { "action" : "create_domain", "rn_id" :"auto_kafka", "domain_name":"auto_create_Fail" } |
      | {"body" : { "action" : "create_domain_with_alias", "rn_id" :"auto_kafka", "domain_name":"auto_cdwa","alias": "auto_alias" }      |
      | {"body" : { "action" : "create_domain_with_alias", "rn_id" :"auto_kafka", "domain_name":"auto_cdwa_Fail","alias": "auto_alias" } |
    @TmsLink=IDXS-T878
    Examples:
      | body                                                                                                                                       |
      | {"body" : { "action" : "create_group", "rn_id" :"auto_kafka", "alias":"auto_group_alias" , "domains": [ { "name": "auto_create" } ] }      |
      | {"body" : { "action" : "create_group", "rn_id" :"auto_kafka", "alias":"auto_group_alias_Fail" , "domains": [ { "name": "auto_create" } ] } |
    @TmsLink=IDXS-T884
    Examples:
      | body                                                                                                                                                                          |
      | {"body" : { "action" : "batch", "rn_id" :"auto_kafka", "domain_name":"auto_create", "documents":  [ { "id": 1, "operation": "save", "fields": { "test": "example" } } ] }     |
      | {"body" : { "action" : "batch", "rn_id" :"auto_kafka", "domain_name":"auto_create_Fail", "documents": [ { "id": 1, "operation": "save", "fields": { "test": "example" } } ] } |
      | {"body" : { "action" : "set_alias", "rn_id" :"auto_kafka", "domain_name":"auto_create", "alias": "auto_set_alias"  }      |
      | {"body" : { "action" : "set_alias", "rn_id" :"auto_kafka", "domain_name":"auto_create_Fail", "alias": "auto_set_alias"  } |
    @TmsLink=IDXS-T874
    Examples:
      | body                                                                                                                                     |
      | {"body" : { "action" : "delete_domain_from_alias", "rn_id" :"auto_kafka", "domain_name":"auto_create", "alias": "auto_set_alias"  }      |
      | {"body" : { "action" : "delete_domain_from_alias", "rn_id" :"auto_kafka", "domain_name":"auto_create_Fail", "alias": "auto_set_alias"  } |
    @TmsLink=IDXS-T882
    Examples:
      | body                                                                                           |
      | {"body" : { "action" : "delete_domain", "rn_id" :"auto_kafka", "domain_name":"auto_cdwa"}      |
      | {"body" : { "action" : "delete_domain", "rn_id" :"auto_kafka", "domain_name":"auto_cdwa_Fail"} |
    @TmsLink=IDXS-T883
    Examples:
      | body                                                            |
      | {"body" : { "action" : "delete_rn", "rn_id" :"auto_kafka"}      |
      | {"body" : { "action" : "delete_rn", "rn_id" :"auto_kafka_Fail"} |
      # Задержка
  Scenario: Метрики Indexer (в ELK ФП Мониторинг). Кафка
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 120000}
      # Проверка метрик
  Scenario Outline: Метрики Indexer (в ELK ФП Мониторинг). Кафка
    # Проверка метрики KAFKA_REQUEST_RECEIVED
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<1_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<1_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<2_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<2_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS_DURATION/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<3_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<3_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    @TmsLink=IDXS-T880
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION        | PROJECT_ID | DOMAIN           | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | create_domain | auto_kafka | auto_create      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | create_domain | auto_kafka | auto_create_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | create_domain_with_alias | auto_kafka | auto_cdwa      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | create_domain_with_alias | auto_kafka | auto_cdwa_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
    @TmsLink=IDXS-T884
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION | PROJECT_ID | DOMAIN           | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | batch  | auto_kafka | auto_create      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | batch  | auto_kafka | auto_create_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | set_alias | auto_kafka | auto_create      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | set_alias | auto_kafka | auto_create_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
    @TmsLink=IDXS-T874
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION                   | PROJECT_ID | DOMAIN           | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | delete_domain_from_alias | auto_kafka | auto_create      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | delete_domain_from_alias | auto_kafka | auto_create_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
    @TmsLink=IDXS-T882
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION        | PROJECT_ID | DOMAIN         | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | delete_domain | auto_kafka | auto_cdwa      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | delete_domain | auto_kafka | auto_cdwa_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
      # Проверка метрик
  Scenario Outline: Метрики Indexer (в ELK ФП Мониторинг). Кафка
    # Проверка метрики KAFKA_REQUEST_RECEIVED
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<1_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<1_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<2_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<2_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS_DURATION/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<3_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<3_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    @TmsLink=IDXS-T878
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION       | PROJECT_ID | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | create_group | auto_kafka | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | create_group | auto_kafka | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
    @TmsLink=IDXS-T883
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION    | PROJECT_ID      | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | delete_rn | auto_kafka      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | delete_rn | auto_kafka_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |





     # IDXS-T939 Проверка аудита события "Добавление и удаление синонимов" при отправке запросов через Kafka
  @TmsLink=IDXS-T939
  Scenario Outline: IDXS-T939 Проверка аудита события Добавление и удаление синонимов при отправке запросов через Kafka
     # Создание домена данных
    * def request_kafka = call sendData '{"body" : { "action" : "create_domain", "rn_id" :"auto", "domain_name":"auto_synonyms" }, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Загрузка синонимов в домен данных
    * def request_kafka = call sendData '<body>, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    # Удаление проекта данных. Отправка запроса в Kafka Synapse
    * def request_kafka = call sendData '{ "body": { "action": "delete_rn", "rn_id": "auto" }, "header": { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule": "Код АС-источника события", "evtID": "Уникальный идентификатор события", "evtDate": "Время возникновения события", "sndDate": "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника" } }'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    Examples:
      | body                                                                                                                                                                                                         |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto", "domain_name": "auto_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон"]}      |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto", "domain_name": "auto_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон"]} |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto", "domain_name": "auto_synonyms", "operation": "delete"}                                                                                              |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto", "domain_name": "auto_synonyms_Fail", "operation": "delete"}                                                                                         |
      # Задержка
  Scenario: IDXS-T939 Проверка аудита события Добавление и удаление синонимов при отправке запросов через Kafka
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 120000}
      # Проверка метрик
  Scenario Outline: IDXS-T939 Проверка аудита события Добавление и удаление синонимов при отправке запросов через Kafka
    # Авторизация в БД Аудита
    * def dbConfig = { username: #(DatabaseUser), password: #(DatabasePass), url: #(auditDatabaseUri), driverClassName: #(DatabaseDrv) }
    * def DbUtils = Java.type('db.DbUtils')
    * def db = new DbUtils(dbConfig)
    # Авторизация во второй БД Аудита
    * def secondTableSuffix = { username: #(DatabaseUser), password: #(DatabasePass), url: #(secondAuditDatabaseUri), driverClassName: #(DatabaseDrv), tableSuffix: #(secondTableSuffix) }
    * db.initDb(secondTableSuffix)
    # Проверка аудита
    * def answer_db1 = db.readRows("SELECT  EVENT_CODE, PARAMS, CRITICAL, IS_SUCCESS  FROM UFS_AUDIT_{tableSuffix}.AUDIT_EVENT WHERE EVENT_DATE_TIME > SYSDATE - INTERVAL '10' MINUTE AND IS_SUCCESS = '<is_success>' AND SUBSYSTEM_CODE = 'BFS_INDEX_SEARCH' AND SERVER_LOCATION = '" + serverPath + "' AND EAR_NAME = 'ufs-index-search-indexer' AND EAR_VERSION = '<earVersion>' AND EVENT_CODE = '<eventCode>' AND CRITICAL = '<critical>' AND PARAMS like '<params>'")
    * print answer_db1
    * match answer_db1[0] == {"EVENT_CODE":"<eventCode>","PARAMS":"<params>","CRITICAL":"<critical>","IS_SUCCESS":<is_success>}
    Examples:
      | eventCode           | params                                                                                                                           | earVersion | critical   | is_success |
      | LOAD_BATCH_SYNONYMS | {\"PROJECT_ID\":\"auto\",\"DOMAIN\":\"auto_synonyms\",\"COUNTS_BECOME\":\"1\",\"OPERATION\":\"partSave\",\"COUNTS_WAS\":\"0\"}   | R4.6.1     | UNCRITICAL | 1          |
      | LOAD_BATCH_SYNONYMS | {\"PROJECT_ID\":\"auto\",\"DOMAIN\":\"auto_synonyms\",\"COUNTS_BECOME\":\"0\",\"OPERATION\":\"delete\",\"COUNTS_WAS\":\"0\"}     | R4.6.1     | UNCRITICAL | 1          |
      | LOAD_BATCH_SYNONYMS | {\"DOMAIN\":\"auto_synonyms_Fail\",\"DESCRIPTION\":\"Недопустимое название\",\"OPERATION\":\"partSave\",\"PROJECT_ID\":\"auto\"} | R4.6.1     | UNCRITICAL | 0          |
      | LOAD_BATCH_SYNONYMS | {\"DOMAIN\":\"auto_synonyms_Fail\",\"DESCRIPTION\":\"Недопустимое название\",\"OPERATION\":\"delete\",\"PROJECT_ID\":\"auto\"}   | R4.6.1     | UNCRITICAL | 0          |



     # IDXS-T910 Проверка Kafka метрик запроса "Добавление и удаление синонимов" (В БД ФП Мониторинг)
  @TmsLink=IDXS-T910
  Scenario Outline: IDXS-T910 Проверка Kafka метрик запроса Добавление и удаление синонимов (В ELK и БД ФП Мониторинг)
    # Создание домена данных
    * def request_kafka = call sendData '<body>, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    Examples:
      | body                                                                                                                                                                                                                      |
      # Успешные запросы
      | {"body" : { "action" : "create_domain", "rn_id" :"auto_kafka", "domain_name":"auto_load_synonyms" }                                                                                                                       |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] }      |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "delete" }                                                                                               |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] }      |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "delete" }                                                                                               |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] }      |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "delete" }                                                                                               |
      | {"body": {"action": "delete_rn","rn_id": "auto_kafka"}                                                                                                                                                                    |
      # Фейловые запросы
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] } |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "delete" }                                                                                          |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] } |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "delete" }                                                                                          |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] } |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "delete" }                                                                                          |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] } |
      | { "body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "delete" }                                                                                          |
#     # IDXS-T910 Проверка Kafka метрик запроса "Добавление и удаление синонимов" (В ELK и БД ФП Мониторинг)
#  @TmsLink=IDXS-T910
#  Scenario Outline: IDXS-T910 Проверка Kafka метрик запроса Добавление и удаление синонимов (В ELK и БД ФП Мониторинг)
#    * def dbConfig = { username: #(DatabaseUser), password: #(DatabasePass), url: #(monitoringDatabaseUri), driverClassName: #(DatabaseDrv) }
#    * def DbUtils = Java.type('db.DbUtils')
#    * def db = new DbUtils(dbConfig)
#    # Задержка
#    * call read('classpath:globals_features/sleep.feature') {sleepTime: 90000}
#    # Проверка метрики HTTP_REQUEST_*
#    * def answer_db1 = db.readRows("SELECT DISTINCT NAME FROM UFS_MONITORING_" + tableSuffix + ".METRICS WHERE START_TIMESTAMP > SYSDATE - INTERVAL '5' MINUTE AND EAR_NAME = 'BFS_INDEX_SEARCH' AND WAR_NAME = 'ufs-index-search-indexer' AND server_Path = '" + serverPath + "' AND count >= '<count>' AND ear_version = '<earVersion>' AND NAME like 'KAFKA_REQUEST%'")
#    * print answer_db1
#    * match answer_db1 contains {"NAME": '<1_metric>'}
#    * match answer_db1 contains {"NAME": '<2_metric>'}
#    * match answer_db1 contains {"NAME": '<3_metric>'}
#    * match answer_db1 contains {"NAME": '<4_metric>'}
#    * match answer_db1 contains {"NAME": '<5_metric>'}
#    * print 'metric received finished'
#    Examples:
#      | 1_metric               | 2_metric              | 3_metric                       | 4_metric           | 5_metric                    | count | earVersion |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | KAFKA_REQUEST_FAIL | KAFKA_REQUEST_FAIL_DURATION | 6     | R4.6.1     |



     # IDXS-T910 Проверка Kafka метрик запроса "Добавление и удаление синонимов" (В ELK и БД ФП Мониторинг)
  @TmsLink=IDXS-T910
  Scenario Outline: IDXS-T910 Проверка Kafka метрик запроса Добавление и удаление синонимов (В ELK ФП Мониторинг)
    # Создание домена данных
    * def request_kafka = call sendData '<body>, "header" : { "evtType": "Тип события", "evtVersion": "Версия схемы события", "srcModule" : "Код АС-источника события", "evtID" : "Уникальный идентификатор события", "evtDate" : "Время возникновения события", "sndDate" : "Время отправки события источником", "parentID": "Идентификатор события-родителя", "prevEvtID": "Идентификтор предыдущего события АС-источника"}}'
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 2000}
    Examples:
      | body                                                                                                                                                                                                                     |
      | {"body" : { "action" : "create_domain", "rn_id" :"auto_kafka", "domain_name":"auto_load_synonyms" }                                                                                                                      |
      | {"body" : { "action" : "create_domain", "rn_id" :"auto_kafka", "domain_name":"auto_delete_synonyms" }                                                                                                                    |
      | {"body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] }      |
      | {"body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_delete_synonyms", "operation": "delete" }                                                                                             |
      | {"body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_load_synonyms_Fail", "operation": "partSave", "fields": [ "футбол, теннис, легкая атлетика, баскетбол, гольф, пинг-понг, биатлон" ] } |
      | {"body": { "action": "batch_synonyms", "rn_id": "auto_kafka", "domain_name": "auto_delete_synonyms_Fail", "operation": "delete" }                                                                                        |
      | {"body": {"action": "delete_rn","rn_id": "auto_kafka"}                                                                                                                                                                   |
      # Задержка
  Scenario: IDXS-T910 Проверка Kafka метрик запроса Добавление и удаление синонимов (В ELK и БД ФП Мониторинг)
    * call read('classpath:globals_features/sleep.feature') {sleepTime: 90000}
      # Проверка метрик
  @TmsLink=IDXS-T910
  Scenario Outline: IDXS-T910 Проверка Kafka метрик запроса Добавление и удаление синонимов (В ELK и БД ФП Мониторинг)
   # Проверка метрики KAFKA_REQUEST_RECEIVED
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<1_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<1_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<2_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<2_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    # Проверка метрики KAFKA_REQUEST_SUCCESS_DURATION/FAIL
    Given url elasticMonitorUri + 'metrics-*/_search?pretty'
    * header Authorization = call read('classpath:globals_js/elastic-authJAM.js')
    * request
    """
    {"sort": [{"endPeriod": {"order": "desc", "unmapped_type": "boolean"}}],
        "query": {
            "bool": {
                "filter": [
                    {"term": {"name.keyword": "<3_metric>"}},
                    {"term": {"serverPath.keyword": "#(serverPath)"}},
                    {"term": {"warName.keyword": "<warName>"}},
                    {"term": {"subSystemCode.keyword": "<subSystemCode>"}},
                    {"term": {"earVersion.keyword": "<earVersion>"}},
                    {"term": {"extendedAttributes.ACTION.keyword": "<ACTION>"}},
                    {"term": {"extendedAttributes.PROJECT_ID.keyword": "<PROJECT_ID>"}},
                    {"term": {"extendedAttributes.DOMAIN.keyword": "<DOMAIN>"}},
                    {"range":{"endPeriod":{
                      "gte": "now-10m"}}}]}},
    "_source" : ["endPeriod", "path", "name",  "warName", "serverPath", "subSystemCode","extendedAttributes.PROJECT_ID","extendedAttributes.ACTION","extendedAttributes.DOMAIN","earVersion"]}
    """
    When method GET
    Then status 200
    * match response.hits.hits[0]._source.name == '<3_metric>'
    * match response.hits.hits[0]._source.serverPath == serverPath
    * match response.hits.hits[0]._source.warName == '<warName>'
    * match response.hits.hits[0]._source.subSystemCode == '<subSystemCode>'
    * match response.hits.hits[0]._source.earVersion == '<earVersion>'
    * match response.hits.hits[0]._source.extendedAttributes.ACTION == '<ACTION>'
    * match response.hits.hits[0]._source.extendedAttributes.PROJECT_ID == '<PROJECT_ID>'
    * match response.hits.hits[0]._source.extendedAttributes.DOMAIN == '<DOMAIN>'
    Examples:
      | 1_metric               | 2_metric              | 3_metric                       | ACTION         | PROJECT_ID | DOMAIN                    | earVersion | warName                  | subSystemCode    |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | batch_synonyms | auto_kafka | auto_load_synonyms        | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | batch_synonyms | auto_kafka | auto_load_synonyms_Fail   | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_SUCCESS | KAFKA_REQUEST_SUCCESS_DURATION | batch_synonyms | auto_kafka | auto_delete_synonyms      | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |
#      | KAFKA_REQUEST_RECEIVED | KAFKA_REQUEST_FAIL    | KAFKA_REQUEST_FAIL_DURATION    | batch_synonyms | auto_kafka | auto_delete_synonyms_Fail | R4.6.1     | ufs-index-search-indexer | BFS_INDEX_SEARCH |