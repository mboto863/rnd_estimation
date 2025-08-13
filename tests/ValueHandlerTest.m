fprintf("Running ValueHandler tests...\n");

fileReader    = FileReader();
firstDayData = fileReader.readDay(1);

studentParameterSetup   = StudentParameterSetup(5);
firstDayVector   = studentParameterSetup.initializeAll(firstDayData);
names = StudentParameterSetup.getNames();

valueHandler    = ValueHandler(5, names, firstDayVector);
disp(valueHandler.getVector());

secondDayData = fileReader.readDay(2);
secondDayVector   = studentParameterSetup.initializeAll(secondDayData);

valueHandler.setVector(secondDayVector);

valueHandler.getStructure();
disp(valueHandler.getVector());
valueHandler.getParameter("mu");

fprintf("ValueHandler tests passed\n");