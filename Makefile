ROOT_D=${PWD}
ARCH_D=$(ROOT_D)/arch
OUT_D=$(ROOT_D)/out
CONFIG_D=$(ROOT_D)/conf

vers=5.7.6
initramfs_name=custom_initramfs

SRC_D=$(ROOT_D)/src
LINUX_SRC_D=$(SRC_D)/linux-$(vers)
INIT_SRC_D=$(SRC_D)/initramfs_min
PATCH_SRC_D=$(SRC_D)/ps3linux-patches-5.7.x

ARCH=$(ARCH_D)/linux-$(vers).tar.gz

INITRAMFS=$(OUT_D)/$(initramfs_name).gz
KERNEL=$(OUT_D)/arch_$(vers).tar.gz


all: $(INITRAMFS) $(KERNEL)

$(INITRAMFS):
	cd $(INIT_SRC_D) && find . | cpio -H newc -o | gzip > $@

$(ARCH_D)/linux-$(vers).tar.gz:
	cd $(ARCH_D) && wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.7.6.tar.gz

$(LINUX_SRC_D)/Makefile: $(ARCH_D)/linux-$(vers).tar.gz
	tar -xzvf $< -C $(SRC_D)
	touch $@

$(KERNEL): $(LINUX_SRC_D)/vmlinux $(LINUX_SRC_D)/Makefile
	mkdir -p $(OUT_D)/tmp/boot
	make -C $(LINUX_SRC_D) ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- install INSTALL_PATH=$(OUT_D)/tmp/boot
	make -C $(LINUX_SRC_D) ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- modules_install INSTALL_MOD_PATH=$(OUT_D)/tmp/
	make -C $(LINUX_SRC_D) ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- headers_install INSTALL_HDR_PATH=$(OUT_D)/tmp/usr
	tar  -C $(OUT_D)/tmp -czvf $@ .
	rm -rf $(OUT_D)/tmp

$(LINUX_SRC_D)/vmlinux: $(LINUX_SRC_D)/.config
	echo 'Patching'
	cd $(LINUX_SRC_D) && \
	for i in $(PATCH_SRC_D)/*; do \
		patch -p1 < $$i;\
	done
	make -C $(LINUX_SRC_D) ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- -j4

$(LINUX_SRC_D)/.config: $(CONFIG_D)/config_$(vers) $(LINUX_SRC_D)/Makefile
	cp $< $@

clean:
	make -C $(LINUX_SRC_D) ARCH=powerpc CROSS_COMPILE=powerpc64-linux-gnu- clean

mrproper: clean
	rm -rf $(OUT_D)/*

