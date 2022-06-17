ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./linker.ld
MAP_FILE = build/miniOS_arm.map

SRC_DIR = src

ASM_SRCS = $(wildcard $(SRC_DIR)/boot/*.S)
ASM_OBJS = $(patsubst %.S, build/%.os, $(ASM_SRCS))

VPATH = $(SRC_DIR)/boot 			\
        $(SRC_DIR)/lib				\
        $(SRC_DIR)/kernel

C_SRCS  = $(wildcard $(SRC_DIR)/boot/*.c)
C_SRCS += $(wildcard $(SRC_DIR)/hal/*.c)
C_SRCS += $(wildcard $(SRC_DIR)/lib/*.c)
C_SRCS += $(wildcard $(SRC_DIR)/kernel/*.c)
C_OBJS = $(patsubst %.c, build/%.o, $(C_SRCS))

INC_DIRS  = -I $(SRC_DIR)/include 			\
            -I $(SRC_DIR)/hal	   			\
            -I $(SRC_DIR)/lib				\
            -I $(SRC_DIR)/kernel

CFLAGS = -c -g -std=c11 -mthumb-interwork

LDFLAGS = -nostartfiles -nostdlib -nodefaultlibs -static -lgcc

miniOS_arm = build/miniOS_arm.axf
miniOS_arm_bin = build/miniOS_arm.bin

.PHONY: all clean run debug gdb

all: $(miniOS_arm)

clean:
	@rm -fr build
	
run: $(miniOS_arm)
	qemu-system-arm -M realview-pb-a8 -kernel $(miniOS_arm) -nographic
	
debug: $(miniOS_arm)
	qemu-system-arm -M realview-pb-a8 -kernel $(miniOS_arm) -nographic -S -s
	
gdb:
	arm-none-eabi-gdb

kill:
	kill -9 `ps aux | grep 'qemu' | awk 'NR==1{print $$2}'`
	
$(miniOS_arm): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(miniOS_arm) $(ASM_OBJS) $(C_OBJS) -Wl,-Map=$(MAP_FILE) $(LDFLAGS)
	$(OC) -O binary $(miniOS_arm) $(miniOS_arm_bin)
	
build/%.os: %.S
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<
	
build/%.o: %.c
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -marm $(INC_DIRS) $(CFLAGS) -o $@ $<
	
test:
	#$(ASM_OBJS)