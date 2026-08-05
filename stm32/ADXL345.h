/*
 * ADXL345.h
 *
 *  Created on: Jul 9, 2026
 *      Author: Jasmitha Nakka
 *
 * Simple ADXL345 I2C driver definitions for demo firmware.
 * Only a minimal subset of functions is provided here for read/write and
 * acceleration conversion. 
 */

#include "stm32f4xx_hal.h"

// ADXL345 I2C address on the bus. STM32 HAL expects the 8-bit form.
#define ADXL345_DEVICE_ADDR     (0x53 << 1)

// Register map definitions from the ADXL345 datasheet.
#define REG_DEVID               0x00
#define REG_POWER_CTL           0x2D
#define REG_DATA_FORMAT         0x31
#define REG_DATAX0              0x32
#define REG_DATAX1              0x33
#define REG_DATAY0              0x34
#define REG_DATAY1              0x35
#define REG_DATAZ0              0x36
#define REG_DATAZ1              0x37

// Function prototypes for the ADXL345 driver.
// The functions use the HAL I2C handle from main.c.

// Initialize the sensor. Returns 1 on success, 0 on failure.
uint8_t ADXL345_Init(I2C_HandleTypeDef *hi2c);

// Write a single register on the ADXL345.
uint8_t ADXL345_writeReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t data_byte);

// Read a single register from the ADXL345.
uint8_t ADXL345_readReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr);

// Read multiple consecutive registers in a burst transfer.
uint8_t ADXL345_ReadRegisters(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t *buffer, uint8_t length);

// Read the X/Y/Z acceleration values and return them as signed 16-bit values.
void ADXL345_Read_Accel(I2C_HandleTypeDef *hi2c, int16_t *x, int16_t *y, int16_t *z);












