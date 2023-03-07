#include <generated/csr.h>
#include <stdint.h>

#include "spi.h"
#include "timer.h"


void spi_init(void){
    SPI_enableSPIRegister_write(0x01);
}

void set_spi_prescaler(uint32_t prescaler){
    SPI_prescaler_reg_write(prescaler);
}

void write_command(uint8_t data){
    while(SPI_dataClockRegisterCSR_read()==0x01){}

    SPI_enableCSRegister_write(0x01);                  //set cs low to send command
    SPI_enableDCRegister_write(0x01);                  //set dc low to send command
    SPI_outputDataRegister_write(data);

    while(SPI_dataClockRegisterCSR_read()==0x00){}

    SPI_enableCSRegister_write(0x00);                  //pull high cs
}

void write_data(uint8_t data){
    while(SPI_dataClockRegisterCSR_read()==0x01){}

    SPI_enableDCRegister_write(0x00);                  //st dc high for data
    SPI_enableCSRegister_write(0x01);                  //set cs low for operation
    SPI_outputDataRegister_write(data);

    while(SPI_dataClockRegisterCSR_read()==0x00){}

    SPI_enableCSRegister_write(0x00);                  //pull high cs
}

void send_bytes(const uint8_t data[], uint8_t length){
    for(uint8_t i=0; i<length; i++){
        while(SPI_dataClockRegisterCSR_read()==0x01){}
        
        SPI_outputDataRegister_write(data[i]);
        SPI_enableCSRegister_write(0x01);

        while(SPI_dataClockRegisterCSR_read()==0x00){}

        SPI_enableCSRegister_write(0x00);

    }
}
