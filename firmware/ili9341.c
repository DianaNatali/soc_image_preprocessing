#include "ili9341.h"
#include "spi.h"
#include "timer.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
//#include <string.h>

volatile uint16_t LCD_W=ILI9341_TFTWIDTH;
volatile uint16_t LCD_H=ILI9341_TFTHEIGHT;
volatile uint8_t textsize;

#define SPI_DEFAULT_FREQ 24000000 ///< Default SPI data clock frequency
#define MADCTL_MY 0x80  ///< Bottom to top
#define MADCTL_MX 0x40  ///< Right to left
#define MADCTL_MV 0x20  ///< Reverse Mode
#define MADCTL_ML 0x10  ///< LCD refresh Bottom to top
#define MADCTL_RGB 0x00 ///< Red-Green-Blue pixel order
#define MADCTL_BGR 0x08 ///< Blue-Green-Red pixel order
#define MADCTL_MH 0x04  ///< LCD refresh right to left


void ili9341_init(void){
    spi_init();
    write_command(ILI9341_SWRESET);             // 0x01 -> Soft reset
    wait_ms(100);
    // Power control A--------------------------------------------
    write_command(ILI9341_LCD_POWERA);
    write_data(0x39);
    write_data(0x2C);
    write_data(0x00);
    write_data(0x34);
    write_data(0x02);

    // Power control B--------------------------------------------
    write_command(ILI9341_LCD_POWERB);
    write_data(0x00);
    write_data(0xC1);
    write_data(0x30);

    // Driver timing control A------------------------------------
    write_command(ILI9341_LCD_DTCA);
    write_data(0x85);
    write_data(0x00);
    write_data(0x78);

    // Driver timing control B------------------------------------
    write_command(ILI9341_LCD_DTCB);
    write_data(0x00);
    write_data(0x00);

    // Power on sequence control----------------------------------
    write_command(ILI9341_LCD_POWER_SEQ);
    write_data(0x64);
    write_data(0x03);
    write_data(0x12);
    write_data(0x81);

    // Power on sequence control----------------------------------
    write_command(ILI9341_LCD_PRC);
    write_data(0x20);

    // Power Control 1 VRH[5:0]-----------------------------------
    write_command(ILI9341_PWCTR1);
    write_data(0x23);

    //Power Control 2 SAP[2:0];BT[3:0]----------------------------
    write_command(ILI9341_PWCTR2);
    write_data(0x10);

    // VCOM Control 1---------------------------------------------
    write_command(ILI9341_VMCTR1);
    write_data(0x3E);
    write_data(0x28);

    // VCOM Control 2--------------------------------------------
    write_command(ILI9341_VMCTR2);
    write_data(0x86);

    // Memory Access Control-------------------------------------
    write_command(ILI9341_MADCTL);
    write_data(0x48);

    // Pixel Format Set------------------------------------------
    write_command(ILI9341_COLMODPIXFMT); // TODO: Revisar RGB 555 
    write_data(0x55); // RGB 565

    // Frameration control,normal mode full colours--------------
    write_command(ILI9341_FRMCRN1);
    write_data(0x00);
    write_data(0x18);

    // Display Function Control----------------------------------
    write_command(ILI9341_DISCTRL);
    write_data(0x08);
    write_data(0x82);
    write_data(0x27);

    // 3gamma function disable-----------------------------------
    write_command(ILI9341_LCD_3GAMMA_EN);
    write_data(0x00);

    // Set positive gamma correction-----------------------------
    write_command(ILI9341_GMCTRP1);
    write_data(0x0F);
    write_data(0x31);
    write_data(0x2B);
    write_data(0x0C);
    write_data(0x0E);
    write_data(0x08);
    write_data(0x4E);
    write_data(0xF1);
    write_data(0x37);
    write_data(0x07);
    write_data(0x10);
    write_data(0x03);
    write_data(0x0E);
    write_data(0x09);
    write_data(0x00);

    // Set positive gamma correction-----------------------------
    write_command(ILI9341_GMCTRN1);
    write_data(0x00);
    write_data(0x0E);
    write_data(0x14);
    write_data(0x03);
    write_data(0x11);
    write_data(0x07);
    write_data(0x31);
    write_data(0xC1);
    write_data(0x48);
    write_data(0x08);
    write_data(0x0F);
    write_data(0x0C);
    write_data(0x31);
    write_data(0x36);
    write_data(0x0F);

    //exit sleep--------------------------------------------------
    write_command(ILI9341_SLPOUT);
    wait_ms(150);
    
    //display on--------------------------------------------------
    write_command(ILI9341_DISPON);
}

