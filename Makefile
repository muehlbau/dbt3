all: common_obj dbgen_exe util_exe

dbgen_exe:
	cd datagen/dbgen; $(MAKE)

common_obj:
	cd dbdriver/common; $(MAKE)

util_exe:
	cd dbdriver/utils; $(MAKE)

clean:
	cd datagen/dbgen; $(MAKE) clean
	cd dbdriver/common; $(MAKE) clean
	cd dbdriver/utils; $(MAKE) clean
