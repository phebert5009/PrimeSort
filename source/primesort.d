module primesort;

/// Inplace, unstable sort in Ω(n^2)
void primeSort(T)(T[] toSort)
{
    import std.range : iota;
start:
    if(toSort.isSorted) return;

    size_t[] factors = factorize(toSort.length + 1);
    if(factors.length <= 1) // toSort.length + 1 is 0, 1, or prime
    {
        factors = factorize(toSort.length + 2);
    }

    factors = [0UL, 1UL] ~ factors;
    auto indexes = factors.dup;

    while(indexes[1] != 0)
    {
        indexes[] += factors[];
        indexes[] %= toSort.length;
        // actual sorting step, but only for one iteration.
        for(int i = 0; i < indexes.length; i++)
        {
            for(int ii = i + 1; ii < indexes.length; ii++)
            {
                if(indexes[i] < indexes[ii] && toSort[indexes[ii]] < toSort[indexes[i]]) // TODO: allow for predicate to be changed
                {
                    auto tmp = toSort[indexes[i]];
                    toSort[indexes[i]] = toSort[indexes[ii]];
                    toSort[indexes[ii]] = tmp;
                }
            }
        }
    }
    // recursive sorting step, using tail recursion. Not because I don't trust the compiler, but because this is as easy to understand 
    toSort = toSort[1..$];
    goto start;
}

unittest {
    auto array = [17, 5, 16, 0, 3, 12, 11, 19, 9, 1, 6, 2, 15, 7, 18, 13, 10, 14, 4, 20, 8];
    primeSort(array);
    assert(array == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
}

unittest {
    auto array = [5, 3, 4, 1, 2];
    primeSort(array);
    assert(array == [1, 2, 3, 4, 5]);
}

unittest {
    auto array = [5, 4, 3, 2, 1];
    primeSort(array);
    assert(array == [1, 2, 3, 4, 5]);
}

unittest {
    auto array = [1, 2, 3, 4, 5];
    primeSort(array);
    assert(array == [1, 2, 3, 4, 5]);
}

private bool isSorted(T)(T[] toCheck) @property
{
    if(toCheck.length <= 1) return true;
    T prev = toCheck[0];
    foreach(value; toCheck)
    {
        if(value < prev) return false; // TODO: allow for predicate to be changed
        prev = value;
    }
    return true;
}

private size_t[] factorize(size_t toFactorize)
{
    if(toFactorize <= 1) return size_t[].init;
    PrimeSieve primes;
    size_t[] primeFactors;
    foreach(prime; primes)
    {
        if(toFactorize % prime != 0) continue;

        primeFactors ~= prime;
        toFactorize /= prime;

        // get rid of duplicates
        while(toFactorize % prime == 0)
        {
            toFactorize /= prime;
        }

        if(toFactorize == 1)
        {
            return primeFactors;
        }
    }
    // probably won't happen, but might as well keep this here
    return primeFactors ~ toFactorize;
}

/// A Range for generating primes.
struct PrimeSieve
{
    private static size_t[] primes = [ 2, 3, 5, 7, 11, 13];
    private static size_t next = 17;

    private size_t cursor;

    /// Pretty much always false, but will stop before overflowing size_t, assuming a >=64bit processor 
    bool empty() @property const @nogc nothrow @safe
    {
        return front == 18_446_744_073_709_551_557; // largest prime < size_t.max assuming 64bit size_t.
        // According to wolfram alpha
    }

    ///
    size_t front() @property const @nogc nothrow @safe
    {
        return primes[cursor];
    }

    ///
    void popFront()
    {
        if(empty) return;
        cursor++;
        if(cursor < primes.length)
        {
            return;
        }

        outer: while(true)
        {
            foreach(prime; primes)
            {
                if(next % prime == 0)
                {
                    popNext();
                    continue outer;
                }
            }
            break;
        }

        primes ~= next;
        popNext();
    }

    private void popNext() @nogc nothrow
    {
        if(next % 6 == 5)
        {
            next += 2;
            return;
        }
        next += 4;
    }

    ///
    size_t opIndex(size_t index)
    {
        import std.conv : to;
        while(index >= primes.length && !empty)
        {
            popFront();
        }
        if(index >= primes.length)
            throw new Exception("Index out of Range: index " ~ index.to!string ~ " produces a prime greater than size_t.max");
        return primes[index];
    }

    ///
    PrimeSieve save() @nogc pure const nothrow @safe
    {
        PrimeSieve newRange;
        newRange.cursor = cursor;
        return newRange;
    }
}
