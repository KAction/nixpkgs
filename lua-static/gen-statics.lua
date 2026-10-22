-- Generate the static-modules preload table and list their C archives.
-- Usage: lua gen-statics.lua <out-staticmods.c> <rock-manifest>...
--
-- Writes the package.preload registration table (extern decls + a luaL_Reg[])
-- to <out-staticmods.c>, and prints each C module's archive path (absolute,
-- unique, sorted) one per line for the link step.
--
-- A luarocks manifest is Lua source assigning bare globals; its `repository`
-- tree maps each module name to its installed file. The C modules are those
-- whose file is a static archive (*.a) -- pure-Lua modules have no luaopen_
-- symbol to register. The archive path is <rock-tree>/lib/lua/5.1/<file>.

local out = arg[1]

local archiveOf = {} -- require-name -> absolute archive path
for i = 2, #arg do
  local manifest = arg[i]
  local root = manifest:gsub("/[^/]+%-rocks/manifest$", "")
  local env = {}
  local chunk = assert(loadfile(manifest))
  setfenv(chunk, env)
  chunk()
  for _rock, versions in pairs(env.repository or {}) do
    for _ver, entries in pairs(versions) do
      for _, entry in ipairs(entries) do
        for name, file in pairs(entry.modules or {}) do
          if type(file) == "string" and file:match("%.a$") then
            archiveOf[name] = root .. "/lib/lua/5.1/" .. file
          end
        end
      end
    end
  end
end

local names = {}
for name in pairs(archiveOf) do
  names[#names + 1] = name
end
table.sort(names)

local function sym(name)
  return (name:gsub("%.", "_"))
end

local f = assert(io.open(out, "w"))
f:write('#include "lua.h"\n')
f:write('#include "lauxlib.h"\n')
for _, name in ipairs(names) do
  f:write(("extern int luaopen_%s(lua_State *L);\n"):format(sym(name)))
end
f:write("const luaL_Reg staticmods[] = {\n")
for _, name in ipairs(names) do
  f:write(('  { "%s", luaopen_%s },\n'):format(name, sym(name)))
end
f:write("  { NULL, NULL }\n")
f:write("};\n")
f:close()

local seen, archives = {}, {}
for _, name in ipairs(names) do
  local a = archiveOf[name]
  if not seen[a] then
    seen[a] = true
    archives[#archives + 1] = a
  end
end
table.sort(archives)
for _, a in ipairs(archives) do
  print(a)
end
