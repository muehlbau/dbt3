all: dbgen_exe util_exe

dbgen_exe:
	cd datagen/dbgen; $(MAKE)

util_exe:
	cd dbdriver/utils; $(MAKE)

clean:
	cd datagen/dbgen; $(MAKE) clean
	cd dbdriver/utils; $(MAKE) clean
