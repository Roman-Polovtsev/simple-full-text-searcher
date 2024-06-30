package ru.polovtsev.tests;

import java.util.Objects;

public class Foot implements Runnable {

    private final String name;
    private final String lock;
    private static volatile int currentLeg = 0; // 0  - left, 1 - right

    public Foot(String name) {
        this.name = name;
        this.lock = "lock";

    }

    @Override public void run() {
        while (true) {
            try {
                step();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    private void step() throws InterruptedException {
        synchronized (lock) {
            while (true) {
                if ((Objects.equals(name, "left") && currentLeg %2 == 0 ) || (name.equals("right") && currentLeg %2 == 1)) {
                    System.out.println("Step by " + name);
                    currentLeg = (currentLeg + 1) % 4;
                    lock.notifyAll();
                } else {
                    lock.wait();
                }
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Thread l = new Thread(new Foot("left"));
        Thread r = new Thread(new Foot("right"));
        Thread r1 = new Thread(new Foot("right"));
        Thread r2 = new Thread(new Foot("left"));
        l.start();
        r.start();
        r1.start();
        r2.start();
        Thread.sleep(1000);
    }
}
