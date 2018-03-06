package tech.barbero.contained.java.example;

import java.util.Arrays;
import java.util.stream.Collectors;

public class Main {
	public static void main(String[] args) {
		System.out.println("Hello " + Arrays.stream(args).collect(Collectors.joining(", ")));
	}
}
