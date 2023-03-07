#ifndef __ILI9341_H__
#define __ILI9341_H__

#include <stdint.h>

#define ILI9341_TFTWIDTH 320  ///< ILI9341 max TFT width
#define ILI9341_TFTHEIGHT 240 ///< ILI9341 max TFT height

// COMMAND DEFINITION
// ---------------------------------------------------------------
#define ILI9341_NOP           0x00  // No Operation
#define ILI9341_SWRESET       0x01  // Software Reset
#define ILI9341_RDDIDIF       0x04  // Read Display Identification Information
#define ILI9341_RDDST         0x09  // Read Display Status
#define ILI9341_RDMODE        0x0A  // Read Display Power Mode
#define ILI9341_RDDMADCTL     0x0B  // Read Display MADCTL
#define ILI9341_RDPIXFMT      0x0C  // Read Display Pixel Format
#define ILI9341_RDIMGFMT      0x0D  // Read Display Image Format
#define ILI9341_RDDSM         0x0E  // Read Display Signal Mode
#define ILI9341_RDSELFDIAG    0x0F  // Read Display Self Diagnostics Result
// ---------------------------------------------------------------
#define ILI9341_SLPIN         0x10  // Enter Sleep Mode
#define ILI9341_SLPOUT        0x11  // Sleep Out
#define ILI9341_PTLON         0x12  // Partial Mode On
#define ILI9341_NORON         0x13  // Normal Display On
// ---------------------------------------------------------------
#define ILI9341_DINVOFF       0x20  // Dislpay Inversion Off
#define ILI9341_DINVON        0x21  // Dislpay Inversion On
#define ILI9341_GAMMASET      0x26  // Gamma Set  
#define ILI9341_DISPOFF       0x28  // Display OFF
#define ILI9341_DISPON        0x29  // Display ON
#define ILI9341_CASET         0x2A  // Column Address Set
#define ILI9341_PASET         0x2B  // Page Address Set
#define ILI9341_RAMWR         0x2C  // Memory Write
#define ILI9341_RGBSET        0x2D  // Color Set
#define ILI9341_RAMRD         0x2E  // Memory Read
// ---------------------------------------------------------------
#define ILI9341_PLTAR         0x30  // Partial Area
#define ILI9341_VSCRDEF       0x33  // Vertical Scroll Definitio
#define ILI9341_TEOFF         0x34  // Tearing Effect Line OFF
#define ILI9341_TEON          0x35  // Tearing Effect Line ON
#define ILI9341_MADCTL        0x36  // Memory Access Control
#define ILI9341_VSCRADD       0x37  // Vertical Scrolling Start Address
#define ILI9341_IDMOFF        0x38  // Idle Mode OFF
#define ILI9341_IDMON         0x39  // Idle Mode ON
#define ILI9341_COLMODPIXFMT  0x3A  // Pixel Format Set
#define ILI9341_WMCON         0x3C  // Write Memory Continue
#define ILI9341_RMCON         0x3E  // Read Memory Continue
// ---------------------------------------------------------------
//#define ILI9341_IFMODE        0xB0  // RGB Interface Signal Control
#define ILI9341_FRMCRN1       0xB1  // Frame Control (In Normal Mode)
#define ILI9341_FRMCRN2       0xB2  // Frame Control (In Idle Mode)
#define ILI9341_FRMCRN3       0xB3  // Frame Control (In Partial Mode)
#define ILI9341_INVTR         0xB4  // Display Inversion Control
#define ILI9341_PRCTR         0xB5  // Blanking Porch Control
#define ILI9341_DISCTRL       0xB6  // Display Function Control
#define ILI9341_ETMOD         0xB7  // Entry Mode Set
#define ILI9341_BKCR1         0xB8  // Backlight Control 1
#define ILI9341_BKCR2         0xB9  // Backlight Control 2
#define ILI9341_BKCR3         0xBA  // Backlight Control 3
#define ILI9341_BKCR4         0xBB  // Backlight Control 4
#define ILI9341_BKCR5         0xBC  // Backlight Control 5
#define ILI9341_BKCR7         0xBE  // Backlight Control 7
#define ILI9341_BKCR8         0xBF  // Backlight Control 8
// ---------------------------------------------------------------
#define ILI9341_PWCTR1        0xC0 ///< Power Control 1
#define ILI9341_PWCTR2        0xC1 ///< Power Control 2
#define ILI9341_PWCTR3        0xC2 ///< Power Control 3
#define ILI9341_PWCTR4        0xC3 ///< Power Control 4
#define ILI9341_PWCTR5        0xC4 ///< Power Control 5
#define ILI9341_VMCTR1        0xC5 ///< VCOM Control 1
#define ILI9341_VMCTR2        0xC7 ///< VCOM Control 2
// ---------------------------------------------------------------
#define ILI9341_RDID1         0xDA ///< Read ID 1
#define ILI9341_RDID2         0xDB ///< Read ID 2
#define ILI9341_RDID3         0xDC ///< Read ID 3
#define ILI9341_RDID4         0xDD ///< Read ID 4
// ---------------------------------------------------------------
#define ILI9341_GMCTRP1       0xE0  // Positive Gamma Correction
#define ILI9341_GMCTRN1       0xE1  // Neagtove Gamma Correction
// Extend register commands
// ---------------------------------------------------------------
#define ILI9341_LCD_POWERA    0xCB   // Power control A register
#define ILI9341_LCD_POWERB    0xCF   // Power control B register
#define ILI9341_LCD_DTCA      0xE8   // Driver timing control A
#define ILI9341_LCD_DTCB      0xEA   // Driver timing control B
#define ILI9341_LCD_POWER_SEQ 0xED   // Power on sequence register
#define ILI9341_LCD_3GAMMA_EN 0xF2   // 3 Gamma enable register
#define ILI9341_LCD_PRC       0xF7   // Pump ratio control register
//Color definitions
// ---------------------------------------------------------------
#define ILI9341_BLACK 0x0000       ///<   0,   0,   0
#define ILI9341_NAVY 0x000F        ///<   0,   0, 123
#define ILI9341_DARKGREEN 0x03E0   ///<   0, 125,   0
#define ILI9341_DARKCYAN 0x03EF    ///<   0, 125, 123
#define ILI9341_MAROON 0x7800      ///< 123,   0,   0
#define ILI9341_PURPLE 0x780F      ///< 123,   0, 123
#define ILI9341_OLIVE 0x7BE0       ///< 123, 125,   0
#define ILI9341_LIGHTGREY 0xC618   ///< 198, 195, 198
#define ILI9341_DARKGREY 0x7BEF    ///< 123, 125, 123
#define ILI9341_BLUE 0x001F        ///<   0,   0, 255
#define ILI9341_GREEN 0x07E0       ///<   0, 255,   0
#define ILI9341_CYAN 0x07FF        ///<   0, 255, 255
#define ILI9341_RED 0xF800         ///< 255,   0,   0
#define ILI9341_MAGENTA 0xF81F     ///< 255,   0, 255
#define ILI9341_YELLOW 0xFFE0      ///< 255, 255,   0
#define ILI9341_WHITE 0xFFFF       ///< 255, 255, 255
#define ILI9341_ORANGE 0xFD20      ///< 255, 165,   0
#define ILI9341_GREENYELLOW 0xAFE5 ///< 173, 255,  41
#define ILI9341_PINK 0xFC18        ///< 255, 130, 198

typedef uint16_t (*read_px_type)(uint32_t);

typedef void (*read_px_init_type)(void);

void ili9341_init(void);

void ili9341_setAddress(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2);

void ili9341_setRotation(uint8_t m);

void ili9341_pushColor(uint16_t color);

void ili9341_clear(uint16_t color);

void ili9341_fillRect(uint16_t xPos,uint16_t yPos,uint16_t w,uint16_t h,uint16_t color);

void ili9341_writeFrame(read_px_type reader, read_px_init_type reader_init);

#endif