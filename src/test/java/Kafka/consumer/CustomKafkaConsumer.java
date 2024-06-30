package Kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import tests.Kafka.fts.Message;

import java.time.Duration;
import java.util.*;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CustomKafkaConsumer {

    private final Map<String, Object> errorProperties;
    private final String errorTopicName;

    public CustomKafkaConsumer(ConsumerKafkaConfig errorProperties) {
        this(errorProperties.toConsumerConfig(), errorProperties.errorTopicName());
    }

    public CustomKafkaConsumer(Map<String, Object> errorProperties, String errorTopicName) {
        this.errorProperties = errorProperties;
        this.errorTopicName = errorTopicName;
    }

    public String receive() {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(errorProperties);
        List<TopicPartition> partitions = subscribeToTopicsPartition(consumer);
        Callable<String> pollTask = () -> pollLastData(consumer, partitions);
        String lastRecord = extractedRecord(pollTask, executor);
        executor.shutdown();
        return lastRecord;
    }

    public List<Message> receiveLastNRecords(int bufferSize){
        ExecutorService executor = Executors.newSingleThreadExecutor();
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(errorProperties);
        List<TopicPartition> partitions = subscribeToTopicsPartition(consumer);
        Callable<List<Message>> pollTask = () -> pollLastNMessages(consumer, partitions, bufferSize);
        List<Message> lastRecords = extractedRecords(pollTask, executor);
        executor.shutdown();
        return lastRecords;
    }

    private List<TopicPartition> subscribeToTopicsPartition(KafkaConsumer<String, String> consumer) {
        TopicPartition partition = new TopicPartition(errorTopicName, 0);
        List<TopicPartition> partitions = Collections.singletonList(partition);
        consumer.assign(partitions);
        return partitions;
    }

    private List<Message> pollLastNMessages(KafkaConsumer<String, String> consumer, List<TopicPartition> partitions, int messagesQuantity) {
        consumer.seekToEnd(partitions);
        long startOffset = consumer.position(partitions.get(0)) - messagesQuantity;
        consumer.seek(partitions.get(0), startOffset);
        return pollLastRecords(consumer, messagesQuantity);
    }

//    {"serverEventDatetime":1702285760778,"message":"event for file certificate /etc/istio/egressgateway-certs/tls.crt : REMOVE,
//    pushing to proxy","deploymentUnit":"ufs-standin-fluent-bit-unver-istio-proxy-logger","logLevel":"INFO","scope":"cache",
//    "subsystem":"UFS_STANDIN","hostName":"egressgateway-ufs-standin-unver-cfc9f69c6-62px4","namespace":"efs-std-ift1-conf-gfsk-standin",
//    "nodeId":"worker-33.ocp.ift-02.solution.sbt","nodePath":"emp.config.gf.sk","systemIp":"192.168.40.236","distribVersion":"D-07.000.00-4992"}

    private List<Message> pollLastRecords(KafkaConsumer<String, String> consumer, long quantity) {
        List<Message> messages = new ArrayList<>();
        do {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
            records.forEach(record -> System.out.printf("Received record: %s%n", record));
            if (!records.isEmpty()) {
                consumer.commitAsync();
                Iterator<ConsumerRecord<String, String>> iterator = records.iterator();
                while (iterator.hasNext()){
                    ConsumerRecord<String, String> record = iterator.next();
                    Message message = Message.from(record);
                    messages.add(message);
                }
            }
        } while (messages.size() <= quantity);
            return messages;
    }

    private String pollLastData(KafkaConsumer<String, String> consumer, List<TopicPartition> partitions) {
        consumer.seekToEnd(partitions);
        return pollRecord(consumer);
    }

    private String pollRecord(KafkaConsumer<String, String> consumer) {
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
            records.forEach(record -> System.out.printf("Received record: %s%n", record));
            if (!records.isEmpty()) {
                consumer.commitAsync();
                Iterator<ConsumerRecord<String, String>> iterator = records.iterator();
                return iterator.next().toString();
            }
        }
    }

    private String extractedRecord(Callable<String> task, ExecutorService executor) {
        try {
            return executor.submit(task).get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            return "error";
        }
    }

    private List<Message> extractedRecords(Callable<List<Message>> task, ExecutorService executor) {
        try {
            return executor.submit(task).get();
        } catch (InterruptedException | ExecutionException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

}
