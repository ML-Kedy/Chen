#include "error.cuh"
#include <math.h>
#include <stdio.h>

#ifdef USE_DP
    typedef double real;
    const real EPSILON = 1.0e-15;
#else
    typedef float real;
    const real EPSILON = 1.0e-6f;
#endif

const int NUM_REPEATS = 10;
const real a = 1.23;
const real b = 2.34;
const real c = 3.57;
void add(const real *x, const real *y, real *z, const int N);
void check(const real *z, const int N);

int main(void)
{
    const int N = 100000000;
    const int M = sizeof(real) * N;
    real *x = (real*) malloc(M);
    real *y = (real*) malloc(M);
    real *z = (real*) malloc(M);

    for (int n = 0; n < N; ++n)
    {
        x[n] = a;
        y[n] = b;
    }

    float t_sum = 0;
    float t2_sum = 0;
    for (int repeat = 0; repeat <= NUM_REPEATS; ++repeat)
    {
    
        cudaEvent_t start, stop;
        CHECK(cudaEventCreate(&start));
        CHECK(cudaEventCreate(&stop));
        CHECK(cudaEventRecord(start));
        /***
         * 此处不能用 CHECK 宏函数, 
         * 一个 CUDA 流 (CUDA stream)中的操作(如这里的 cudaEventRecord 函数)并不是直接提交给 GPU 执 行,
         * 而是先提交到一个软件队列,需要添加一条对该流的 cudaEventQuery 操作(或者 cudaEventSynchronize)刷新队列,
         * 才能促使前面的操作在 GPU 执行
         */
        cudaEventQuery(start); 

        add(x, y, z, N);

        CHECK(cudaEventRecord(stop));
        CHECK(cudaEventSynchronize(stop));
        float elapsed_time;
        CHECK(cudaEventElapsedTime(&elapsed_time, start, stop));
        printf("Time = %g ms.\n", elapsed_time);

        if (repeat > 0)
        {
            t_sum += elapsed_time;
            t2_sum += elapsed_time * elapsed_time;
        }

        CHECK(cudaEventDestroy(start));
        CHECK(cudaEventDestroy(stop));

    }

    const float t_ave = t_sum / NUM_REPEATS;
    const float t_err = sqrt(t2_sum / NUM_REPEATS - t_ave * t_ave);
    printf("Time = %g +- %g ms.\n", t_ave, t_err);

    check(z, N);

    free(x);
    free(y);
    free(z);
    return 0;
}

void add(const real *x, const real *y, real *z, const int N)
{
    for (int n = 0; n < N; ++n)
    {
        z[n] = x[n] + y[n];
    }
}

void check(const real *z, const int N)
{
    bool has_error = false;
    for (int n = 0; n < N; ++n)
    {
        if (fabs(z[n] - c) > EPSILON)
        {
            has_error = true;
        }
    }
    printf("%s\n", has_error ? "Has errors" : "No errors");
}

