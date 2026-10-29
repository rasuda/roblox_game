local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Config = require(script.Parent.Config)
local backend = DataStoreService:GetDataStore(Config.DataStoreName)
local Store = {}
local profiles = {}
local function key(player) return "Player_" .. player.UserId end
local function valid(data)
 return type(data)=="table" and data.Schema==1 and type(data.Gold)=="number"
  and data.Gold==data.Gold and data.Gold>=0 and data.Gold<9e15
  and type(data.HasCreature)=="boolean"
end

function Store.Load(player)
 local token=HttpService:GenerateGUID(false)
 player:SetAttribute("SaveStatus","Carregando...")
 for attempt=1,6 do
  local ok,data=pcall(function()
   return backend:UpdateAsync(key(player),function(old)
    if old==nil then old={Schema=1,Gold=0,HasCreature=false} end
    if not valid(old) then return nil end
    if old.Session and old.Session~=token and (old.LeaseUntil or 0)>os.time() then return nil end
    old.Session=token old.LeaseUntil=os.time()+Config.LeaseSeconds
    return old
   end)
  end)
  if ok and data and data.Session==token and valid(data) then
   local profile={Gold=data.Gold,HasCreature=data.HasCreature,Token=token,
    LeaseUntil=data.LeaseUntil,Saving=false,Closing=false,Lost=false}
   profiles[player]=profile
   player:SetAttribute("Gold",profile.Gold)
   player:SetAttribute("HasCreature",profile.HasCreature)
   player:SetAttribute("SaveStatus","Salvo")
   player:SetAttribute("DataReady",true)
   return profile
  end
  task.wait(2)
 end
 -- Never substitute a zero balance after a failed read.
 player:SetAttribute("SaveStatus","Falha ao carregar")
 player:Kick("Não foi possível carregar seu ouro com segurança. Aguarde alguns segundos e entre novamente.")
 return nil
end

function Store.Get(player)
 local p=profiles[player]
 if p and not p.Closing and not p.Lost and p.LeaseUntil>os.time()+15 then return p end
 return nil
end

function Store.Save(player,release)
 local p=profiles[player]
 if not p then return false end
 if release then p.Closing=true end
 while p.Saving do task.wait(.1) end
 if profiles[player]~=p or p.Lost then return false end
 p.Saving=true
 local gold,hasCreature=p.Gold,p.HasCreature
 player:SetAttribute("SaveStatus","Salvando...")
 local success=false
 for attempt=1,Config.SaveAttempts do
  local ok,result=pcall(function()
   return backend:UpdateAsync(key(player),function(old)
    if not valid(old) or old.Session~=p.Token then return nil end
    local record={Schema=1,Gold=gold,HasCreature=hasCreature,UpdatedAt=os.time()}
    if not release then record.Session=p.Token record.LeaseUntil=os.time()+Config.LeaseSeconds end
    return record
   end)
  end)
  if ok and result then
   success=true
   if not release then p.LeaseUntil=result.LeaseUntil end
   break
  elseif ok then
   p.Lost=true
   player:Kick("Sua sessão de dados mudou. Entre novamente para proteger seu ouro.")
   break
  end
  task.wait(attempt)
 end
 p.Saving=false
 player:SetAttribute("SaveStatus",success and "Salvo" or "Falha ao salvar; tentando novamente")
 if release then profiles[player]=nil end
 return success
end

function Store.Publish(player)
 local p=profiles[player]
 if p then
  player:SetAttribute("Gold",p.Gold)
  player:SetAttribute("HasCreature",p.HasCreature)
 end
end
return Store
