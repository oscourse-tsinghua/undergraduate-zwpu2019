# rom_test

This project is about a test for ROM IP.

I build it for stepfpga max10 to test if the rom ip works when sof file is loaded to the board.

The led represents the addr of data of a word in rom.

The segment represents the Little endian byte  of a word in rom.

The result turns out that the addr bits in intel hex file is based on the word addr not byte addr
