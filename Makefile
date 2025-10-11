CFILES = $(wildcard *.c)
SFILES = $(wildcard *.S)
OFILES = $(CFILES:.c=.o) $(SFILES:.S=.o)

LLVMPATH = /opt/homebrew/opt/llvm/bin
LLDPATH = /opt/homebrew/opt/lld/bin
CLANGFLAGS = -Wall -O2 -ffreestanding -nostdinc -nostdlib -mcpu=cortex-a72+nosimd

all: clean kernel8.img

%.o: %.S
	$(LLVMPATH)/clang --target=aarch64-elf $(CLANGFLAGS) -c $< -o $@

%.o: %.c
	$(LLVMPATH)/clang --target=aarch64-elf $(CLANGFLAGS) -c $< -o $@

kernel8.img: $(OFILES)
	$(LLDPATH)/ld.lld -m aarch64elf -nostdlib $(OFILES) -T link.ld -o kernel8.elf
	$(LLVMPATH)/llvm-objcopy -O binary kernel8.elf kernel8.img

clean:
	/bin/rm kernel8.elf *.o *.img > /dev/null 2> /dev/null || true
