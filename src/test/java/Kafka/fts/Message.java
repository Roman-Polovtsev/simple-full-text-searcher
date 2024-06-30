package Kafka.fts;

import org.apache.kafka.clients.consumer.ConsumerRecord;

public class Message {

    private final long offset;
    private final String data;

    public Message(long offset, String data) {
        this.offset = offset;
        this.data = data;
    }

    public static Message from(ConsumerRecord<String, String> record) {
        return new Message(record.offset(), record.value());
    }

    public long offset() {
        return offset;
    }

    public String data() {
        return data;
    }

    @Override
    public String toString() {
        return "Message{" +
                "offset=" + offset +
                ", data='" + data + '\'' +
                '}';
    }
}
