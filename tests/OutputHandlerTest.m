fprintf("Running OutputHandler tests...\n");

oh        = OutputHandler()
oh.log("mu",4000,10)
mu_log    = oh.get("mu")
oh.log("sigma",[40,50],5)
oh.log("sigma",[60,60],6)
oh.log("sigma",[60,60],8)
sigma_log = oh.get("sigma")
all_logs  = oh.getAll()

fprintf("OutputHandler tests passed\n");

