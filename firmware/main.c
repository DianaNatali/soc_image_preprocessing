#include "spi.h"
#include "timer.h"
#include "ili9341.h"
#include "read_buffer.h"
#include "cam_config.h"
#include "defaults.h"

#include <stdio.h>
#include <stdlib.h>
#include <irq.h>
#include <uart.h>
#include <i2c.h>
#include <console.h>
#include <generated/csr.h>

int32_t sw_time[10];
int j = 0;

int main(void){
   irq_setmask(1 << UART_INTERRUPT);
	irq_setie(1);
   uart_init();
   set_spi_prescaler(100);
   wait_ms(10);
   spi_init();
   ili9341_init();
   ili9341_setRotation(1);
   ili9341_clear(ILI9341_BLACK);
   set_spi_prescaler(6);
   wait_ms(10);
   cam_init_reg();

   while(1){
      rq_read();
      // printf("Counter: %d\n", sobel_core_counter_sobel_reg_read());
      //printf("Frame init\n");
      ili9341_writeFrame(&read_px, &read_px_init);
      //printf("Frame end\n");
      end_reading();
      
   }
   return 0;
}