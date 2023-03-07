#ifndef __READBUFFER_H__
#define __READBUFFER_H__

#include <stdbool.h>
#include <stdint.h>

void rq_read(void);
void end_reading(void);
uint16_t read_px(uint32_t address);
void read_px_init(void);


#endif