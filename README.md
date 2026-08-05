# jnakka-fpga-stm32-motion-logger

### FPGA-Based Collision Detection & Event Logging System:

### Overview

This project is a hardware/software co-design platform for real-time collision
detection and event logging, built on an Artix-7 FPGA and STM32 microcontroller.

The FPGA performs configurable threshold-based collision detection in hardware,
logs collision events in a FIFO, and immediately notifies the STM32 through an
interrupt-driven interface using EXTI callbacks. The STM32 retrieves queued
events over a custom UART packet protocol and presents them to the user
through a serial terminal.

This project demonstrates FPGA RTL design, embedded firmware development,
digital communication protocols, interrupt-driven embedded systems, and
hardware/software co-design.

## Architecture

- **FPGA (Artix-7, SystemVerilog RTL)**
  - Configurable threshold-based collision/event detection logic
  - Parameterized FIFO buffers for event logging
  - Interrupt generation
  - Custom UART TX/RX FSMs for FPGA↔MCU communication

- **FPGA–MCU Interface**
  - Custom UART packet protocol and command parser for bidirectional
    communication and runtime reconfiguration (no re-synthesis required)
  - Interrupt-driven FPGA-to-MCU interface using EXTI callbacks to minimize
    event-retrieval latency

- **STM32 (C)**
  - Retrieves queued events over UART
  - Presents events to the user through a serial terminal

## System Architecture

```
┌──────────────────────┐
│ ADXL345 Accelerometer│
│ Measures X/Y/Z       │
│ acceleration         │
└──────────┬───────────┘
           │ I²C
           ▼
┌──────────────────────────────┐
│ STM32 Nucleo                 │
│                              │
│ • Custom ADXL345 driver      │
│ • Reads acceleration data    │
│ • Computes/selects magnitude │
│ • Builds UART packets        │
│ • Handles FPGA interrupt     │
│ • Prints events to terminal  │
└──────────┬───────────────────┘
           │ UART: commands and sensor values
           ▼
┌─────────────────────────────────────┐
│ Artix-7 FPGA                        │
│                                     │
│ UART RX → Packet Parser             │
│              ↓                      │
│        Command Decoder              │
│        ├─ Threshold config register │
│        ├─ Arm-mode config register  │
│        ├─ Sensor-value register     │
│        └─ FIFO read control         │
│              ↓                      │
│ Event Detector → Pulse Generator    │
│              ↓                      │
│         Event FIFO                  │
│              ↓                      │
│       Interrupt output              │
└──────────┬──────────────────────────┘
           │ EXTI interrupt
           ▼
        STM32
           │
           │ USB serial
           ▼
┌──────────────────────────────┐
│ PC Serial Terminal           │
│                              │
│ System armed                 │
│ Threshold: 80                │
│ Collision detected           │
│ Magnitude: 126               │
└──────────────────────────────┘
```

*This diagram shows the target end-to-end architecture. See [Status](#status) below for what's currently implemented.*

## Status

| Component | Status |
|---|---|
| SystemVerilog RTL (FSMs, FIFO, interrupt generation) | ✅ Done |
| UART packet protocol + command parser | ✅ Done |
| Interrupt-driven FPGA→MCU interface (EXTI) | ✅ Done |
| ADXL345 I²C driver | ✅ Done |
| Custom PCB for ADXL345 | 🚧 In progress |
| Full sensor-to-pipeline integration | 🚧 In progress |
| Serial monitor / host-side display | 🚧 In progress |

## Repository Structure

- `rtl/` → SystemVerilog source (FSMs, FIFO, interrupt logic, etc.)
- `tb/` → testbenches
- `stm32/` → STM32 firmware (C)
  - Contains only application code
  - Does not include STM32 HAL/CMSIS or BSP
  - HAL/CMSIS is assumed from STM32Cube / external dependency
- `docs/` → diagrams, protocol notes
- `README.md`