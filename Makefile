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

# clean executable files
clean:
	@echo "Removing object files ..."
	rm build/*.out