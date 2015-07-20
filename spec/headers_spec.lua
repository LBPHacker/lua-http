describe("http.headers module", function()
	local headers = require "http.headers"
	it("multiple values can be added for same key", function()
		local h = headers.new()
		h:append("a", "a", false)
		h:append("a", "b", false)
		h:append("foo", "bar", true)
		h:append("a", "c", false)
		h:append("a", "a", true)
		local iter, state = h:each()
		assert.same({"a", "a", false}, {iter(state)})
		assert.same({"a", "b", false}, {iter(state)})
		assert.same({"foo", "bar", true}, {iter(state)})
		assert.same({"a", "c", false}, {iter(state)})
		assert.same({"a", "a", true}, {iter(state)})
	end)
	it("entries are kept in order", function()
		local h = headers.new()
		h:append("a", "a", false)
		h:append("b", "b", true)
		h:append("c", "c", false)
		h:append("d", "d", true)
		h:append("d", "d", true) -- twice
		h:append("e", "e", false)
		local iter, state = h:each()
		assert.same({"a", "a", false}, {iter(state)})
		assert.same({"b", "b", true}, {iter(state)})
		assert.same({"c", "c", false}, {iter(state)})
		assert.same({"d", "d", true}, {iter(state)})
		assert.same({"d", "d", true}, {iter(state)})
		assert.same({"e", "e", false}, {iter(state)})
	end)
	it(":has works", function()
		local h = headers.new()
		assert.same(h:has("a"), false)
		h:append("a", "a")
		assert.same(h:has("a"), true)
		assert.same(h:has("b"), false)
	end)
	it(":upsert works", function()
		local h = headers.new()
		h:append("a", "a", false)
		h:append("b", "b", true)
		h:append("c", "c", false)
		assert.same(3, #h)
		h:upsert("b", "foo", false)
		assert.same(3, #h)
		assert.same("foo", h:get("b"))
		h:upsert("d", "d", false)
		assert.same(4, #h)
		local iter, state = h:each()
		assert.same({"a", "a", false}, {iter(state)})
		assert.same({"b", "foo", false}, {iter(state)})
		assert.same({"c", "c", false}, {iter(state)})
		assert.same({"d", "d", false}, {iter(state)})
	end)
	it("never_index defaults to sensible boolean", function()
		local h = headers.new()
		h:append("content-type", "application/json")
		h:append("authorization", "supersecret")
		assert.same({"content-type", "application/json", false}, {h:geti(1)})
		assert.same({"authorization", "supersecret", true}, {h:geti(2)})
	end)
end)
