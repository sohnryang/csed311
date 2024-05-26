`define CACHE_SET_COUNT         4;
`define CACHE_WAY_COUNT         4;

`define ADDR_EXTRACT_CACHE_TAG  31: 6;
`define ADDR_EXTRACT_CACHE_IDX   5: 4;
`define ADDR_EXTRACT_CACHE_BO    3: 2;
`define ADDR_EXTRACT_CACHE_ALN   1: 0;

`define SIZE_CACHE_TAG          (31 - 6 + 1);
`define SIZE_CACHE_IDX          ( 5 - 4 + 1);
`define SIZE_CACHE_BO           ( 3 - 2 + 1);
`define SIZE_CACHE_ALN          ( 1 - 0 + 1);

`define SIZE_CACHE_BLK          (16 * 8);       // 16 Byte block

`define STATUS_CACHE_WAIT       2'b00       // Waiting input validate
`define STATUS_CACHE_CHECK      2'b01       // Cheking cache whether entry is hit or miss
`define STATUS_CACHE_FETCH      2'b10       // Fetch values from memory -> cache
`define STATUS_CACHE_APPLY      2'b11       // Writing values back from cache -> memory