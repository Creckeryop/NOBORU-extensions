PervEdenIt = Parser:new("PervEden", "http://www.perveden.com", "ITA", "PVEDENITA", "PERVEDENITAENG")
PervEdenIt.NSFW = true
PervEdenIt.API = "/api/list/1/"

local function stringify(string)
	return Stringify(string, JSON_STRING)
end

local downloadContent = DownloadContent

function PervEdenIt:getManga(dest_table, sort, filter)
	local content = downloadContent(self.Link .. self.API)
	local t = {}
	for h, id, img, ld, Name in content:gmatch('"h": (%d-),[^}]-"i": "(%S-)",[^}]-"im": (%S-),[^}]-"ld": (%S-),[^}]-"t": "([^"]-)"') do
		t[#t + 1] = {h = tonumber(h), id = id, img = img == "null" and "" or "cdn.perveden.com/mangasimg/" .. (img:match('"(%S-)"') or "") or "", ld = tonumber(ld), Name = Name}
		if #t % 50 == 0 then
			coroutine.yield(false)
		end
	end
	table.sort(t, sort)
	for _, m in ipairs(t) do
		local name = stringify(m.Name)
		if not filter or name:upper():find(filter:upper()) then
			dest_table[#dest_table + 1] = CreateManga(name, m.id, m.img, self.ID, m.id)
		end
		if _ % 50 == 0 then
			coroutine.yield(false)
		end
	end
end

function PervEdenIt:getPopularManga(page, dest_table)
	self:getManga(
		dest_table,
		function(a, b)
			return a.h > b.h
		end
	)
	dest_table.NoPages = true
end

function PervEdenIt:getLatestManga(page, dest_table)
	self:getManga(
		dest_table,
		function(a, b)
			return a.ld > b.ld
		end
	)
	dest_table.NoPages = true
end

function PervEdenIt:searchManga(search, page, dest_table)
	local old_gsub = string.gsub
	string.gsub = function(self, one, sec)
		return old_gsub(self, sec, one)
	end
	search = search:gsub("!", "%%%%21"):gsub("#", "%%%%23"):gsub("%$", "%%%%24"):gsub("&", "%%%%26"):gsub("'", "%%%%27"):gsub("%(", "%%%%28"):gsub("%)", "%%%%29"):gsub("%*", "%%%%2A"):gsub("%+", "%%%%2B"):gsub(",", "%%%%2C"):gsub("%.", "%%%%2E"):gsub("/", "%%%%2F"):gsub(" ", "%+"):gsub("%%", "%%%%25")
	string.gsub = old_gsub
	self:getManga(
		dest_table,
		function(a, b)
			return a.ld > b.ld
		end,
		search
	)
	dest_table.NoPages = true
end

function PervEdenIt:getChapters(manga, dest_table)
	local content = downloadContent(self.Link .. "/api/manga/" .. manga.Link):match('"chapters"(.-)"chapters_len"') or ""
	local t = {}
	for num, title, id in content:gmatch('%[%s-(%S-),[^,%]]-,([^,]-),[^%]]-"([^"]-)"[^%]]-%]') do
		t[#t + 1] = {
			Name = num .. " : " .. stringify(title:match('"([^"]-)"') or manga.Name),
			Link = id,
			Pages = {},
			Manga = manga
		}
	end
	for i = #t, 1, -1 do
		dest_table[#dest_table + 1] = t[i]
	end
end

function PervEdenIt:prepareChapter(chapter, dest_table)
	local content = downloadContent(self.Link .. "/api/chapter/" .. chapter.Link):match('images"(.-)$')
	local t = {}
	for link in content:gmatch('"(%S-)"') do
		t[#t + 1] = "cdn.perveden.com/mangasimg/" .. link
	end
	for i = #t, 1, -1 do
		dest_table[#dest_table + 1] = t[i]
	end
end

function PervEdenIt:loadChapterPage(link, dest_table)
	dest_table.Link = link
end

PervEdenEn = PervEdenIt:new("PervEden", "https://www.perveden.com", "ENG", "PVEDENENG", "PERVEDENITAENG")
PervEdenEn.NSFW = true
PervEdenEn.API = "/api/list/0/"

Extensions.Register(
	"PERVEDENITAENG",
	{
		Type = "Parsers",
		Name = "PervEden",
		Link = "http://www.perveden.com",
		Language = {"ENG", "ITA"},
		ID = "PERVEDENITAENG",
		Version = 2,
		NSFW = true,
		Parsers = {
			PervEdenEn,
			PervEdenIt
		},
		LatestChanges = "Fixed images parser"
	}
)
