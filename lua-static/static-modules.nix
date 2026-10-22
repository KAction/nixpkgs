{
  pkgs ? import ../. { },
}:

let
  lib = pkgs.lib;

  staticLua = pkgs.pkgsStatic.lua5_1;

  # Native (build-platform) lua used only to parse rock manifests at build time.
  parseLua = pkgs.lua5_1;

  # Relink a (static) lua, baking the given module derivations' archives into
  # liblua.a and registering every module they declare into package.preload.
  #
  # modules :: list of buildLuarocksPackage derivations (pkgsStatic.lua5_1.pkgs.*)
  # Each installs lib/lua/5.1/<name>.a plus a *-rocks/manifest whose `modules`
  # table lists the require-names it provides (authoritative; a single archive
  # may back several modules).
  withStaticModules =
    lua: modules:
    let
      # Merged tree of the modules' Lua companions (socket.lua, ltn12.lua, ...).
      # One store path regardless of module count; its share/lua/5.1 is baked
      # into LUA_PATH_DEFAULT so the library (hence any embedder, not just the
      # wrapped CLI) finds them.
      luaEnv = pkgs.buildEnv {
        name = "lua-static-modules-env";
        paths = modules;
        ignoreCollisions = true;
      };
      # Prepended to LUA_PATH_DEFAULT (via the guarded macro the patch adds) so
      # the modules' Lua companions are found with no LUA_PATH, for the CLI and
      # any liblua embedder.
      extraPath = "${luaEnv}/share/lua/5.1/?.lua;${luaEnv}/share/lua/5.1/?/init.lua;";

      # The modules' C-library dependencies (e.g. sqlite for lsqlite3). Each
      # module's buildInputs carries them next to the lua-module framework deps;
      # filter out the latter (they carry a `luaModule` marker). Their objects
      # are referenced by the baked-in archives, so the final lua link must pull
      # them in -- discovered via pkg-config at build time.
      moduleLibDeps = lib.unique (
        lib.concatMap (m: lib.filter (d: !(d ? luaModule)) (m.buildInputs or [ ])) modules
      );
    in
    lua.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./preload-statics.patch ];

      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        parseLua
        # from the static set so nativeBuildInput splicing yields the
        # host-targeting cross wrapper ($PKG_CONFIG = <host>-pkg-config).
        pkgs.pkgsStatic.pkg-config
      ];
      buildInputs = (old.buildInputs or [ ]) ++ moduleLibDeps;

      # Consumed by bake-modules.sh (arrays rely on __structuredAttrs).
      staticModulePaths = modules;
      staticModuleLibDeps = moduleLibDeps;
      staticGenScript = ./gen-statics.lua;
      staticPathExtra = extraPath;

      preBuild = (old.preBuild or "") + ''
        source ${./bake-modules.sh}
      '';

      # Re-form the installed liblua.a as a thin archive over the (renamed) fat
      # core plus every module's archive. All members are immutable store paths,
      # so nix preserves them; embedders linking -llua pull the static modules
      # with no object copying, and the single thin archive resolves the
      # core<->module symbol cycle internally (no --start-group needed).
      #
      # Done in postFixup: the strip of fixupPhase would corrupt a thin archive,
      # so let it strip the fat core first, then re-form the thin archive over it.
      postFixup = (old.postFixup or "") + ''
        extralibs=$(cat src/staticmods.extralibs)
        mapfile -t mods < src/staticmods.archives
        mv "$out/lib/liblua.a" "$out/lib/liblua-core.a"
        $AR rcsT "$out/lib/liblua.a" "$out/lib/liblua-core.a" "''${mods[@]}"

        # Propagate the modules' external C-lib deps so `pkg-config --libs lua`
        # links an embedder with no manual -l flags. They go in Libs (not
        # Libs.private): liblua.a is a static archive, so consumers always pull
        # the module objects and hence always need these. The resolved -L store
        # paths also keep the deps in lua's closure. Every *.pc is edited: lua's
        # versioned names start as symlinks to lua.pc but fixupPhase's includedir
        # patch has already turned them into independent regular files.
        sed -i "s|^Libs:.*|& $extralibs|" "$out"/lib/pkgconfig/*.pc
      '';
    });

in
withStaticModules staticLua [
  pkgs.pkgsStatic.lua5_1.pkgs.luafilesystem
  pkgs.pkgsStatic.lua5_1.pkgs.luasocket
  pkgs.pkgsStatic.lua5_1.pkgs.lsqlite3
]
