fprintf("Running Estimation test...\n");


fileReader  = FileReader();
parameterSetup  = LogNormalParameterSetup(100);
est = Estimation("LogNormal",fr,ps);
est.run();

fprintf("Estimation tests passed\n");

omega = outputHandler.get("omega");
