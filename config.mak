PREPROCESS     := 1
COMPILE        := 1
UTF8_BOM       := 0
JOIN           := 0
PROTECT        := 0
ifeq ($(windir),)
 RESOURCES_PATH := /mnt/c/Program\ Files\ (x86)/MTA\ San\ Andreas\ 1.5/server/mods/deathmatch/resources/
else
 RESOURCES_PATH := C:/Program\ Files\ (x86)/MTA\ San\ Andreas\ 1.5/server/mods/deathmatch/resources/
endif
TEMP_DIR       := build
DEPLOY_HOST    := ravin.tk
DEPLOY_DIR     := /home/rafalh/mta/toxic/mods/deathmatch/resources
