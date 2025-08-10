fprintf("Running main script...\n")
tic
fr = FileReader();
ps = StudentParameterSetup(2);

est = Estimation("Student",fr,ps);
est.run();
toc
