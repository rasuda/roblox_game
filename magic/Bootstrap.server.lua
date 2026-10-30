workspace:SetAttribute("MagicStatus","Iniciando sistema")
local ok,err=xpcall(function() require(script.Parent:WaitForChild("Game",10)) end,debug.traceback)
if not ok then
 warn("[MagicGame] "..tostring(err))
 workspace:SetAttribute("MagicStatus","Erro na inicialização")
 workspace:SetAttribute("MagicError",string.sub(tostring(err),1,250))
end
