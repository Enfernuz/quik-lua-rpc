package.path = "../?.lua;" .. package.path

require 'busted.runner'()

describe("a test", function()
  -- tests to here
  it("tests insulate block does not update environment", function()
    assert.are.equal(1, 1)
  end)
  
end)