/*
 * ADXL345.c
 *
 * Created on: Jul 9, 2026
 * Author: rames
 */

#include "ADXL345.h"

uint8_t ADXL345_Init(I2C_HandleTypeDef *hi2c) {
    uint8_t device_id = 0;
    HAL_StatusTypeDef status;

    // 1. Read the DEVID register (0x00) to make sure the sensor is actually there
    status = HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, 0x00, I2C_MEMADD_SIZE_8BIT, &device_id, 1, 100);
    if (status != HAL_OK) {
        return 0; // Failure: Physical I2C communication failed!
    }

    if (device_id != 0xE5) {
        return 0; // Failure: Sensor not found or wrong device ID!
    }

    // 2. Configure DATA_FORMAT (0x31) to +/- 2g range, Full Resolution
    if (ADXL345_writeReg(hi2c, 0x31, 0x08) != HAL_OK) {
        return 0; // Failure: Could not write configuration
    }

    // 3. Configure POWER_CTL (0x2D) to Measurement Mode (wakes it up)
    if (ADXL345_writeReg(hi2c, 0x2D, 0x08) != HAL_OK) {
        return 0; // Failure: Could not wake up sensor
    }

    return 1; // Success!
}

uint8_t ADXL345_writeReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t data_byte) {

	HAL_StatusTypeDef status;

	    // HAL_I2C_Mem_Write parameters:
	    // 1. I2C Handle pointer <-- this pointer uses * bc hi2c is a huge data
	    // 2. Device Address (0x53 shifted left)
	    // 3. Target Register Address on the ADXL345
	    // 4. Size of the register address (8-bit for ADXL345)
	    // 5. Pointer to the data byte we want to send <-- this pointer uses & bc its only one byte
	    // 6. Size of the data we are sending (1 byte)
	    // 7. Timeout in milliseconds
	    status = HAL_I2C_Mem_Write(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT, &data_byte, 1, 100);

	    // Return the status (HAL_OK is 0, errors are non-zero)
	    return (uint8_t)status;
}

//HAL_I2C_Mem_Read(I2C_HandleTypeDef *hi2c, uint16_t DevAddress, uint16_t MemAddress, uint16_t MemAddSize, uint8_t *pData, uint16_t Size, uint32_t Timeout);

uint8_t ADXL345_readReg(I2C_HandleTypeDef *hi2c, uint8_t reg_addr) {

	uint8_t data_holder = 0;
	HAL_StatusTypeDef status;

	status = HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT, &data_holder, 1, 100);

	if (status != HAL_OK) {
		return 1; // Safe fallback if bus read drops
	}

	return data_holder;

}

uint8_t ADXL345_ReadRegisters(I2C_HandleTypeDef *hi2c, uint8_t reg_addr, uint8_t *buffer, uint8_t length) {
	// Burst read

	return (uint8_t)HAL_I2C_Mem_Read(hi2c, ADXL345_DEVICE_ADDR, reg_addr, I2C_MEMADD_SIZE_8BIT, buffer, length, 100);
}

void ADXL345_Read_Accel(I2C_HandleTypeDef *hi2c, int16_t *x, int16_t *y, int16_t *z) {
	uint8_t buffer[6];
	uint8_t status;

	status = ADXL345_ReadRegisters(hi2c, REG_DATAX0, buffer, 6); // start reading from X data 0.

	// Only process if the burst read actually succeeded
	if (status == HAL_OK) {
		// x (no asterisk) refers to the pointer itself (the memory address).
		//*x (with asterisk) refers to actual variable in the location the pointer is pointing to back in main.c (the destination).
		// but in the function declaration the *x means that the input is a pointer type
		*x = (int16_t)(buffer[1] << 8);
		*x = *x | buffer[0];

		*y = (int16_t) (buffer[3] << 8);
		*y = *y | buffer[2];

		*z = (int16_t) (buffer[5] << 8);
		*z = *z | buffer[4];
	} else {
		// Clear outputs if data transmission failed completely
		*x = 0;
		*y = 0;
		*z = 0;
	}
}
