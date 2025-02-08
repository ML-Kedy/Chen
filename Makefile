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


# arithmetic1cpu
arithmetic1cpu.out: src/arithmetic1cpu.cu
	$(CC) -arch=$(arch) -O3 src/arithmetic1cpu.cu -o build/arithmetic1cpu.out
	chmod +x build/arithmetic1cpu.out
	./build/arithmetic1cpu.out	

# arithmetic2gpu
arithmetic2gpu.out: src/arithmetic2gpu.cu
	$(CC) -arch=$(arch) -O3 src/arithmetic2gpu.cu -o build/arithmetic2gpu.out
	chmod +x build/arithmetic2gpu.out
	./build/arithmetic2gpu.out 10000

# static
static.out: src/static.cu
	$(CC) -arch=$(arch) -O3 src/static.cu -o build/static.out
	chmod +x build/static.out
	./build/static.out

# query
query.out: src/query.cu
	$(CC) -arch=$(arch) -O3 src/query.cu -o build/query.out
	chmod +x build/query.out
	./build/query.out

# matrix
matrix.out: src/matrix.cu
	$(CC) -arch=$(arch) -O3 src/matrix.cu -o build/matrix.out
	chmod +x build/matrix.out
	./build/matrix.out 10000

# reduce1cpu
reduce1cpu.out: src/reduce1cpu.cu
	$(CC) -arch=$(arch) -O3 src/reduce1cpu.cu -o build/reduce1cpu.out
	chmod +x build/reduce1cpu.out
	./build/reduce1cpu.out

# reduce2gpu
reduce2gpu.out: src/reduce2gpu.cu
	$(CC) -arch=$(arch) -O3 src/reduce2gpu.cu -o build/reduce2gpu.out
	chmod +x build/reduce2gpu.out
	./build/reduce2gpu.out

# reduce3gpu
reduce3gpu.out: src/reduce3gpu.cu
	$(CC) -arch=$(arch) -O3 src/reduce3gpu.cu -o build/reduce3gpu.out
	chmod +x build/reduce3gpu.out
	./build/reduce3gpu.out

# reduce4gpu
reduce4gpu.out: src/reduce4gpu.cu
	$(CC) -arch=$(arch) -O3 src/reduce4gpu.cu -o build/reduce4gpu.out
	chmod +x build/reduce4gpu.out
	./build/reduce4gpu.out

# neighbor1cpu
neighbor1cpu.out: src/neighbor1cpu.cu
	$(CC) -arch=$(arch) -O3 src/neighbor1cpu.cu -o build/neighbor1cpu.out
	chmod +x build/neighbor1cpu.out
	./build/neighbor1cpu.out

# neighbor2gpu
neighbor2gpu.out: src/neighbor2gpu.cu
	$(CC) -arch=$(arch) -O3 src/neighbor2gpu.cu -o build/neighbor2gpu.out
	chmod +x build/neighbor2gpu.out
	./build/neighbor2gpu.out

# reduce5gpu
reduce5gpu.out: src/reduce5gpu.cu
	$(CC) -arch=$(arch) -O3 src/reduce5gpu.cu -o build/reduce5gpu.out
	chmod +x build/reduce5gpu.out
	./build/reduce5gpu.out


# clean executable files
clean:
	@echo "Removing object files ..."
	rm build/*.out