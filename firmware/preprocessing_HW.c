#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//#include <string.h>
#include <stdbool.h>
#include <generated/csr.h>

#include "preprocessing_HW.h"

void enable_HW_bypass(void){
    preprocessor_prep_filter_reg_write(0);
}

void enable_HW_grayscale(void){
    preprocessor_prep_filter_reg_write(1);
}
