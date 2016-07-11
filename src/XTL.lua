-- Options:
local no_translation = true
local msg_noTranslation = ':( Sorry'
local default_language = 'EN'
local project_name = 'XTL01'
local hash_XTL = 'XTL'

--[==[
By 2016 Tiago Danin
GNU GENERAL PUBLIC LICENSE
Version 2, June 1991
see https://github.com/TiagoDanin/XTLanguage/blob/master/LICENSE
]==]--

local XTL = {
	version = '0.1.alpha0',
	name = 'XTLanguage',
	author = 'Tiago Danin - 2016',
	license = 'GPL v2',
	page = 'github.com/LuaAdvanced/XTLanguage'
}


function XTL.load_redis(redis)
	redis = redis
	if redis:ping() then
		return true, true
	end
	return false, false
end


local hash_base = hash_XTL .. ':' .. project_name .. ':'


function XTL.user (id, set, force)
	local hash = hash_base .. 'ID:' .. id
	if set and set == 'del' then
		redis:del(hash)
		return hash, true

	elseif set then
		redis:set(hash, set)
		return set, true

	elseif redis:get(hash) then
		return redis:get(hash), true

	elseif force then
		return default_language, true

	end
	return false, false
end


function XTL.set (lang, input, set)
	local hash = hash_base .. 'LANG:' .. lang .. ':' .. input
	redis:set(hash, set)
	redis:hset(hash_base .. 'LANG:' .. lang .. ':LIST', input, set)
	return set, true
end


function XTL.get (lang, input)
	local hash = hash_base .. 'LANG:' .. lang .. ':' .. input
	if redis:get(hash) then
		redis:incr(hash .. ':USE')
		local get = redis:get(hash)
		return get, true

	elseif no_translation then
		return msg_noTranslation, false

	end
	return false, false
end


function XTL.list (lang)
	local hash = hash_base .. 'LANG:' .. lang
	local table = redis:hgetall(hash .. ':LIST')
	return table, true
end


function XTL.shor (id, input)
	local lang = XTL.user(id, false, true)
	local res = XTL.get(lang, input)
	return res, true
end


function XTL.vote (lang, input, set, id, force, pont)
	local hash = hash_base .. 'VOTE:' .. lang .. ':' .. input
	if not redis:get(hash .. 'USER: ' .. id) or force then
		if pont then
			redis:incrby(hash .. ':' .. set .. 'VOTE', pont)
			redis:set(hash .. 'USER: ' .. id .. ':PONT', pont)
		else
			redis:incr(hash .. ':' .. set .. 'VOTE')
		end

		local n = redis:get(hash .. ':' .. set .. 'VOTE')
		redis:hset(hash .. ':LIST', set, n)
		redis:set(hash .. 'USER: ' .. id, set)
		return set, true

	elseif redis:get(hash .. 'USER: ' .. id) then
		local ex_set = redis:get(hash .. 'USER: ' .. id)
		if redis:get(hash .. 'USER: ' .. id .. ':PONT') then
			redis:decrby(hash .. ':' .. ex_set .. 'VOTE', redis:get(hash .. 'USER: ' .. id .. ':PONT'))
			redis:set(hash .. 'USER: ' .. id .. ':PONT', 1)
		else
			redis:decr(hash .. ':' .. ex_set .. 'VOTE')
		end

		if pont then
			redis:incrby(hash .. ':' .. set .. 'VOTE', pont)
			redis:set(hash .. 'USER: ' .. id .. ':PONT', pont)
		else
			redis:incr(hash .. ':' .. set .. 'VOTE')
		end

		local n = redis:get(hash .. ':' .. set .. 'VOTE')
		redis:hset(hash .. ':LIST', set, n)
		redis:set(hash .. 'USER: ' .. id, set)
		return set, true

	end
	return false, false
end


function XTL.listvote (lang, input)
	local hash = hash_base .. 'VOTE:' .. lang .. ':' .. input
	local table = redis:hgetall(hash .. ':LIST')
	return table, true
end


function XTL.sync (lang, input)
	local set = msg_noTranslation
	local check = 0
	for v,i in pairs(XTL.listvote(lang, input)) do
		i = math.floor(i)
		if check < i then
			check = i
			set = v
		end
	end
	XTL.set(lang, input, set)
	return set, true
end


return XTL
