# SecureBootDemo setup -- paste this whole block into the VM's Terminal.
# It installs the demo tools and builds an UNSIGNED test kernel module.

sudo apt-get update && sudo apt-get install -y mokutil tpm2-tools build-essential "linux-headers-$(uname -r)"

mkdir -p ~/demo && cd ~/demo

cat > hello.c <<'EOF'
// Tiny kernel module used to show Secure Boot blocking unsigned code.
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Unsigned test module for the Secure Boot demo");

static int __init hello_init(void)
{
    pr_info("hello: UNSIGNED module loaded into the kernel\n");
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("hello: unloaded\n");
}

module_init(hello_init);
module_exit(hello_exit);
EOF

echo 'obj-m := hello.o' > Kbuild
make -C "/lib/modules/$(uname -r)/build" M="$PWD" modules

echo
echo "Setup done. hello.ko built (unsigned):"
ls -l ~/demo/hello.ko
