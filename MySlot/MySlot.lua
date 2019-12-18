local MySlot_Profile={}
local MacroIcon = {}

for i=1, GetNumMacroIcons() do
	MacroIcon[(GetMacroIconInfo(i))] = i
end

local map_String={
	["spell"]="S",
	["macro"]="M",
	["item"]="I",
	["companion"]="C",
}

local function getSpellString(arg1,arg0)
	if arg1==0 then
		return ""
	end
	local a,b=GetSpellName(arg1,BOOKTYPE_SPELL)
	if b~="" then
		return a.."("..b..")"
	else
		return a
	end	
end

local companionitem=[[{["b"]="%s",["c"]=%d}]]
local function getCompanionString(arg0,arg1)
	return string.format(companionitem, arg0, arg1)
end

local function myPickupCompanion(arg1)
	if type(arg1)=="table" then
		PickupCompanion(arg1["b"], arg1["c"])
	end
end

--local macroitem=[[{["id"]=%s,["name"]="%s",["icon"]=%d,["body"]=%s,["perchar"]=%s,}]]
local macroitem=[[{["b"]="%s",["c"]=%d,["d"]=%s,["e"]=%s,}]]

local function getMacroString(arg1)
	local name, iconTexture, body, perchar,l = GetMacroInfo(arg1)
	if name and body then
		
		local iconx=MacroIcon[iconTexture] or 1
		if string.find(body,"#show")==1 then
			iconx=1
		end
		return string.format(macroitem,name, iconx,"[[".. body.."]]", tonumber(arg1)>36 and "1" or "nil")
	end
	return arg1
end

local function findMacro(arg1)
	for i=1,54 do
		local name, iconTexture, body, perchar = GetMacroInfo(i)
		local icon=MacroIcon[iconTexture] or 1
		if body==(arg1["d"]) then
			
			return EditMacro(i,arg1["b"],arg1["c"],(arg1["d"]),arg1["e"])
		end
	end
	
	return nil
end

local function myCreateMacro(arg1)
	local g,l = GetNumMacros()
	if ((arg1["e"] and l==18) or (arg1["e"]==nil and g==36)) then
		MySlot_Print("宏 ["..arg1["b"].." ] 被忽略，因为你没有在公共或个人宏区域没有足够的空格，请准备足够的空格后重新导入")
		return nil
	end
	return CreateMacro(arg1["b"],arg1["c"],(arg1["d"]),arg1["e"],1)
end

local function myGetMacroId(arg1)
	if type(arg1)=="table" then
		return findMacro(arg1) or myCreateMacro(arg1)
	end
	return arg1
end


local function myGetActionInfo(i)
	local arg0,arg1,arg2,arg3 = GetActionInfo(i)
	
	if map_String[arg0 or "x"] then
	
		if(arg0=="spell")then
			return "\"S\"","\""..getSpellString(arg1,arg0).."\""
		end	

		if(arg0=="macro")then
			return "\"M\"",getMacroString(arg1)
		end	
		
		if(arg0=="companion")then
			return "\"C\"",getCompanionString(arg2,arg1)
		end	

		return "\"I\"","\""..arg1.."\""
		
	end
	
	return nil
end

local function isChange(i)
	local arg0,arg1 = myGetActionInfo(i)
	
	if MySlot_Profile[i]==nil then
		return arg0~=nil
	end
	
	if MySlot_Profile[i]["a"]~=arg0 then
		return 1
	end 

	if MySlot_Profile[i]["b"]~=arg1 then
		return 1
	end 
	
	--[[
	由于 宏 指针 变化不确定 认为所有宏都发生了变化
	if arg0=="macro" then
		return not findMacro(arg1)
	end]]
	
	return nil
end

local keyitem=[[[%s]=%s,]]

