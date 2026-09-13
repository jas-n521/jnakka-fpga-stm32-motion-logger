/*
 * ADXL345.h
 *
 *  Created on: Jul 9, 2026
 *      Author: Jasmitha Nakka
 */

// I2C handle: &hi2c1

// This gives our driver access to HAL functions like HAL_I2C_Master_Transmit
#include "stm32f4xx_hal.h"

// Device I2C Address (Shifted 1 bit left for STM32 HAL)
#define ADXL345_DEVICE_ADDR     (0x53 << 1)

// Register Map Definitions from DataSheet

#define REG_DEVID               0x00
#define REG_POWER_CTL           0x2D
#define REG_DATA_FORMAT         0x31
#define REG_DATAX0              0x32
#define REG_DATAX1              0x33
#define REG_DATAY0              0x34
#define REG_DATAY1              0x35
#define REG_DATAZ0              0x36
#define REG_DATAZ1              0x37

// Function Prototypes
// write to reg, read from reg, initializer (setup), read acceleration!!!


//initializer: It reads the DEVID to make sure it's plugged in, tells the sensor to start measuring,
//and sets how sensitive it should be.
//Prototype Design: It needs the I2C handle, and it should return a uint8_t (like a 1 for "Success" or
//0 for "Failed") so your main program knows it's safe to proceed.

uint8_t ADXL345_Init(I2C_HandleTypeDef *hi2c);

// Write to reg: start condition, device address, ADXL345 address, data byte variable, stop condition
// We can simplify the process.
// uint8_t return value to show us if function worked.
// We'll input these values to the I2C Transmit function

uint8_t ADXL345_writeReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t data_byte);

// Read reg: start condition, device address, ADXL345 address, data byte variable. restart,
// device address, data byte holder, stop condition
// Usage in main: my_id = ADXL345_readReg(&hi2c1, REG_DEVID);
// the data holder will be local in the function itself. We pass that data holder as a return value
// to the actual holder, in this case: my_id
uint8_t ADXL345_readReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr);

// Read Registers:
// Acceleration data is held in 6 diff registers. BURST read needed (read multiple simultaneously)
// Read x32 and next 5 reg's.
// Needs a 6 byte array to hold 6 reg's bytes.
// Pointer goes from x32 to x33 automatically until NACK packet is sent.
// We make it so that NACK packet is sent after we read the specified number of registers.

uint8_t ADXL345_ReadRegisters(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t *buffer, uint8_t length);

// Read Acceleration:
// This actually gives the acceleration values.
// This function creates a 6 byte array locally and calls the ReadRegisters function.
// Sorts ^ that data into x y and z acceleration value holders.

void ADXL345_Read_Accel(I2C_HandleTypeDef *hi2c, int16_t *x, int16_t *y, int16_t *z);












