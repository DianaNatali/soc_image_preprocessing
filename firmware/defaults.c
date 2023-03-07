#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <generated/csr.h>

#include "defaults.h"

void set_switch_state_prep_filter(uint8_t val){
    switch_state_prep_filter = val;
}

uint8_t get_switch_state_prep_filter(void){
    return switch_state_prep_filter;
}
