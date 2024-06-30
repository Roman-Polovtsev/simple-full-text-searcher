package ru.polovtsev.tests;

import java.util.Iterator;


/*
 сначала по a потом по b
 */
public class MultiIterator<T> implements Iterator<T> {

    private final Iterator<T> a;
    private final Iterator<T> b;

    public MultiIterator(Iterator<T> a, Iterator<T> b) {
        this.a = a;
        this.b = b;
    }

    @Override
    public boolean hasNext() {
        boolean nextA = a.hasNext();
        if (nextA) return nextA;
        else return b.hasNext();
    }

    @Override
    public T next() {
//        if (hasNext()) return a.next()
        return null;
    }

    @Override
    public void remove() {

    }
}
