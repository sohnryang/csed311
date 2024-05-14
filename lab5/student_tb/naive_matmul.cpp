const int M = 8;
const int N = 8;
const int K = 8;

int main(void) {
  int a[M][K];
  int b[K][N];
  int c[M][N];

  // Initialize
  int x = 0;
  #pragma unroll (M)
  for (int m = 0; m < M; ++m) {
    #pragma unroll (N)
    for (int n = 0; n < N; ++n) {
      a[m][n] = x++;
      b[m][n] = x++;
      c[m][n] = 0;
    }
  }

  // matrix op
  #pragma unroll (M)
  for (int m = 0; m < M; ++m) {
    #pragma unroll (N)
    for (int n = 0; n < N; ++n) {
      #pragma unroll (K)
      for (int k = 0; k < K; ++k) {
        c[m][n] += a[m][k] + b[k][n];
      }
    }
  }

  return 0;
}
