# Hypergeometric Numerical Methods

PearsonOlverMasonPorter table 6 p.853

## Single Fraction Method

- Particularly useful when |c| < 1 and |a|, |b| < 30

## Gauss-Jacobi quadrature

- Re(c) > Re(b) > 0 or Re(c) > Re(a) > 0
- High computational cost, last resort only

## Taylor Series Expansion

- |a|, |b| < 50, |c| < 20
- Method A seems slightly better in accuracy.
- For our purposes we should compare performances (computational) of A and B methods and then use the best one.

# Recurrence Relations

## c < -20, |a|, |b|

- Use rec00plus_backward
  - Get c to 0.3

# Cancellation

- b - a or c - a - b is close to an integer.

# Transformation Formulas

- Need to be looked at again, as Pearson provides new ones in his more recent article.

# IMPORTANT FOR INFINITE RECURSION DEBUGGING IN CASE IV

- Pearson: We apply forward recurrences to c so that all computations involve large values of |c| and then use an additional transformation, such as (4.12)