local function myGetKeyBinding()
	local t={}
	for i=1,GetNumBindings() do
		command, key1, key2=GetBinding(i)	
		if key1=="\\" then
			key1="\\\\"
		end
		
		if key2=="\\" then
			key2="\\\\"
		end
		
		
		if key1 then
			t[#t+1]=string.format(keyitem,"\""..key1.."\"","\""..command.."\"")
		end
		
		if key2 then
			t[#t+1]=string.format(keyitem,"\""..key2.."\"","\""..command.."\"")
		end
		
	end
	
	return table.concat(t)
end

StaticPopupDialogs["MYSLOT_MSGBOX"] = {
	text = "你 确定 要导入么？？？",
	button1 = "确定",
	button2 = "取消",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1,
	OnAccept=function()
		local i,j,iv,jv
		local changed={}
		local add=nil
	
		for i=1,120 do
			if isChange(i) then
				tinsert(changed,i)	
			end				
		end
		
		for i,iv in pairs(changed) do
			if MySlot_Profile[iv]==nil then
					PickupAction(iv)
					ClearCursor()						
			elseif MySlot_Profile[iv].a=="S" then
				PickupSpell(MySlot_Profile[iv].b);
			elseif MySlot_Profile[iv].a=="I" then
				PickupItem(MySlot_Profile[iv].b)		
			elseif MySlot_Profile[iv].a=="M" then
				PickupMacro(myGetMacroId(MySlot_Profile[iv].b))
			elseif MySlot_Profile[iv].a=="C" then
				myPickupCompanion(MySlot_Profile[iv].b)
			elseif MySlot_Profile[iv].a=="nil" then
					PickupAction(iv)
					ClearCursor()
			elseif MySlot_Profile[iv].a==nil then
					PickupAction(iv)
					ClearCursor()					
			end
			
			PlaceAction(iv)	
			ClearCursor()
	
		end		
		
		if MySlot_Profile[999] then
			for i,v in pairs(MySlot_Profile[999]) do
				SetBinding(i,v)
			end
		end
		
		MySlot_Print("所有按钮及按键邦定位置恢复完毕")
	end,
}


local slotitem=[[[%d]={["a"]=%s,["b"]=%s,},]]

function MySlot_Export()
	local s=""
	local i
	local t={}
	for i=1,120 do
		local arg0,arg1 = myGetActionInfo(i)
			if arg0 then
				t[#t+1]=string.format(slotitem,i,arg0,arg1)
			end
	end	
	
	t[#t+1]="[999]={"..myGetKeyBinding().."},"
	
	s="@ --------------------\n"..s
	s="@ 问题/建议请联系 farmer1992@gmail.com\n"..s
	s="@ \n"..s
	s="@ 等级："..UnitLevel("player").."\n"..s
	s="@ 职业："..UnitClass("player").."\n"..s
	s="@ 人物："..UnitName("player").."\n"..s
	s="@ 天赋："..select(3,GetTalentTabInfo(1)).."/"..select(3,GetTalentTabInfo(2)).."/"..select(3,GetTalentTabInfo(3)).."\n"..s
	s="@ Myslot 导出数据"..date().."\n"..s
	
	s=s..HumBase64.enc(table.concat(t))

	--s=s..(table.concat(t))

	MYSLOT_ReportFrame_EditBox:SetText(s)
	MYSLOT_ReportFrame_EditBox:HighlightText()

end

function MySlot_Import()

	if InCombatLockdown() then
		MySlot_Print("请在非战斗时候使用导入功能")
	end

	local s=MYSLOT_ReportFrame_EditBox:GetText() or ""
	s=string.gsub(s,"(@.[^\n]*\n)","")
	s=string.gsub(s,"\n","")
	s=string.gsub(s,"\r","")
	s=HumBase64.dec(s)
	
	--MYSLOT_ReportFrame_EditBox:SetText(s)
	--MYSLOT_ReportFrame_EditBox:HighlightText()	
	
	local f=loadstring("return {"..s.."}")
	if f and s~="" then
		MySlot_Profile=f()

		StaticPopup_Show("MYSLOT_MSGBOX")
	else
		MySlot_Print("导入字符串有错误 不能导入")
	end
	
end


function MySlot_Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|CFFFF0000<|r|CFFFFD100My Slot|r|CFFFF0000>|r"..(msg or ""))
end

SlashCmdList["Myslot"] = function()
	MYSLOT_ReportFrame:Show()
end
SLASH_Myslot1 = "/Myslot"



function MySlot_Clearall()
		for i=1,120 do
				PickupAction(i)
				ClearCursor()
		end
end
