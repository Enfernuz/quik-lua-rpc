package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("NOOP TEST", function()
      it("SHOULD run fine", function() end)
end)
