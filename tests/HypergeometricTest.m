fprintf("Running Hypergeometric Test...\n");

lambda = 1;

a = 10;
b = 5;
c = 15;
z = 0.5;
tic
my_approx = Hypergeometric(lambda, a, b, c, z).approximate()
toc
approx = hypergeom([a, b], c, z)

% get random number in ]-50, 50[
a = -50 + 100 * rand();
b = -50 + 100 * rand();
c = -50 + 100 * rand();
z = -0.5 + 1 * rand();
tic
my_rand_approx = Hypergeometric(lambda, a, b, c ,z).approximate()
toc
rand_approx = hypergeom([a, b], c, z)

