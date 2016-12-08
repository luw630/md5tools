require("lfs")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

local CoreVersion=CONFIG_CORE_VERSION_Other
local CoreVersion_Anroid=CONFIG_CORE_VERSION_Android

local VersionNode=
{
  [1]="ios",
  [2]="android",
  [3]="other"
}

local VersionCore=
{
  ["ios"]=CONFIG_CORE_VERSION_Ios,
  ["android"]=CONFIG_CORE_VERSION_Android,
  ["other"]=CONFIG_CORE_VERSION_Other
}

function MainScene:onExit()
end

function MainScene:getFileLen(path)
    local file = io.open(path, "rb")
    if file == nil then
        return 0
    end
    local content = file:read("*a")
    io.close(file)
    return string.len(content)
end

function MainScene:onEnter()
local md5Table={}
local dirFile=io.open("dir.txt", "r")
local dirKey="out\\"
local keyLength=string.len(dirKey)
local count=1
    for dirLine in dirFile:lines() do
	if string.find(dirLine,"launcher.zip")==nil and string.find(dirLine,"serverList.json")==nil 
	   and string.find(dirLine,"flist.json")==nil and string.find(dirLine,"platform.json")==nil 
	   and string.find(dirLine,"version.json")==nil and string.find(dirLine,"version.json")==nil then
	       localmd5 = CCCrypto:MD5File(dirLine)
	       local len=self:getFileLen(dirLine)
	       md5Table[count]={}
	       local resIndex=string.find(dirLine,dirKey, 1, false)
	       dirLine=string.sub(dirLine, resIndex+keyLength, -1)
	       dirLine= string.gsub(dirLine,"\\","/")
	       md5Table[count].file=dirLine
	       md5Table[count].md5=localmd5
	       md5Table[count].len=len
	       count=count+1
       end
    end
    self:write_flist("./flist.json",md5Table)
    self:write_version("./version.json")
          os.exit()
end

function MainScene:write_flist(path,table)
    local content = "{\n"
    local count=1
    local totalCount=#table
    for key,value in pairs(table) do
        if value ~= nil then
	    local fileDesc="\n\t\t\""..count.."\":"
	    if count<totalCount then
		fileDesc =fileDesc.. "{ \"file\":\""..value.file.."\", \"md5\":\""..value.md5.."\", \"size\":"..value.len.."},"
	    else
		fileDesc = fileDesc.."{ \"file\":\""..value.file.."\", \"md5\":\""..value.md5.."\", \"size\":"..value.len.."}"
	    end
            content = content..fileDesc
	    count=count+1
        end
    end
    content = content.."\n}\n"
    self:write_file(path, content,"w+b")

end
--[[
function MainScene:write_version(path)
    local content = "local version ={\n" .. "\tcore=\""..CoreVersion.."\",\n" .."version=\""..self:getSvnVersion().."\"\n}"
    content = content.."\nreturn version"
    self:write_file(path, content,"w+b")
end
--]]

function MainScene:write_version(path)
    local content = "{\n"
    local count=1
    local totalCount=#VersionNode
    for i,platform in  pairs(VersionNode) do
	local str="  \""..platform.."\":{\n"
	if count<totalCount then
		str=str.."\t\"core\":\""..VersionCore[platform].."\",\n" .."\t\"version\":\""..self:getSvnVersion(platform).."\"\n\t},"
	else
		str=str.."\t\"core\":\""..VersionCore[platform].."\",\n" .."\t\"version\":\""..self:getSvnVersion(platform).."\"\n\t}"
	end
	count=count+1
	content=content..str.."\n"
    end
    content = content.."}\n"
    self:write_file(path, content,"w+b")
end

function MainScene:getSvnVersion(platform)
	local version="0."..VersionCore[platform]
	local versionFile=io.open("svnversion.txt", "r")
	local str=""
	for dirLine in versionFile:lines() do
	     print("dirLine  "..dirLine)
	     local length=string.len(dirLine)
	     for i=1,length do
		local char=string.sub(dirLine,i,i)
		if tonumber(char)~=nil then
			print("char------"..char)
			str=str..char
		end
	     end
	     
	end
	version=version.."."..str
	print("version  "..version)
	return version
end

function MainScene:write_file(path,content,mode)
    mode = mode or "w+b"
    local file,errorinfo = io.open(path, mode)
    local cd=lfs.currentdir()
    if file then
        local hr,err = file:write(content)
        if hr == nil then
            print(err)
            io.close(file)
            return false
        end
        io.close(file)
        return true
    else
        print("can't open file:"..path)
        return false
    end
end

function MainScene:onExit()
end
return MainScene
