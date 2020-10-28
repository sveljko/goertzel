# Goertzel filter in Ada/Spark

This implements the Goertzel filter in Ada, staying in the Spark
subset.

There are several improvements possible, but, in general, it works
well. For example, the `Goertzel` package should be made generic with
regards to the required number of significant digits of the floating
point type used for the calculations.

As far as Spark is concerned, the only problem left is that we can't
prove that there will be no overflow during calculations.  That is a
hard problem for any non-trivial calculation, like filters.  Also,
filters, are often designed with the notion that the calculations
might overflow if the samples are out of "regular" range and in that
case filter will simply "fail". Thus, it's not a big issue.

But, time permitting, we could/should improve and add contracts that
would enable us to prove no overflow, too.
