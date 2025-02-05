CC = nvcc
arch = sm_86

# add4device
add4device.out: src/add4device.cu
	$(CC) -arch=$(arch) src/add4device.cu -o build/add4device.out
	chmod +x build/add4device.out
	./build/add4device.out

# clean executable files
clean:
	@echo "Removing object files ..."
	rm build/*.out