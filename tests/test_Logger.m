fprintf("Running Logger tests...\n")

% Create a logger instance.
logger = Logger();

% Write informative log.
logger.writeInfo("This is info");

% Write warning log.
logger.writeWarning("This is a warning");

% Write an error log.
logger.writeError("This is an error");

% Write a log with a parameter.
x = 1;
logger.writeInfo("x is %d", x);
logger.writeWarning("x is %d",x);
logger.writeError("x is %d", x);