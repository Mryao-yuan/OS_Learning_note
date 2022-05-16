# 部署工作环境

## 创建启动盘

利用bximage创建

bximage -hd -mode="flat" -size=60 -q hd60M.img

-hd/-fd 创建硬盘/软盘
-mode 创建的硬盘类型：flat/sparse/growing
-size 硬盘的大小 MB为单位
-q 默认方式创建
