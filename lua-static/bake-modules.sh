# Bake static Lua modules into the interpreter being built. Sourced from the
# lua derivation's preBuild (sourced, not executed, so the structuredAttrs bash
# arrays below are in scope).
#
# From the derivation environment:
#   staticModulePaths[]    module outputs (lib/lua/**/*.a + *-rocks/manifest)
#   staticModuleLibDeps[]  their C-library deps (ship lib/pkgconfig/*.pc)
#   staticGenScript        lua script: writes staticmods.c, lists C archives
#   staticPathExtra        LUA_PATH_DEFAULT_EXTRA value (modules' Lua companions)
# Tools from the environment: $AR, $PKG_CONFIG and `lua` (build-platform).

_bake_modules() {
  local m mf dep pc
  local manifests=()
  for m in "${staticModulePaths[@]}"; do
    for mf in "$m"/*-rocks/manifest; do manifests+=("$mf"); done
  done

  # staticmods.c (the package.preload registration table) + the list of C
  # archives the interpreter must link, both derived from the rock manifests.
  local archives=()
  mapfile -t archives < <(lua "$staticGenScript" src/staticmods.c "${manifests[@]}")

  : > src/staticmods.mk

  # The link pulls the module objects (needed by the preload table baked into
  # liblua.a) while those objects call back into liblua.a's core API -- a
  # cross-archive cycle. Wrap the interpreter link in a linker group.
  echo 'override MYLDFLAGS += -Wl,--start-group' >> src/staticmods.mk

  # Bake the modules' Lua companions onto the compiled-in search path.
  echo "override MYCFLAGS += -DLUA_PATH_DEFAULT_EXTRA='\"$staticPathExtra\"'" >> src/staticmods.mk

  # External C libraries the archives reference (sqlite -> -lsqlite3 -lz, ...).
  # The deps are in buildInputs, so stdenv already put their lib/pkgconfig on
  # PKG_CONFIG_PATH; ask the host pkg-config for the combined static link line.
  local pcnames=()
  for dep in "${staticModuleLibDeps[@]}"; do
    for pc in "$dep"/lib/pkgconfig/*.pc; do
      [ -e "$pc" ] && pcnames+=("$(basename "$pc" .pc)")
    done
  done
  local extralibs=""
  [ ${#pcnames[@]} -gt 0 ] && extralibs=$("$PKG_CONFIG" --static --libs "${pcnames[@]}")

  # Close the group after the module archives and their external libs.
  echo "override MYLIBS += ${archives[*]} $extralibs -Wl,--end-group" >> src/staticmods.mk

  # Hand postFixup the module archives (to re-form liblua.a as a thin archive)
  # and the external libs (to complete lua's pkg-config for embedders).
  printf '%s\n' "${archives[@]}" > src/staticmods.archives
  printf '%s\n' "$extralibs" > src/staticmods.extralibs

  echo "[static-modules] baked: ${archives[*]}"
  cat src/staticmods.mk
}
_bake_modules
