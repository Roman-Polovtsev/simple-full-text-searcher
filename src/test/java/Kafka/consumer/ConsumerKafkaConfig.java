package Kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.util.HashMap;
import java.util.Map;

public class ConsumerKafkaConfig {

    private final String errorTopicName;
    private final String bootstrapAddress;
    private final String trustStoreLocation;
    private final String trustStorePassword;
    private final String keyStoreLocation;
    private final String keyStorePassword;
    private final String groupIdName;

    public ConsumerKafkaConfig(Map<String, Object> config) {
        this.errorTopicName = (String) config.get("errorTopicName");
        this.bootstrapAddress = (String) config.get("bootstrapAddress");
        this.trustStoreLocation = (String) config.get("trustStoreLocation");
        this.trustStorePassword = (String) config.get("trustStorePassword");
        this.keyStoreLocation = (String) config.get("keyStoreLocation");
        this.keyStorePassword = (String) config.get("keyStorePassword");
        this.groupIdName = (String) config.get("groupIdName");
    }

    public String errorTopicName() {
        return errorTopicName;
    }

    public Map<String, Object> toConsumerConfig() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapAddress);
        configProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        configProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        configProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        configProps.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, "1");
        configProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");
        configProps.put(ConsumerConfig.GROUP_ID_CONFIG, groupIdName);
        configProps.put("security.protocol", "SSL");
        configProps.put("ssl.enabled.protocols", "TLSv1.2");
        configProps.put("ssl.key.password", keyStorePassword);
        configProps.put("ssl.keystore.location", keyStoreLocation);
        configProps.put("ssl.keystore.password", keyStorePassword);
        configProps.put("ssl.keystore.type", "JKS");
        configProps.put("ssl.truststore.location", trustStoreLocation);
        configProps.put("ssl.truststore.password", trustStorePassword);
        configProps.put("ssl.truststore.type", "JKS");
        configProps.put("ssl.endpoint.identification.algorithm", "");
        return configProps;
    }
}
