package = "zile"
version = "git-1"
description = {
  license = "GPLv3+",
  homepage = "http://www.gnu.org/s/zile",
  detailed = "An editor building kit, bundled with zmacs: a lightweight Emacs clone.",
  summary = "Zile Implements Lua Editors",
}
source = {
  url = "git://github.com/gvvaughan/zile.git",
}
dependencies = {
  "alien >= 0.7.0",
  "lua >= 5.2",
  "luaposix >= 29",
  "lua-stdlib >= 35",
  "lrexlib-gnu >= 2.7.1",
}
external_dependencies = nil
build = {
  install_command = "make install luadir='$(LUADIR)'",
  copy_directories = {
    "bin",
    "docs",
  },
  type = "command",
  build_command = "./bootstrap && ./configure LUA='$(LUA)' LUA_INCLUDE='-I$(LUA_INCDIR)' --prefix='$(PREFIX)' --libdir='$(LIBDIR)' --datadir='$(LUADIR)' && make clean all",
}
