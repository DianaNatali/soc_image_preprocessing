#ifndef __SPI_H__
#define __SPI_H__

#include <stdint.h>

void spi_init(void);

void write_command(uint8_t data);

void write_data(uint8_t data);

void send_bytes(const uint8_t data[], uint8_t length);

void set_spi_prescaler(uint32_t prescaler);


#endif