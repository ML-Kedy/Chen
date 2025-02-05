CC = nvcc
arch = sm_86

# add4device
add4device.out: src/add4device.cu
	$(CC) -arch=$(arch) src/add4device.cu -o build/add4device.out
	chmod +x build/add4device.out
	./build/add4device.out

# add2wrong
add2wrong.out: src/add2wrong.cu
	$(CC) -arch=$(arch) src/add2wrong.cu -o build/add2wrong.out
	chmod +x build/add2wrong.out
	./build/add2wrong.out

# add3if
# compute-sanitizer --tool memcheck build/add3if.out
## remove if will memcheck error, -lineinfo is show error line
add3if.out: src/add3if.cu
	$(CC) -arch=$(arch) -lineinfo src/add3if.cu -o build/add3if.out
	chmod +x build/add3if.out
	./build/add3if.out


# check2kernel
check2kernel.out: src/check2kernel.cu
	$(CC) -arch=$(arch) src/check2kernel.cu -o build/check2kernel.out
	chmod +x build/check2kernel.out
	./build/check2kernel.out	


# add1cpu, add event time, -O3 is optimization
add1cpu.out: src/add1cpu.cu
	$(CC) -arch=$(arch) -O3 src/add1cpu.cu -o build/add1cpu.out
	chmod +x build/add1cpu.out
	./build/add1cpu.out	

	$(CC) -arch=$(arch) -O3 -DUSE_DP src/add1cpu.cu -o build/add1cpu.out
	chmod +x build/add1cpu.out
	./build/add1cpu.out

# add2gpu, add event time, -O3 is optimization
add2gpu.out: src/add2gpu.cu
	$(CC) -arch=$(arch) -O3 src/add2gpu.cu -o build/add2gpu.out
	chmod +x build/add2gpu.out
	./build/add2gpu.out	

	$(CC) -arch=$(arch) -O3 -DUSE_DP src/add2gpu.cu -o build/add2gpu.out
	chmod +x build/add2gpu.out
	./build/add2gpu.out	

# clean executable files
clean:
	@echo "Removing object files ..."
	rm build/*.out