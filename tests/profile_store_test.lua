-- Run with Lua 5.3+ or: luatex --luaonly tests/profile_store_test.lua
-- Roblox service doubles exercise the real persistence module.
local realRequire=require
local config=assert(loadfile("magic/Config.lua"))()
local record,failRead,failWrite,attempts,token=nil,false,false,0,0
local backend={}
function backend:UpdateAsync(_,callback)
 attempts=attempts+1
 if failRead or failWrite then error("simulated unavailable DataStore") end
 local result=callback(record)
 if result then record=result end
 return result
end
game={GetService=function(_,name)
 if name=="DataStoreService" then return {GetDataStore=function() return backend end} end
 return {GenerateGUID=function() token=token+1 return "session"..token end}
end}
task={wait=function() end}
script={Parent={Config="config"}}
require=function(name) if name=="config" then return config end return realRequire(name) end
local function player(id)
 return {UserId=id,attributes={},SetAttribute=function(self,k,v) self.attributes[k]=v end,
 Kick=function(self,message) self.kicked=message end}
end
local function store() return assert(loadfile("magic/ProfileStore.lua"))() end
local a=player(1) local s=store()
local p=assert(s.Load(a))
assert(p.Gold==0 and p.HasCreature==false)
p.Gold=1000 p.HasCreature=true
assert(s.Save(a,false)) assert(record.Gold==1000 and record.HasCreature)
assert(s.Save(a,false)) assert(record.Gold==1000,"Save retry must not double gold")
local b=player(1) local other=store()
assert(other.Load(b)==nil and b.kicked,"Another server must not acquire a live session")
assert(s.Save(a,true))
b=player(1) local p2=assert(other.Load(b))
assert(p2.Gold==1000 and p2.HasCreature,"Rejoin must restore both values without offline income")
p2.Gold=2000 failWrite=true
assert(not other.Save(b,false)) assert(record.Gold==1000,"Failed save must preserve stored data")
failWrite=false assert(other.Save(b,false)) assert(record.Gold==2000)
record.Session="newer-server"
assert(not other.Save(b,false) and b.kicked,"Old session must not overwrite a new server")
assert(record.Gold==2000 and record.Session=="newer-server")
failRead=true local c=player(2)
assert(store().Load(c)==nil and c.kicked,"Failed load must not create a zero profile")
failRead=false record={Schema=99,Gold=999,HasCreature=true}
assert(store().Load(player(3))==nil and record.Gold==999,"Unsupported schema must not be erased")
print("PASS: new profile, idempotent save, session lock, rejoin, save/load failure, stale session, schema protection")
for _,path in ipairs({"terrain/TerrainBuilder.server.lua","terrain/BaseOwnership.server.lua","magic/Game.lua","magic/Bootstrap.server.lua","magic/CreatureVisual.lua","client/GoldHUD.client.lua"}) do
 assert(loadfile(path))
end
print("PASS: syntax for all game scripts")
