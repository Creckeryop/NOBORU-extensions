PervEdenIt=Parser:new("PervEden","http://www.perveden.com","ITA","PVEDENITA","PERVEDENITAENG")PervEdenIt.NSFW=true;PervEdenIt.API="/api/list/1/"local function a(string)return Stringify(string,JSON_STRING)end;local b=DownloadContent;function PervEdenIt:getManga(c,d,e)local f=b(self.Link..self.API)local g={}for h,i,j,k,l in f:gmatch('"h": (%d-),[^}]-"i": "(%S-)",[^}]-"im": (%S-),[^}]-"ld": (%S-),[^}]-"t": "([^"]-)"')do g[#g+1]={h=tonumber(h),id=i,img=j=="null"and""or"cdn.perveden.com/mangasimg/"..(j:match('"(%S-)"')or"")or"",ld=tonumber(k),Name=l}if#g%50==0 then coroutine.yield(false)end end;table.sort(g,d)for m,n in ipairs(g)do local o=a(n.Name)if not e or o:upper():find(e:upper())then c[#c+1]=CreateManga(o,n.id,n.img,self.ID,n.id)end;if m%50==0 then coroutine.yield(false)end end end;function PervEdenIt:getPopularManga(p,c)self:getManga(c,function(q,r)return q.h>r.h end)c.NoPages=true end;function PervEdenIt:getLatestManga(p,c)self:getManga(c,function(q,r)return q.ld>r.ld end)c.NoPages=true end;function PervEdenIt:searchManga(s,p,c)local t=string.gsub;string.gsub=function(self,u,v)return t(self,v,u)end;s=s:gsub("!","%%%%21"):gsub("#","%%%%23"):gsub("%$","%%%%24"):gsub("&","%%%%26"):gsub("'","%%%%27"):gsub("%(","%%%%28"):gsub("%)","%%%%29"):gsub("%*","%%%%2A"):gsub("%+","%%%%2B"):gsub(",","%%%%2C"):gsub("%.","%%%%2E"):gsub("/","%%%%2F"):gsub(" ","%+"):gsub("%%","%%%%25")string.gsub=t;self:getManga(c,function(q,r)return q.ld>r.ld end,s)c.NoPages=true end;function PervEdenIt:getChapters(w,c)local f=b(self.Link.."/api/manga/"..w.Link):match('"chapters"(.-)"chapters_len"')or""local g={}for x,y,i in f:gmatch('%[%s-(%S-),[^,%]]-,([^,]-),[^%]]-"([^"]-)"[^%]]-%]')do g[#g+1]={Name=x.." : "..a(y:match('"([^"]-)"')or w.Name),Link=i,Pages={},Manga=w}end;for z=#g,1,-1 do c[#c+1]=g[z]end end;function PervEdenIt:prepareChapter(A,c)local f=b(self.Link.."/api/chapter/"..A.Link):match('images"(.-)$')local g={}for B in f:gmatch('"(%S-)"')do g[#g+1]="cdn.perveden.com/mangasimg/"..B end;for z=#g,1,-1 do c[#c+1]=g[z]end end;function PervEdenIt:loadChapterPage(B,c)c.Link=B end;PervEdenEn=PervEdenIt:new("PervEden","https://www.perveden.com","ENG","PVEDENENG","PERVEDENITAENG")PervEdenEn.NSFW=true;PervEdenEn.API="/api/list/0/"Extensions.Register("PERVEDENITAENG",{Type="Parsers",Name="PervEden",Link="http://www.perveden.com",Language={"ENG","ITA"},ID="PERVEDENITAENG",Version=2,NSFW=true,Parsers={PervEdenEn,PervEdenIt},LatestChanges="Fixed images parser"})