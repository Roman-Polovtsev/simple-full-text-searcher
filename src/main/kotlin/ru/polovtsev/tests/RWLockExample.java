package ru.polovtsev.tests;

import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

public class RWLockExample {
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
}
