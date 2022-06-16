%.bin:%.s
	nasm -I include/ -o $@ $< 
build/master.img:boot/loader.bin boot/mbr.bin
ifeq ("$(wildcard masetr.img)","")
	bximage -hd=16 -q -mode=create -imgmode=flat -sectsize=512 $@
endif
	dd if=boot/mbr.bin of=build/master.img bs=512 count=1 conv=notrunc
	dd if=boot/loader.bin of=build/master.img bs=512 seek=2 count=1 conv=notrunc

.PHONY:clear
clean:
	rm -rf boot/*.bin
	rm -rf build/master*	
	rm -rf master*
	rm -rf build/bx_enh_dbg.ini	

.PHNOY:bochs
bochs:build/master.img
	cd build && bochs -q