package ru.polovtsev.tests;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class BlockingQueueWaitNotify<T> implements BlockingQueue<T> {

    private final Queue<T> queue = new LinkedList<>();
    private volatile int currentQuantity = 0;
    private final Lock lock = new ReentrantLock();
    private static final ThreadLocal<Integer> counter = ThreadLocal.withInitial(()->0);

    @Override
    public void add(T element) throws InterruptedException {
        synchronized (lock){
            Integer current = counter.get();
            counter.set(current+1);
            while (currentQuantity == 5){
                lock.wait();
            }
            queue.add(element);
            currentQuantity++;
            lock.notifyAll();
            System.out.println("add " + counter.get());
        }
    }


    @Override
    public T poll() throws InterruptedException {
        synchronized (lock){
            Integer current = counter.get();
            counter.set(current+1);
            while (currentQuantity == 0){
                lock.wait();
            }
            T result = queue.poll();
            currentQuantity--;
            lock.notifyAll();
            System.out.println("poll "   + counter.get() + "\nqueue size " + queue.size());
            return result;
        }
    }
}

