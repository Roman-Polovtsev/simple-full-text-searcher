package Kafka.producer;

import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.HashMap;
import java.util.Map;

public class KafkaConfig {

    private final String topicName;
    private final String bootstrapAddress;
    private final String trustStoreLocation;
    private final String trustStorePassword;
    private final String keyStoreLocation;
    private final String keyStorePassword;

    public KafkaConfig(Map<String, Object> config) {
        this.topicName = (String) config.get("topicName");
        this.bootstrapAddress = (String) config.get("bootstrapAddress");
        this.trustStoreLocation = (String) config.get("trustStoreLocation");
        this.trustStorePassword = (String) config.get("trustStorePassword");
        this.keyStoreLocation = (String) config.get("keyStoreLocation");
        this.keyStorePassword = (String) config.get("keyStorePassword");
    }

    public String topicName() {
        return topicName;
    }

    public Map<String, Object> toKafkaConfig() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapAddress);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
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