// Set coordinate for print or other function--------------------------------------------------
void ili9341_setAddress(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2){//set coordinate for print or other function
    write_command(ILI9341_CASET);
    write_data(x1>>8);
    write_data(x1);
    write_data(x2>>8);
    write_data(x2);

    write_command(ILI9341_PASET);
    write_data(y1>>8);
    write_data(y1);
    write_data(y2);
    write_data(y2);

    write_command(ILI9341_RAMWR);// Memory write
}

// Rotate screen at desired orientation--------------------------------------------------------
void ili9341_setRotation(uint8_t m){
    uint8_t rotation;
    rotation=m%4;
    write_command(ILI9341_MADCTL);
    switch (rotation){
    case 0:
        write_data(MADCTL_MX|MADCTL_BGR);
        LCD_W = ILI9341_TFTWIDTH;
        LCD_H = ILI9341_TFTHEIGHT;
        break;
    case 1:
        write_data(MADCTL_MV|MADCTL_BGR);
        LCD_W = ILI9341_TFTHEIGHT;
        LCD_H = ILI9341_TFTWIDTH;
        break;
    case 2:
        write_data(MADCTL_MY|MADCTL_BGR);
        LCD_W = ILI9341_TFTWIDTH;
        LCD_H = ILI9341_TFTHEIGHT;
        break;
    case 3:
        write_data(MADCTL_MX|MADCTL_MY|MADCTL_MV|MADCTL_BGR);
        LCD_W = ILI9341_TFTHEIGHT;
        LCD_H = ILI9341_TFTWIDTH;
        break;
    }
}

// Set colour for drawing----------------------------------------------------------------------
void ili9341_pushColor(uint16_t color){
    write_data(color>>8);
    write_data(color);
}

// Clear lcd and fill with colour--------------------------------------------------------------
void ili9341_clear(uint16_t color){
    uint16_t i,j;

    ili9341_setAddress(0, 0, LCD_H-1, LCD_W-1);
    for(i = 0; i < LCD_W; i++){
        for(j = 0; j < LCD_H; j++){
            ili9341_pushColor(color);
        }
    }
}   

// Draw colour filled rectangle
void ili9341_fillRect(uint16_t xPos,uint16_t yPos,uint16_t w,uint16_t h,uint16_t color){
    if((xPos >= LCD_W) || (yPos >= LCD_H)) return;
    if((xPos + w -1) >= LCD_W)
    w = LCD_W - xPos;
    if((yPos + h - 1) >= LCD_H)
    h = LCD_H - yPos;

    ili9341_setAddress(xPos, yPos, xPos + w -1, yPos + h-1);

    for(yPos = h; yPos >0; yPos--) {
        for(xPos = w; xPos > 0; xPos--){
            ili9341_pushColor(color);
        }
    }
}

void ili9341_writeFrame(read_px_type reader, read_px_init_type reader_init){
    uint16_t data;
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    ili9341_setAddress(0, 0, LCD_H -1, LCD_W -1);
    (*reader_init)();
    for(uint32_t address = 1; address <= 76800; address++) {
        data = (*reader)(address);
        ili9341_pushColor(data);
        blue = (data & (0x001F))<<3;
        green = ((data & (0x03E0))>>5)<<3;
        red = ((data & (0x7C00))>>10)<<3;
        //printf("%d,%d,%d\n", red, green, blue);
        //printf("Read Addr: %d", address);
        //printf("Data: %x\n", data);//printf("Write Addr: %d\n", address);
    }
}