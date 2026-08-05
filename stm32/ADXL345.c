/*
 * ADXL345.c
 *
 * Created on: Jul 9, 2026
 * Author: Jasmitha Nakka
 *
 * Minimal ADXL345 I2C driver implementation used by stm32/main.c.
 * This file contains only the basic initialization, register read/write,
 * and acceleration conversion functions needed for demo firmware.
 */

#include "ADXL345.h"

uint8_t ADXL345_Init(I2C_HandleTypeDef *hi2c) {
    uint8_t device_id = 0;
    HAL_StatusTypeDef status;

    // 1. Read the DEVID register (0x00) to verify the sensor is present.
    status = HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, REG_DEVID, I2C_MEMADD_SIZE_8BIT,
                               &device_id, 1, 100);
    if (status != HAL_OK) {
        return 0; // Failure: I2C communication failed.
    }

    if (device_id != 0xE5) {
        return 0; // Failure: Unexpected device ID.
    }

    // 2. Configure DATA_FORMAT (0x31) for +/- 2g range, full resolution.
    if (ADXL345_writeReg(hi2c, REG_DATA_FORMAT, 0x08) != HAL_OK) {
        return 0; // Failure: Write operation failed.
    }

    // 3. Configure POWER_CTL (0x2D) to Measurement Mode.
    if (ADXL345_writeReg(hi2c, REG_POWER_CTL, 0x08) != HAL_OK) {
        return 0; // Failure: Could not wake up sensor.
    }

    return 1; // Success
}

uint8_t ADXL345_writeReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t data_byte) {
    HAL_StatusTypeDef status;

    // Write one byte to an ADXL345 register.
    status = HAL_I2C_Mem_Write(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT,
                               &data_byte, 1, 100);

    return (uint8_t)status;
}

uint8_t ADXL345_readReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr) {
    uint8_t data_holder = 0;
    HAL_StatusTypeDef status;

    status = HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT,
                              &data_holder, 1, 100);

    if (status != HAL_OK) {
        return 1; // Return a safe fallback when the read fails.
    }

    return data_holder;
}

uint8_t ADXL345_ReadRegisters(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t *buffer, uint8_t length) {
    // Burst read multiple registers starting at reg_addr.
    return (uint8_t)HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT,
                                     buffer, length, 100);
}

void ADXL345_Read_Accel(I2C_HandleTypeDef *hi2c, int16_t *x, int16_t *y, int16_t *z) {
    uint8_t buffer[6];
    uint8_t status;

    // Read the six acceleration bytes in one burst.
    status = ADXL345_ReadRegisters(hi2c, REG_DATAX0, buffer, 6);

    if (status == HAL_OK) {
        // Combine low and high bytes for each axis.
        *x = (int16_t)((buffer[1] << 8) | buffer[0]);
        *y = (int16_t)((buffer[3] << 8) | buffer[2]);
        *z = (int16_t)((buffer[5] << 8) | buffer[4]);
    } else {
        // Clear outputs on failure.
        *x = 0;
        *y = 0;
        *z = 0;
    }
}
