# MAKEFILE HACK: http://devicesoftware.blogspot.com/2010/06/handling-path-with-white-spaces-in.html
nullstring :=          # creating a null string
space := $(nullstring) # end of the line
CURDIR2 := $(subst $(space),\ ,$(CURDIR))

ifeq ($(wildcard $(CURDIR2)/Makefile.auto),)

$(PROJECT_NAME): $(CURDIR2)/Makefile.auto
	$(MAKE)

$(CURDIR2)/Makefile.auto: $(CURDIR2)/meta.xml
	$(META2MAKEFILE) -o $(CURDIR2)/Makefile.auto -t $(PROJECT_NAME)_ -utf8 $(CURDIR2)/meta.xml

else

$(PROJECT_NAME): $(PROJECT_NAME)_files

include $(CURDIR2)/Makefile.auto

endif
