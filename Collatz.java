class Collatz {
	
    public static void main(String[] args) {
        long maxsteps = 0L;
        for (long i = 1; i <= 100000000; ++i) {
            long steps = 0L;
            long result = i;
            while (result != 1L) {
                if ((result & 1L) == 1L) {
                    // multiplying by 3 and adding 1 a number is always even
                    result = (result * 3L + 1L) >> 1;
                    steps += 2;
                } else {
                    ++steps;
                    result >>= 1;
                }
            }
            if (steps > maxsteps) {
                maxsteps = steps;
                System.out.printf("Number: %d, steps: %d\n", i, maxsteps);
            }
        
        }
    }
}

