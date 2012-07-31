META2MAKEFILE_PATH := D:\lua\tools\meta2makefile.exe
ADDUTF8BOM_PATH    := D:\lua\tools\addutf8bom.exe

ifeq ($(VERBOSE),)
Q := @
else
Q :=
endif
META2MAKEFILE := $(Q)"$(META2MAKEFILE_PATH)"
LUA           := $(Q)"D:\lua\lua5.1.exe"
LUAC          := $(Q)"D:\lua\luac5.1.exe"
LUAPP         := $(Q)$(LUA) "D:\lua\preprocess.lua"
ADDUTF8BOM    := $(Q)"$(ADDUTF8BOM_PATH)"
COPY          := $(Q)copy /Y
MKDIR         := $(Q)mkdir
RM            := $(Q)del /F /Q

PREPROCESS     := 1
COMPILE        := 1
RESOURCES_PATH := C:\Program Files\MTA San Andreas 1.3\server2\mods\deathmatch\resources\