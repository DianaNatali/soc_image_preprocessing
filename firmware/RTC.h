#ifndef __RTC_H__
#define __RTC_H__

#include <stdint.h>

int32_t hw_time[10];
int32_t RTC_val_HW;
int32_t RTC_prep_val_HW;
int32_t RTC_val_SW;
int32_t RTC_prep_val_SW;

void milisec_actual_HW(void);
void milisec_prepro_HW(void);
int32_t get_milisec_prepro_HW(void);
void milisec_actual_SW(void);
void milisec_prepro_SW(void);
int32_t get_milisec_prepro_SW(void);


#endif