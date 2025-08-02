fprintf("Running Hypergeometric Test...\n");
lambda = 1
a = rand(-50,50);
b = rand(-50,50);
c = rand(-50,50);
z = rand(-100,100);
tic
my_approx = Hypergeometric(lambda, a, b, c, z)
toc
approx = hypergeom(lambda, a, b, c, z)