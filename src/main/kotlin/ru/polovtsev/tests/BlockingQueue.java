package ru.polovtsev.tests;

import java.util.HashMap;

public interface BlockingQueue<T> {

    void add(T element) throws InterruptedException;

    T poll() throws InterruptedException;

    public static void main(String[] args) throws InterruptedException {
        BlockingQueue<String> queue = new BlockingQueueLockConditions<>();
        int counter = 10;
        var map = new HashMap<Long, String>();
        Thread addThread = new Thread(() -> {
            int addCounter = counter;
            while (addCounter > 0){
                try {
                    queue.add(String.valueOf(addCounter));
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                addCounter--;
            }
        });
        Thread pollThread = new Thread(() -> {
            int pollCounter = counter;
            while (pollCounter > 0){
                try {
                    queue.poll();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                pollCounter--;
            }
        });

        pollThread.start();
        addThread.start();


        Thread.sleep(1000);
        pollThread.join();
        addThread.join();

    }
}
