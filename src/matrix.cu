#include <stdio.h>
#include "error.cuh"

#ifdef USE_DP
    typedef double real;
#else
    typedef float real;
#endif

const int TILE_DIM = 32;
const int NUM_REPEATS = 10;

void timing(const real *d_A, real *d_B, const int N, const int task);
__global__ void copy(const real *d_A, real *d_B, const int N);
__global__ void transpose1(const real *d_A, real *d_B, const int N);
__global__ void transpose2(const real *d_A, real *d_B, const int N);
__global__ void transpose3(const real *d_A, real *d_B, const int N);
__global__ void transpose4(const real *d_A, real *d_B, const int N);
__global__ void transpose5(const real *d_A, real *d_B, const int N);
void print_matrix(const int N, const real *A);

int main(int argc, char **argv){
    if (argc != 2){
        printf("usage: %s N\n", argv[0]);
        exit(1);
    }

    const int N = atoi(argv[1]);
    const int N2 = N * N;
    const int M = sizeof(real) * N2;
    real *h_A = (real*)malloc(M);
    real *h_B = (real*)malloc(M);

    for (int n = 0; n < N2; ++n){
        h_A[n] = n;
    }

    real *d_A, *d_B;
    CHECK(cudaMalloc(&d_A, M));
    CHECK(cudaMalloc(&d_B, M));
    CHECK(cudaMemcpy(d_A, h_A, M, cudaMemcpyHostToDevice));

    printf("\ncopy:\n");
    timing(d_A, d_B, N, 0);
    printf("\ntranspose with coalesced read:\n");
    timing(d_A, d_B, N, 1);
    printf("\ntranspose with coalesced write:\n");
    timing(d_A, d_B, N, 2);
    printf("\ntranspose with coalesced write and __ldg read:\n");
    timing(d_A, d_B, N, 3);
    printf("\ntranspose with shared memory bank conflict:\n");
    timing(d_A, d_B, N, 4);
    printf("\ntranspose without shared memory bank conflict:\n");
    timing(d_A, d_B, N, 5);
    CHECK(cudaMemcpy(h_B, d_B, M, cudaMemcpyDeviceToHost));
    if (N <= 10){
        printf("A = \n");
        print_matrix(N, h_A);
        printf("B = \n");
        print_matrix(N, h_B);
    }

    free(h_A);
    free(h_B);
    CHECK(cudaFree(d_A));
    CHECK(cudaFree(d_B));
    return 0;
}

void timing(const real *d_A, real *d_B, const int N, const int task){
    const int grid_size_x = (N + TILE_DIM - 1) / TILE_DIM;
    const int grid_size_y = grid_size_x;
    const dim3 block_size(TILE_DIM, TILE_DIM);
    const dim3 grid_size(grid_size_x, grid_size_y);

    float t_sum = 0;
    float t2_sum = 0;
    for (int repeat = 0; repeat <= NUM_REPEATS; ++repeat){
        cudaEvent_t start, stop;
        CHECK(cudaEventCreate(&start));
        CHECK(cudaEventCreate(&stop));
        CHECK(cudaEventRecord(start));
        cudaEventQuery(start);

        switch (task){
            case 0:
                copy<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            case 1:
                transpose1<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            case 2:
                transpose2<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            case 3:
                transpose3<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            case 4:
                transpose4<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            case 5:
                transpose5<<<grid_size, block_size>>>(d_A, d_B, N);
                break;
            default:
                printf("Error: wrong task\n");
                exit(1);
                break;
        }

        CHECK(cudaEventRecord(stop));
        CHECK(cudaEventSynchronize(stop));
        float elapsed_time;
        CHECK(cudaEventElapsedTime(&elapsed_time, start, stop));
        printf("Time = %g ms.\n", elapsed_time);

        if (repeat > 0){
            t_sum += elapsed_time;
            t2_sum += elapsed_time * elapsed_time;
        }
        CHECK(cudaEventDestroy(start));
        CHECK(cudaEventDestroy(stop));
    }
    const float t_ave = t_sum / NUM_REPEATS;
    const float t_err = sqrt(t2_sum / NUM_REPEATS - t_ave * t_ave);
    printf("Time = %g +- %g ms.\n", t_ave, t_err);
}

__global__ void copy(const real *A, real *B, const int N){
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    const int index = ny * N + nx;
    if (nx < N && ny < N){
        B[index] = A[index];
    }
}

__global__ void transpose1(const real *A, real *B, const int N){
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    // no coalesced write and coalesced read
    if (nx < N && ny < N){
        B[nx * N + ny] = A[ny * N + nx];
    }
}

__global__ void transpose2(const real *A, real *B, const int N){
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    // coalesced write and no coalesced read
    if (nx < N && ny < N){
        B[ny * N + nx] = A[nx * N + ny];
    }
}

__global__ void transpose3(const real *A, real *B, const int N){
    const int nx = blockIdx.x * blockDim.x + threadIdx.x;
    const int ny = blockIdx.y * blockDim.y + threadIdx.y;
    // coalesced write and no coalesced read
    if (nx < N && ny < N){
        B[ny * N + nx] = __ldg(&A[nx * N + ny]);
    }
}

// with bank conflict
__global__ void transpose4(const real *A, real *B, const int N)
{
    __shared__ real S[TILE_DIM][TILE_DIM];
    int bx = blockIdx.x * TILE_DIM;
    int by = blockIdx.y * TILE_DIM;

    int nx1 = bx + threadIdx.x;
    int ny1 = by + threadIdx.y;
    if (nx1 < N && ny1 < N)
    {
        S[threadIdx.y][threadIdx.x] = A[ny1 * N + nx1];
    }
    __syncthreads();

    int nx2 = bx + threadIdx.x;
    int ny2 = by + threadIdx.y;
    if (nx2 < N && ny2 < N)
    {
        B[ny2 * N + nx2] = S[threadIdx.x][threadIdx.y];
    }
}

// without bank conflict
__global__ void transpose5(const real *A, real *B, const int N)
{
    __shared__ real S[TILE_DIM][TILE_DIM + 1];
    int bx = blockIdx.x * TILE_DIM;
    int by = blockIdx.y * TILE_DIM;

    int nx1 = bx + threadIdx.x;
    int ny1 = by + threadIdx.y;
    if (nx1 < N && ny1 < N)
    {
        S[threadIdx.y][threadIdx.x] = A[ny1 * N + nx1];
    }
    __syncthreads();

    int nx2 = bx + threadIdx.x;
    int ny2 = by + threadIdx.y;
    if (nx2 < N && ny2 < N)
    {
        B[ny2 * N + nx2] = S[threadIdx.x][threadIdx.y];
    }
}

void print_matrix(const int N, const real *A){
    for (int ny = 0; ny < N; ny++){
        for (int nx = 0; nx < N; nx++){
            printf("%g\t", A[ny * N + nx]);
        }
        printf("\n");
    }
}