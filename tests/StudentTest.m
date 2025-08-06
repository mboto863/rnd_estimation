fprintf("Running Student tests...\n");

% Read day 1.
fileReader  = FileReader();
[data_first_day,ok_first_day] = fileReader.readDay(1);

% Setup parameters.
parameterSetup = StudentParameterSetup(5);
theta          = parameterSetup.initializeAll(data_first_day);
names          = parameterSetup.getNames();
valueHandler   = ValueHandler(5, names, theta);
parameters     = valueHandler.getStructure();

[inequality, equality] = Student.getNonLinearConstraint(theta, valueHandler, data_first_day);
price_first_day        = Student.getPrice(parameters, data_first_day(1, :));
forward_price          = Student.getForwardPrice(parameters);

% fprintf("Iterating over 10 days...\n")
% tic
% for day = 1:10
%     [data,ok] = fr.readDay(day);
%     if ok
%         model = StudentModel(5,data);
%         price = model.modelPrice();
%     end
% end
% toc