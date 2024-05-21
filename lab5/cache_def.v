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

`define CACHE_STATUS_READY              3'd0
`define CACHE_STATUS_READ               3'd1
`define CACHE_STATUS_WRITE              3'd2
`define CACHE_STATUS_READING_MEMORY     3'd3
`define CACHE_STATUS_WRITING_MEMORY     3'd4