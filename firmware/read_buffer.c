#include "read_buffer.h"
#include "timer.h"

#include <generated/csr.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
//#include <string.h>

void rq_read(void){
    sobel_buffer_rq_read_reg_write(0x01);
    //printf("Ack pre %d\n", sobel_buffer_ack_read_reg_read());
    while(sobel_buffer_ack_read_reg_read()==0);
    sobel_buffer_rq_read_reg_write(0x00);
    sobel_buffer_reading_reg_write(0x01);
    //printf("Ack pos %d\n", sobel_buffer_ack_read_reg_read());
}

void end_reading(void){
    sobel_buffer_reading_reg_write(0x00);
    while(sobel_buffer_ack_read_reg_read()==1);
}

uint16_t read_px(uint32_t address){
    uint16_t data;
    // wait_us(1);
    sobel_buffer_read_clk_reg_write(0x01);
    // wait_us(1);
    sobel_buffer_read_clk_reg_write(0x00);
    data = sobel_buffer_output_px_data_reg_read();
    sobel_buffer_read_addr_reg_write(address);
    //printf("Read Addr: %d\n", address);
    //printf("Data: %x\n", data);
    return data;
}

void read_px_init(void){
    // wait_us(1);
    sobel_buffer_read_clk_reg_write(0x01);
    // wait_us(1);
    sobel_buffer_read_clk_reg_write(0x00);
    sobel_buffer_read_addr_reg_write(0x00);
}