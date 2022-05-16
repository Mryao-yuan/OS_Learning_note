mbr.bin:mbr.s
	nasm  -o mbr.bin mbr.s
mbr_disk.bin:mbr_disk.s
	nasm -I include/ -o mbr_disk.bin mbr_disk.s
# -I path <add a pathname to the include file path>

# %.bin:%.s
#  nasm -o $<(输入) $@（输出） 

loader.bin:mbr_disk.s loader.s
	nasm -I include/ -o loader.bin loader.s

master.img:loader.bin mbr_disk.bin
	
	bximage -hd=16 -q -mode=create -imgmode=flat -sectsize=512 master.img

#	dd if=mbr.bin of=master.img bs=512 count=1 conv=notrunc
# 通过seek 将 loader写入硬盘第二个扇区
	dd if=mbr_disk.bin of=master.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=master.img bs=512 seek=2 count=1 conv=notrunc

.PHONY:clear
clean:
	rm -rf *.bin
	rm -rf master*	
.PHNOY:bochs
bochs:master.img
	bochs -q
