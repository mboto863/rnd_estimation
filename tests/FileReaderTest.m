fprintf("Running FileReader tests...\n");

fr = FileReader();
l = fr.getFiles();
[data1,ok1] = fr.readDay(1);
[data10,ok10] = fr.readDay(10);
[data100,ok100] = fr.readDay(100);
%[data1000,ok1000] = fr.readDay(1000);

fprintf("FileReader tests passed\n");