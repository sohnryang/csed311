const int M = 8;
const int N = 8;
const int K = 8;
const int TILE = 4;

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
  for (int tile_m = 0; tile_m < M; tile_m += TILE) {
    #pragma unroll (N)
    for (int tile_n = 0; tile_n < N; tile_n += TILE) {
      #pragma unroll (K)
      for (int tile_k = 0; tile_k < K; tile_k += TILE) {
        #pragma unroll (TILE)
        for (int m = tile_m; m < tile_m + TILE; ++m) {
          #pragma unroll (TILE)
          for (int n = tile_n; n < tile_n + TILE; ++n) {
            #pragma unroll (TILE)
            for (int k = tile_k; k < tile_k + TILE; ++k) {
              c[m][n] += a[m][k] + b[k][n];
            }
          }
        }
      }
    }
  }

  return 0;
}

