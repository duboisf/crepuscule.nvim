describe("location", function()
  local location = require("crepuscule.location")

  it("gets the current location", function()
    local co = coroutine.running()
    assert(co, "not running inside a coroutine")

    location.geo_coordinates(function(coordinates)
      vim.schedule(function()
        coroutine.resume(co, coordinates)
      end)
    end)

    local coordinates = coroutine.yield()
    assert(coordinates, "coordinates must not be nil")
    assert(coordinates.latitude, "coordinates must not be nil")
    assert(coordinates.longitude, "coordinates must not be nil")
  end)
end)
