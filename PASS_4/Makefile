%.bin:%.s
	nasm -I include/ -o $@ $< 
build/master.img:src/loader.bin src/mbr_disk.bin
ifeq ("$(wildcard masetr.img)","")
	bximage -hd=16 -q -mode=create -imgmode=flat -sectsize=512 $@
endif
	dd if=src/mbr_disk.bin of=build/master.img bs=512 count=1 conv=notrunc
	dd if=src/loader.bin of=build/master.img bs=512 seek=2 count=1 conv=notrunc

.PHONY:clear
clean:
	rm -rf src/*.bin
	rm -rf build/master*	
	rm -rf master*
	rm -rf build/bx_enh_dbg.ini	

.PHNOY:bochs
bochs:build/master.img
	cd build && bochs -q
