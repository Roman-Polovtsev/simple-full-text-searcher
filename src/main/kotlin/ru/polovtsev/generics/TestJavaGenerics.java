package ru.polovtsev.generics;

import org.jetbrains.annotations.NotNull;
import org.yaml.snakeyaml.constructor.SafeConstructor;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.IntStream;

/**
 * if generic has bounding - it erases to left boundary, else - to object
 *
 * class X<T extends COmparable> ==
 */
public class TestJavaGenerics {

    /*
    this will be erased to (always to left border)
     public Comparable get()
     */

    public static void main(String[] args) {
        IntStream.range(1,4).filter(i -> i > 1).forEach(System.out::println);
        boolean res = IntStream.range(1, 4).peek(System.out::println).anyMatch(i -> i > 1);
        System.out.println(res);
    }

    static class ErasureLeft <T extends Comparable<T>>{
        T value;
        public T get(){
            return value;
        }
    }

   //bridge
    static class Person implements Comparable<Person>{
       @Override
       public int compareTo(@NotNull Person o) {
           return 0;
       }

       //synt bridge method added by compiler
//       public int compareTo(Object o){
//           return compareTo((Person) o);
//       }
   }


   //heap pollution
    static class HeapPollution{

        Number[] numbers = new Integer[10];

        //this will throw ArrayStoreException
        void getException(){
            numbers[0] = 1.2f;
        }

        void genericsPollution(){
            List<Integer> integers = new ArrayList<>();
            List warningList = integers; //get warning
            List<Number> numberList = warningList; //warnign
            numberList.add(6.7d); // complied successfully, but:

            Integer integer = integers.get(0); //ClassCastException because of line below - added by compiler
            //Integer integer = integers.get(0);
        }

        void genericArrayCreation(){
           // List<Number>[] lists = new ArrayList<Number>[10];
            //Object[]objects = lists;
            //objects[0] = new ArrayList<String>();
//            lists[0].add(1L);

        }

        void varargsGenericArray(List<String>... lists){
            Object[] objects = lists;
            objects[0] = Arrays.asList(42);
            String s = lists[0].get(0); //ClassCastException
        }

        void producerExtends(){
            List<? extends Number> list = new ArrayList<Integer>();
            //cannot add anything than null
            //list.add(Long.MAX_VALUE);
            //list.add(Integer.MAX_VALUE);
            list.add(null);

            //can return any child of
            Number number = list.get(0);
        }

        void consumerSuper(){
            List<? super Number> list = new ArrayList<>();

            list.add(Integer.MAX_VALUE);
            list.add(Long.MAX_VALUE);
            //cannot add anything more than Number
//            list.add(new Object());

            //can return only object
            Object object = list.get(0);

//            Number object1 = list.get(0);

        }
   }


}
