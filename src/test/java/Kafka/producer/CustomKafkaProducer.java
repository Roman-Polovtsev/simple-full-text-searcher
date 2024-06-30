package Kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;

import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class CustomKafkaProducer {

    private final Map<String, Object> properties;
    private final String topicName;

    public CustomKafkaProducer(KafkaConfig properties) {
        this.properties = properties.toKafkaConfig();
        this.topicName = properties.topicName();
    }

    public void send(String data) {
        try (KafkaProducer<String, String> producer = new KafkaProducer<>(properties)) {
            ProducerRecord<String, String> record = new ProducerRecord<>(topicName, data);
            Future<RecordMetadata> recordResult = producer
                    .send(record, (recordMetadata, e) -> recordsCallback(data, recordMetadata, e));
            recordResult.get();
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            System.out.printf("Smth went wrong during sending data: %s \nto topic: %s", data, topicName);
        }
    }

    public void delayedSend(String data, long millis) {
        Thread sender = new Thread(() -> {
            try {
                Thread.sleep(millis);
                send(data);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        sender.start();
    }

    private void recordsCallback(String data, RecordMetadata recordMetadata, Exception e) {
        if (e == null)
            System.out.println("Sent message=[" + data + "] with offset=[" + recordMetadata.offset() + "]");
        else System.out.println("Unable to send message=[" + data + "] due to : " + e.getMessage());
    }
}
