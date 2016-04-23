XTL = require('src/XTL')

-- Redis wget https://raw.githubusercontent.com/nrk/redis-lua/version-2.0/src/redis.lua
redis_server = require('redis')
redis = redis_server.connect('127.0.0.1', 6379)

local ping = XTL.load_redis(redis)
if ping then
	print('REDIS OK :)')
else
	print('REDIS with problems :(')
end
local lang = XTL.user("TiagoDanin", "EN")
print('LANG USER: ' .. lang)
local ok = XTL.set(lang, 'test', 'test... test ...')
print('SET: ' .. ok)
if ok then
	print('GET: ' .. XTL.get(lang, 'test'))
else
	print('GET: Error!')
end
