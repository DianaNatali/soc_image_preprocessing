#ifndef __PREPROCESSING_SW_H__
#define __PREPROCESSING_SW_H__

// uint8_t variable;

// uint8_t get_variable(void);

// void set_variable(uint8_t x);

uint16_t px_data;
uint8_t px_red;
uint8_t px_green;
uint8_t px_blue;
double grayscale_float;
uint8_t grayscale_5;
uint16_t grayscale_15;
uint16_t threshold;
uint8_t invert;
uint8_t invert;
uint16_t invert_15;

void SW_bypass(void);
void SW_grayscale(void);
void SW_threshold(uint8_t THRESHOLD_VAL);
void SW_invert(void);

#endif