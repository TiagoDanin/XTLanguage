-- Options:
local msg_erro = true
local no_translation = ':('
local project_name = '001'
local hash_XTL = 'XTL'

--[==[
By 2016 Tiago Danin
GNU GENERAL PUBLIC LICENSE
Version 2, June 1991
see https://github.com/LuaAdvanced/XTLanguage/blob/master/LICENSE
]==]--

local XTL = {
	version = '0.0.alpha01',
	name = 'XTLanguage',
	author = 'Tiago Danin - 2016',
	license = 'GPL v2',
	page = 'github.com/LuaAdvanced/XTLanguage'
}

function XTL.load_redis(redis)
	redis = redis
	if redis:ping() then
		return true, true
	else
		return false, false
	end
	return
end

local hash_base = hash_XTL .. ':' .. project_name .. ':'

function XTL.user (id, set)
	local hash = hash_base .. 'ID:' .. id
	if set == 'del' then
		redis:del(hash)
		return hash, true
	elseif set then
		redis:set(hash, set)
		return set, true
	else
		if redis:get(hash) then
			return redis:get(hash), true
		else
			return no_translation, false
		end
	end
end

function XTL.set (lang, input, set)
	local hash = hash_base .. 'LANG:' .. lang .. ':IN:' .. input
	redis:set(hash, set)
	return set, true
end

function XTL.get (lang, input)
	local hash = hash_base .. 'LANG:' .. lang .. ':IN:' .. input
	if redis:get(hash) then
		local get = redis:get(hash)
		return get, true
	else
		return no, false
	end
end

function XTL.vote (lang, input, set, id)
	local hash = hash_base .. 'VOTE:' .. input
	if not redis:get(hash .. ':' .. set) then
		redis:set(hash .. ':' .. set .. ':ID:' .. id, 'OK')
		redis:set(hash .. ':' .. set, ':ID:' .. id)
		redis:incr(hash .. ':' .. set)
		redis:hset(hash .. ':' .. set)
	else
		if not redis:get(hash .. ':' .. set .. ':ID:' .. id) then
			redis:set(hash .. ':' .. set .. ':ID:' .. id, 'OK')
			redis:incr(hash .. ':' .. set)
		end
	end
end

return XTL
