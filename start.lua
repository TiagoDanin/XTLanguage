XTL = require('src/XTL')

-- Redis wget https://raw.githubusercontent.com/nrk/redis-lua/version-2.0/src/redis.lua
redis_server = require('redis')
redis = redis_server.connect('127.0.0.1', 6379)

print('\n\nREDIS! TEST!')
-- REDIS
local ping = XTL.load_redis(redis)
if ping then
	print('REDIS OK :)')
else
	print('REDIS with problems :(')
end

print('\n\nTranslate! TEST!')
-- Translate
local lang = XTL.user("TiagoDanin", "EN")
print('LANG USER: ' .. lang)
local ok = XTL.set(lang, 'test', 'test... test ...')
print('SET: ' .. ok)
if ok then
	print('GET: ' .. XTL.get(lang, 'test'))
else
	print('GET: Error!')
end

print('\n\nVote translate! TEST!')
-- Vote translate
print('USER X1 Voted')
XTL.vote('EN', 'test', 'TEST.......', 'X1')

print('USER X2 Voted')
XTL.vote('EN', 'test', 'TEST.......', 'X2')

print('USER X3 Voted')
XTL.vote('EN', 'test', 'TEST..TEST', 'X3', false, 21)

print('USER TiagoDanin Voted')
XTL.vote('EN', 'test', 'TEST!', 'TiagoDanin', true, 50) -- :V

print('\n LIST VOTES')
local result = 0
for v,i in pairs(XTL.listvote('EN', 'test')) do
	print(v .. '   ==  ' .. i)
	result =  result + i
end
print('Total: ' .. result)

XTL.sync('EN', 'test')
print('\nWIN Translate')
print(XTL.get('EN', 'test'))
