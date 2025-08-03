fprintf("Running StudentModel tests...\n");

fr          = FileReader();
[data1,ok1] = fr.readDay(1);
model1      = StudentModel(5,data1);
price1      = model1.modelPrice();
fprintf("Iterating over 10 days...\n")
tic
for day = 1:10
    [data,ok] = fr.readDay(day);
    if ok
        model = StudentModel(5,data);
        price = model.modelPrice();
    end
end
toc