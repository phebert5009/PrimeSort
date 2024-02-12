# PrimeSort

This is a joke sorting algorithm which should be worse than bubble sort (and is unstable too).

I just made it for fun. Use it at your own risk.

## The Idea


This is actually a pessimisation of selection sort, where we do extra work with every pass.

Given an array of length `N`.
Use the prime factors of `N + 1`, along with 1 and 0, as steps for various indexes (mod `N`),
(which should each take some multiple of `N` steps to return to 0), to sort a subset of the array
(bubble sort is simplest for the subsets).

if `N + 1` is prime, use `N + 2` instead, to increase the size of the subarrays.
This is not strictly necessary, but it should reduce the amount of passes.

Finally shortcut if the array is already sorted.
