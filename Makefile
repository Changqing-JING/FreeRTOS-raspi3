CROSS ?= aarch64-linux-gnu
CFLAGS =  -mcpu=cortex-a53 -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I$(INCLUDEPATH1) -I$(INCLUDEPATH2) -I$(INCLUDEPATH3)
ASMFLAGS = -mcpu=cortex-a53

BUILDPATH = build
INCLUDEPATH1 ?= FreeRTOS/Source/include
INCLUDEPATH2 ?= FreeRTOS/Source/portable/GCC/ARM_CA53_64_RaspberryPi3
INCLUDEPATH3 ?= Demo

OBJS = build/startup.o 
OBJS +=build/FreeRTOS_asm_vector.o
OBJS +=build/FreeRTOS_tick_config.o
OBJS +=build/uart.o
OBJS +=build/main.o

OBJS +=build/port.o
OBJS +=build/portASM.o

OBJS +=build/list.o
OBJS +=build/tasks.o
OBJS +=build/queue.o
OBJS +=build/timers.o

OBJS +=build/heap_1.o

kernel8.elf : raspberrypi3.ld $(OBJS)
	$(CROSS)-gcc -Wl,--build-id=none -std=gnu11 -T raspberrypi3.ld -o build/$@ -ffreestanding -O2 -nostdlib $(OBJS)
	$(CROSS)-objdump -D build/kernel8.elf > build/kernel8.list

build/%.o : Demo/%.S $(BUILDPATH)
	$(CROSS)-as $(ASMFLAGS) -c -o $@ $<
	
build/%.o : Demo/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/portable/GCC/ARM_CA53_64_RaspberryPi3/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/portable/GCC/ARM_CA53_64_RaspberryPi3/%.S
	$(CROSS)-as $(ASMFLAGS) -c -o $@ $<

build/%.o : FreeRTOS/Source/portable/MemMang/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

$(BUILDPATH):
	@if [ ! -d $(BUILDPATH) ]; then \
	  echo " mkdir $(BUILDPATH)"; mkdir $(BUILDPATH); \
	fi

clean :
	rm -f build/*.o
	rm -f *.elf
	rm -f *.list

run: kernel8.elf
	qemu-system-aarch64 -M raspi3b -m 1024 -serial null -serial mon:stdio -nographic -kernel build/$<

runasm :
	qemu-system-aarch64 -M raspi3b -m 1024 -serial null -serial mon:stdio -nographic -kernel build/$< -d in_asm


