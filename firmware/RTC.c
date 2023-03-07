#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <generated/csr.h>

#include "RTC.h"


void milisec_actual_HW(void){
    RTC_val_HW = RTC_milisec_reg_CSR_read();
}

void milisec_prepro_HW(void){
    RTC_prep_val_HW = RTC_milisec_reg_CSR_read()-RTC_val_HW;
}

int32_t get_milisec_prepro_HW(void){
    return RTC_prep_val_HW;
}


void milisec_actual_SW(void){
    RTC_val_SW = RTC_milisec_reg_CSR_read();
}

void milisec_prepro_SW(void){
    RTC_prep_val_SW = RTC_milisec_reg_CSR_read()-RTC_val_SW;
}

int32_t get_milisec_prepro_SW(void){
    return RTC_prep_val_SW;
}
