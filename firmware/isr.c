#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <generated/csr.h>
#include <generated/soc.h>
#include <irq.h>
#include <console.h>
#include <uart.h>

#include "RTC.h"
#include "preprocessing_HW.h"
#include "defaults.h"

int i = 0;

void isr(void);
extern void wait_ms(unsigned int time);

void isr(void){
	unsigned int irqs;

	irqs = irq_pending() & irq_getmask();

	if(irqs & (1 << UART_INTERRUPT)){
		uart_isr();
	}
}


