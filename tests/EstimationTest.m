fprintf("Running Estimation test...\n");


fr  = FileReader();
ps  = StudentParameterSetup(2);
est = Estimation("Student",fr,ps);
est.run();

fprintf("Estimation tests passed\n");