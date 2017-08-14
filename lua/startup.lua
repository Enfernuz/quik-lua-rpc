local worker = require("./worker")
assert(worker ~= nil)

function OnStop()

	worker:terminate()
end

function main()

	worker:init("tcp://127.0.0.1:5559")
	worker:start()
end