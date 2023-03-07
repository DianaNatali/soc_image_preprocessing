#ifndef __PREPROCESSING_HW_H__
#define __PREPROCESSING_HW_H__


void enable_HW_preprocessing(bool value);
uint8_t get_enable_mode_state(void);
void enable_HW_bypass(void);
void enable_HW_grayscale(void);
void enable_HW_threshold(void);
void enable_HW_invert(void);

#endif