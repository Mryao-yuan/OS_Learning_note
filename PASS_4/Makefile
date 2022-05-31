%.bin:%.s
	nasm -I include/ -o $@ $< 
master.img:loader.bin mbr_disk.bin
	bximage -hd=16 -q -mode=create -imgmode=flat -sectsize=512 master.img
	dd if=mbr_disk.bin of=master.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=master.img bs=512 seek=2 count=1 conv=notrunc
.PHONY:clear
clean:
	rm -rf *.bin
	rm -rf master*	
.PHNOY:bochs
bochs:master.img
	bochs -q
