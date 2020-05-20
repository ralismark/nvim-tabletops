local tabletops = {}

local server

local function create_server(on_connection)
	local server = vim.loop.new_tcp()
	server:bind('127.0.0.1', 39998)
	server:listen(4, function(err)
		assert(not err, err)
		local sock = vim.loop.new_tcp()
		server:accept(sock)
		on_connection(sock)
	end)
	return server
end

local function on_receive(data)
	vim.schedule(function()
		vim.api.nvim_call_function("tabletops#on_receive", { data })
	end)
end

function tabletops.is_loaded()
	return server ~= nil
end

function tabletops.start()
	if tabletops.is_loaded() then
		return
	end
	server = create_server(function(sock)
		local data = ""
		sock:read_start(function(err, chunk)
			assert(not err, err)
			if chunk then
				data = data .. chunk
			else
				sock:close()
				on_receive(data)
			end
		end)
	end)
	print("Tabletops server started")
end

function tabletops.stop()
	if not tabletops.is_loaded() then
		return
	end
	server:close()
	server = nil
	print("Tabletops server stopped")
end

function tabletops.send(data)
	local client = vim.loop.new_tcp()
	client:connect("127.0.0.1", 39999, function(err)
		assert(not err, err)
		client:write(data, function(err)
			client:close()
			assert(not err, err)
		end)
	end)
end

return tabletops
