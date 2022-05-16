mbr.bin:mbr.s
	nasm -o mbr.bin mbr.s
# 创建 master.img
master.img:mbr.bin
	bximage -q -mode=create -hd=16 -sectsize=512 -imgmode=flat master.img
# 将bin文件输出为 512 字节大小的 master.img 镜像 
	dd if=mbr.bin of=master.img bs=512 count=1 conv=notrunc

.PHONY:clean
clean:
	rm -rf *.bin
	rm -rf *.img
.PHONY:bochs
bochs:master.img	
	bochs -q
