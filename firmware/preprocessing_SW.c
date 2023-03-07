#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//#include <string.h>
#include <stdbool.h>
#include <generated/csr.h>

#include "preprocessing_SW.h"


void SW_bypass(void){
    for(uint32_t address = 1; address <= 76800; address++) {
        preprocessor_prep_write_addr_SW_reg_write(address);
        preprocessor_prep_read_addr_SW_reg_write(address);
        preprocessor_prep_output_px_data_SW_reg_write(preprocessor_prep_input_px_data_SW_reg_CSR_read());
    }
}

void SW_grayscale(void){
    for(uint32_t address = 1; address <= 76800; address++) { 
        preprocessor_prep_write_addr_SW_reg_write(address);
        preprocessor_prep_read_addr_SW_reg_write(address);
        px_data = preprocessor_prep_input_px_data_SW_reg_CSR_read();
        px_blue = px_data & (0x001F);
        px_green = (px_data & (0x03E0))>>5;
        px_red = (px_data & (0x7C00))>>10;
        grayscale_float = ((double)px_red)*0.281+((double)px_green)*0.562+((double)px_blue)*0.093;
        grayscale_5 = ((uint8_t)grayscale_float) & 0x001F;
        grayscale_15 = (grayscale_5) + (grayscale_5<<5)+(grayscale_5<<10);
        preprocessor_prep_output_px_data_SW_reg_write(grayscale_15);
    }
}

void SW_threshold(uint8_t THRESHOLD_VAL){
    for(uint32_t address = 1; address <= 76800; address++) {
        preprocessor_prep_write_addr_SW_reg_write(address);
        preprocessor_prep_read_addr_SW_reg_write(address);
        px_data = preprocessor_prep_input_px_data_SW_reg_CSR_read();
        px_blue = px_data & (0x001F);
        px_green = (px_data & (0x03E0))>>5;
        px_red = (px_data & (0x7C00))>>10;
        grayscale_float = ((double)px_red)*0.281+((double)px_green)*0.562+((double)px_blue)*0.093;
        grayscale_5 = ((uint8_t)grayscale_float)<<3;
        threshold = (grayscale_5 < THRESHOLD_VAL)? 0 : 32767;
        preprocessor_prep_output_px_data_SW_reg_write(threshold);
    }
}

void SW_invert(void){
    for(uint32_t address = 1; address <= 76800; address++) {
        preprocessor_prep_write_addr_SW_reg_write(address);
        preprocessor_prep_read_addr_SW_reg_write(address);
        px_data = preprocessor_prep_input_px_data_SW_reg_CSR_read();
        px_blue = 255 - (px_data & (0x001F));
        px_green = 255 - ((px_data & (0x03E0))>>5);
        px_red = 255- ((px_data & (0x7C00))>>10);
        grayscale_float = ((double)px_red)+((double)px_green)+((double)px_blue);
        invert = ((uint8_t)grayscale_float) & 0x001F;
        invert_15 = (invert) + (invert<<5)+(invert<<10);
        preprocessor_prep_output_px_data_SW_reg_write(invert_15);
    }
}
