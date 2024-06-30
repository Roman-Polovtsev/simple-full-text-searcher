package ru.polovtsev.tests;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class BlockingQueueLockConditions<T> implements BlockingQueue<T> {

    private final Queue<T> queue = new LinkedList<>();
    private final Lock lock = new ReentrantLock();
    private final Condition isEmpty = lock.newCondition();
    private final Condition isFull = lock.newCondition();
    private static final ThreadLocal<Integer> counter = ThreadLocal.withInitial(() -> 0);

    @Override
    public void add(T element) throws InterruptedException {
        lock.lock();
        threadLocalCounter();
        while (queue.size() == 5) {
            isFull.await();
        }
        queue.add(element);
        isEmpty.signalAll();
        System.out.println("add " + counter.get());
        lock.unlock();
    }

    @Override public T poll() throws InterruptedException {
        lock.lock();
        threadLocalCounter();
        while (queue.isEmpty()) {
            isEmpty.await();
        }
        T result = queue.poll();
        System.out.println("poll " + counter.get() + "\nqueue size " + queue.size());
        isFull.signalAll();
        lock.unlock();
        return result;
    }

    private void threadLocalCounter() {
        Integer current = counter.get();
        counter.set(current + 1);
    }
}
