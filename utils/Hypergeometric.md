# Hypergeometric Numerical Methods

PearsonOlverMasonPorter table 6 p.853

## Single Fraction Method

- Particularly useful when |c| < 1 and |a|, |b| < 30

## Gauss-Jacobi quadrature

- Re(c) > Re(b) > 0 or Re(c) > Re(a) > 0
- High computational cost, last resort only

## Taylor Series Expansion

- |a|, |b|, |c| < 20
- Method A seems slightly better

# Recurrence Relations

## c < -20, |a|, |b|

- Use rec00plus_backward
