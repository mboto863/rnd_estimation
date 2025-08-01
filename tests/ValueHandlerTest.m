fprintf("Running ValueHandler tests...\n");

fr = FileReader();
data1 = fr.readDay(1);

sps = StudentParameterSetup(5);
vec = sps.initializeAll(data1);
names = StudentParameterSetup.getNames();

vh = ValueHandler(5,names,vec);
disp(vh.getVector());
data2 = fr.readDay(2);
vec = sps.initializeAll(data2);
vh.setVector(vec);
vh.getStruct();
disp(vh.getVector());
vh.get("mu");

% vh1.setVector([2000,40])
% vh1.getStruct()
% vh1.getVector()
% vh1.get("mu")
% 
% vh2 = ValueHandler(5,{'omega','nu'},[0.5,20,21])
% vh2.setVector([0.6,40,41])
% vh2.getStruct()
% vh2.getVector()
% vh2.get("omega")
% vh2.get("nu")

fprintf("ValueHandler tests passed\n");