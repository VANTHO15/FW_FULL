#define VTOR_REG  0xE000ED08
/* #define MASTER_ID 0x4001FC00 */ /* Đọc giá trị trong địa chỉ này để xem đang là core nào */
#define MAIN_CORE 0x0

    MODULE  ?cstartup

    ;; Forward declaration of sections.
    SECTION CSTACK:DATA:NOROOT(3)

    EXTERN  main
    EXTERN RAM_INIT
    EXTERN INT_SRAM_START
    EXTERN INT_SRAM_END
    EXTERN vectortable$$Base
    EXTERN initvectortable$$Base
    EXTERN initvectortable$$Limit
    EXTERN data$$Base
    EXTERN initdata$$Base
    EXTERN initdata$$Limit
    EXTERN data_nocache$$Base
    EXTERN initdata_nocache$$Base
    EXTERN initdata_nocache$$Limit
    EXTERN data_sharable$$Base
    EXTERN initdata_sharable$$Base
    EXTERN initdata_sharable$$Limit
    EXTERN bss$$Base
    EXTERN bss$$Limit
    EXTERN bss_nocache$$Base
    EXTERN bss_nocache$$Limit
    EXTERN bss_sharable$$Base
    EXTERN bss_sharable$$Limit
    EXTERN __CORE0_VTOR
    PUBLIC __INIT_TABLE
    PUBLIC __ZERO_TABLE
    PUBLIC _start

/* Copying data from rom to ram and erase bss */
    SECTION .init_table:CONST(4)
__INIT_TABLE
    DCD vectortable$$Base
    DCD initvectortable$$Base
    DCD initvectortable$$Limit
    DCD data$$Base
    DCD initdata$$Base
    DCD initdata$$Limit
    DCD data_nocache$$Base
    DCD initdata_nocache$$Base
    DCD initdata_nocache$$Limit
    DCD data_sharable$$Base
    DCD initdata_sharable$$Base
    DCD initdata_sharable$$Limit
__INIT_TABLE_END
    SECTION .zero_table:CONST(4)
__ZERO_TABLE
    DCD bss$$Base
    DCD bss$$Limit
    DCD bss_nocache$$Base
    DCD bss_nocache$$Limit
    DCD bss_sharable$$Base
    DCD bss_sharable$$Limit
__ZERO_TABLE_END

    THUMB
    PUBWEAK Reset_Handler
    SECTION .startup:CODE:REORDER:NOROOT(2)

_start:
Reset_Handler:

	/* Clear Register */
	BL ClearRegister  

	/* Reset core register */
	BL SetVtorRegister

	/* Set stack register */
	BL SetStack

	/* Clear Ram */
	BL RamInit

	/* Copy initialized data from Rom to Ram */
	BL InitData

	/* Clear Bss */
	BL ClearBss


/* Call Main Routine  */
_MAIN:
  CPSIE i  /* Vô hiệu hoá tất cả các ngắt  */
  BL main

    PUBLIC ThoNVEnd
ThoNVEnd:
    CMP R1,#1

/******************************************************************************
/* Function defination                                                       */
/*****************************************************************************/

/* Clear các Register */
ClearRegister:
    MOV     R0,#0
    MOV     R1,#0
    MOV     R2,#0
    MOV     R3,#0
    MOV     R4,#0
    MOV     R5,#0
    MOV     R6,#0
    MOV     R7,#0
    MOV     R8,#0
    MOV     R9,#0
    MOV     R10,#0
    MOV     R11,#0
    MOV     R12,#0
    MOV     PC, LR

/* Gán giá trị VTOR_REG vào memory __vectortable_start */
SetVtorRegister:
    LDR     R0, =VTOR_REG
    LDR     R1, =VTABLE
    STR     R1, [R0]
    MOV     PC, LR

/* set stack pointer Core0 cho MSP */
SetStack:
    LDR     r0, =Stack_start_c0
    MSR     MSP, r0
    MOV     PC, LR

/* Ram Init */
RamInit:
    LDR     R0, =RAM_INIT
    CMP     R0, #0
    /* Nếu __SRAM_INIT không bằng 0 thì bỏ qua */
    BEQ     SRAM_End
    LDR     R1, =INT_SRAM_START
    LDR     R2, =INT_SRAM_END
    SUBS    R2, R1
    SUBS    R2, #1 
    BLE     SRAM_End /* Nếu SUBS <= 0 thì nhảy */
    MOVS    R0, #0
    MOVS    R3, #0
SRAM_Loop:
    STM     R1!, {R0, R3} /* Lưu trữ nội dung của các thanh ghi vào một vị trí bộ nhớ đã chỉ định*/
    SUBS    R2, #8
    BGE     SRAM_Loop /* Nếu SUBS >= 0 thì nhảy */
SRAM_End:
    MOV     PC, LR

/* Init Data */
InitData:
    LDR     R0, =__INIT_TABLE
    LDR     R6, =__INIT_TABLE_END
    SUBS    R5, R6, R0 
    ADDS    R5, R5, #12
SetaddRegionData:
    SUBS    R5, R5, #12
    CMP     R5, #0
    BEQ     InitData_End /* nếu bằng */
    LDR     R1, [R0]
    LDR     R2, [R0, #4]
    LDR     R3, [R0, #8]
    ADDS    R0, R0, #12
    SUBS    R4, R3, R2
    CMP     R4, #0
    BEQ     SetaddRegionData /* nếu bằng */
CopyDataFlashtoRam:
    LDR     R4,[R2]
    STR     R4,[R1]
    ADDS    R1, R1, #1
    ADDS    R2, R2, #1
    CMP     R2, R3
    BEQ     SetaddRegionData /* nếu bằng */
    B       CopyDataFlashtoRam
InitData_End:
    MOV  PC, LR

/* Clear Bss */
ClearBss:
    LDR     R0, =__ZERO_TABLE
    LDR     R6, =__ZERO_TABLE_END
    SUBS    R5, R6, R0
    ADDS    R5, R5, #8
SetAddRegionBss:
    SUBS    R5, R5, #8
    CMP     R5, #0
    BEQ     ClearBss_End
    LDR     R1, [R0]
    LDR     R2, [R0, #4]
    ADDS    R0, R0, #8
    SUBS    R4, R2, R1
    CMP     R4, #0
    BEQ     SetAddRegionBss
EraseBss:
    MOVS    R4, #0
    STR     R4,[R1]
    ADDS    R1, R1, #1
    CMP     R2, R1
    BEQ     SetAddRegionBss
    B       EraseBss
ClearBss_End:
    MOV     PC, LR


    THUMB
    SECTION .intvec:DATA:ROOT(2)
    PUBLIC VTABLE
    EXTERN Stack_start_c0

VTABLE
    DCD  Stack_start_c0
    DCD Reset_Handler
    DCD NMI_Handler
    DCD HardFault_Handler
    DCD	MemManage_Handler
    DCD	BusFault_Handler
    DCD	UsageFault_Handler
    DCD	0
    DCD	0
    DCD	0
    DCD	0
    DCD	SVC_Handler
    DCD	DebugMon_Handler
    DCD	0
    DCD	PendSV_Handler
    DCD	SysTick_Handler
    DCD	WWDG_IRQHandler              			/* Window Watchdog interrupt                                          */
    DCD	PVD_IRQHandler               			/* PVD through EXTI line detection interrupt                          */
    DCD	TAMP_STAMP_IRQHandler        			/* Tamper and TimeStamp interrupts through the EXTI line              */
    DCD	RTC_WKUP_IRQHandler          			/* RTC Wakeup interrupt through the EXTI line                         */
    DCD	0                            			/* Reserved                                                           */
    DCD	RCC_IRQHandler               			/* RCC global interrupt                                               */
    DCD	EXTI0_IRQHandler             			/* EXTI Line0 interrupt                                               */
    DCD	EXTI1_IRQHandler             			/* EXTI Line1 interrupt                                               */
    DCD	EXTI2_IRQHandler             			/* EXTI Line2 interrupt                                               */
    DCD	EXTI3_IRQHandler             			/* EXTI Line3 interrupt                                               */
    DCD	EXTI4_IRQHandler             			/* EXTI Line4 interrupt                                               */
    DCD	DMA1_Stream0_IRQHandler      			/* DMA1 Stream0 global interrupt                                      */
    DCD	DMA1_Stream1_IRQHandler      			/* DMA1 Stream1 global interrupt                                      */
    DCD	DMA1_Stream2_IRQHandler      			/* DMA1 Stream2 global interrupt                                      */
    DCD	DMA1_Stream3_IRQHandler      			/* DMA1 Stream3 global interrupt                                      */
    DCD	DMA1_Stream4_IRQHandler      			/* DMA1 Stream4 global interrupt                                      */
    DCD	DMA1_Stream5_IRQHandler      			/* DMA1 Stream5 global interrupt                                      */
    DCD	DMA1_Stream6_IRQHandler      			/* DMA1 Stream6 global interrupt                                      */
    DCD	ADC_IRQHandler               			/* ADC3 global interrupts                                             */
    DCD	CAN1_TX_IRQHandler           			/* CAN1 TX interrupts                                                 */
    DCD	CAN1_RX0_IRQHandler          			/* CAN1 RX0 interrupts                                                */
    DCD	CAN1_RX1_IRQHandler          			/* CAN1 RX1 interrupts                                                */
    DCD	CAN1_SCE_IRQHandler          			/* CAN1 SCE interrupt                                                 */
    DCD	EXTI9_5_IRQHandler           			/* EXTI Line[9:5] interrupts                                          */
    DCD	TIM1_BRK_TIM9_IRQHandler     			/* TIM1 Break interrupt and TIM9 global interrupt                     */
    DCD	TIM1_UP_TIM10_IRQHandler     			/* TIM1 Update interrupt and TIM10 global interrupt                   */
    DCD	TIM1_TRG_COM_TIM11_IRQHandler			/* TIM1 Trigger and Commutation interrupts and TIM11 global interrupt */
    DCD	TIM1_CC_IRQHandler           			/* TIM1 Capture Compare interrupt                                     */
    DCD	TIM2_IRQHandler              			/* TIM2 global interrupt                                              */
    DCD	TIM3_IRQHandler              			/* TIM3 global interrupt                                              */
    DCD	TIM4_IRQHandler              			/* TIM4 global interrupt                                              */
    DCD	I2C1_EV_IRQHandler           			/* I2C1 event interrupt                                               */
    DCD	I2C1_ER_IRQHandler           			/* I2C1 error interrupt                                               */
    DCD	I2C2_EV_IRQHandler           			/* I2C2 event interrupt                                               */
    DCD	I2C2_ER_IRQHandler           			/* I2C2 error interrupt                                               */
    DCD	SPI1_IRQHandler              			/* SPI1 global interrupt                                              */
    DCD	SPI2_IRQHandler              			/* SPI2 global interrupt                                              */
    DCD	USART1_IRQHandler            			/* USART1 global interrupt                                            */
    DCD	USART2_IRQHandler            			/* USART2 global interrupt                                            */
    DCD	USART3_IRQHandler            			/* USART3 global interrupt                                            */
    DCD	EXTI15_10_IRQHandler         			/* EXTI Line[15:10] interrupts                                        */
    DCD	RTC_Alarm_IRQHandler         			/* RTC Alarms (A and B) through EXTI line interrupt                   */
    DCD	OTG_FS_WKUP_IRQHandler       			/* USB On-The-Go FS Wakeup through EXTI line interrupt                */
    DCD	TIM8_BRK_TIM12_IRQHandler    			/* TIM8 Break interrupt and TIM12 global interrupt                    */
    DCD	TIM8_UP_TIM13_IRQHandler     			/* TIM8 Update interrupt and TIM13 global interrupt                   */
    DCD	TIM8_TRG_COM_TIM14_IRQHandler			/* TIM8 Trigger and Commutation interrupts and TIM14 global interrupt */
    DCD	TIM8_CC_IRQHandler           			/* TIM8 Capture Compare interrupt                                     */
    DCD	DMA1_Stream7_IRQHandler      			/* DMA1 Stream7 global interrupt                                      */
    DCD	FSMC_IRQHandler              			/* FSMC global interrupt                                              */
    DCD	SDIO_IRQHandler              			/* SDIO global interrupt                                              */
    DCD	TIM5_IRQHandler              			/* TIM5 global interrupt                                              */
    DCD	SPI3_IRQHandler              			/* SPI3 global interrupt                                              */
    DCD	UART4_IRQHandler             			/* UART4 global interrupt                                             */
    DCD	UART5_IRQHandler             			/* UART5 global interrupt                                             */
    DCD	TIM6_DAC_IRQHandler          			/* TIM6 global interrupt, DAC1 and DAC2 underrun error interrupt      */
    DCD	TIM7_IRQHandler              			/* TIM7 global interrupt                                              */
    DCD	DMA2_Stream0_IRQHandler      			/* DMA2 Stream0 global interrupt                                      */
    DCD	DMA2_Stream1_IRQHandler      			/* DMA2 Stream1 global interrupt                                      */
    DCD	DMA2_Stream2_IRQHandler      			/* DMA2 Stream2 global interrupt                                      */
    DCD	DMA2_Stream3_IRQHandler      			/* DMA2 Stream3 global interrupt                                      */
    DCD	DMA2_Stream4_IRQHandler      			/* DMA2 Stream4 global interrupt                                      */
    DCD	ETH_IRQHandler               			/* Ethernet global interrupt                                          */
    DCD	ETH_WKUP_IRQHandler          			/* Ethernet Wakeup through EXTI line interrupt                        */
    DCD	CAN2_TX_IRQHandler           			/* CAN2 TX interrupts                                                 */
    DCD	CAN2_RX0_IRQHandler          			/* CAN2 RX0 interrupts                                                */
    DCD	CAN2_RX1_IRQHandler          			/* CAN2 RX1 interrupts                                                */
    DCD	CAN2_SCE_IRQHandler          			/* CAN2 SCE interrupt                                                 */
    DCD	OTG_FS_IRQHandler            			/* USB On The Go FS global interrupt                                  */
    DCD	DMA2_Stream5_IRQHandler      			/* DMA2 Stream5 global interrupt                                      */
    DCD	DMA2_Stream6_IRQHandler      			/* DMA2 Stream6 global interrupt                                      */
    DCD	DMA2_Stream7_IRQHandler      			/* DMA2 Stream7 global interrupt                                      */
    DCD	USART6_IRQHandler            			/* USART6 global interrupt                                            */
    DCD	I2C3_EV_IRQHandler           			/* I2C3 event interrupt                                               */
    DCD	I2C3_ER_IRQHandler           			/* I2C3 error interrupt                                               */
    DCD	OTG_HS_EP1_OUT_IRQHandler    			/* USB On The Go HS End Point 1 Out global interrupt                  */
    DCD	OTG_HS_EP1_IN_IRQHandler     			/* USB On The Go HS End Point 1 In global interrupt                   */
    DCD	OTG_HS_WKUP_IRQHandler       			/* USB On The Go HS Wakeup through EXTI interrupt                     */
    DCD	OTG_HS_IRQHandler            			/* USB On The Go HS global interrupt                                  */
    DCD	DCMI_IRQHandler              			/* DCMI global interrupt                                              */
    DCD	CRYP_IRQHandler              			/* Hash and Rng global interrupt                                      */
    DCD	FPU_IRQHandler               			/* CRYP crypto global interrupt                                       */
    DCD	HASH_RNG_IRQHandler          			/* Floating point interrupt                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	0                            			/* Reserved                                                           */
    DCD	LCD_TFT_IRQHandler           			/* LTDC global interrupt                                              */
    DCD	LCD_TFT_1_IRQHandler         			/* LTDC global error interrupt                                        */

    THUMB
    PUBWEAK NMI_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
NMI_Handler
    B       NMI_Handler

    PUBWEAK HardFault_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
HardFault_Handler
    B       HardFault_Handler

    PUBWEAK MemManage_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
MemManage_Handler
    B       MemManage_Handler

    PUBWEAK BusFault_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
BusFault_Handler
    B       BusFault_Handler

    PUBWEAK UsageFault_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
UsageFault_Handler
    B       UsageFault_Handler

    PUBWEAK SVC_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
SVC_Handler
    B       SVC_Handler

    PUBWEAK DebugMon_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
DebugMon_Handler
    B       DebugMon_Handler

    PUBWEAK PendSV_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
PendSV_Handler
    B       PendSV_Handler

    PUBWEAK SysTick_Handler
    SECTION .text:CODE:NOROOT:REORDER(1)
SysTick_Handler
    B       SysTick_Handler

    PUBWEAK WWDG_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
WWDG_IRQHandler
    B       WWDG_IRQHandler

    PUBWEAK PVD_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
PVD_IRQHandler
    B       PVD_IRQHandler

    PUBWEAK TAMP_STAMP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TAMP_STAMP_IRQHandler
    B       TAMP_STAMP_IRQHandler

    PUBWEAK RTC_WKUP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
RTC_WKUP_IRQHandler
    B       RTC_WKUP_IRQHandler

    PUBWEAK RCC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
RCC_IRQHandler
    B       RCC_IRQHandler

    PUBWEAK EXTI0_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI0_IRQHandler
    B       EXTI0_IRQHandler

    PUBWEAK EXTI1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI1_IRQHandler
    B       EXTI1_IRQHandler

    PUBWEAK EXTI2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI2_IRQHandler
    B       EXTI2_IRQHandler

    PUBWEAK EXTI3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI3_IRQHandler
    B       EXTI3_IRQHandler

    PUBWEAK EXTI4_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI4_IRQHandler
    B       EXTI4_IRQHandler

    PUBWEAK DMA1_Stream0_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream0_IRQHandler
    B       DMA1_Stream0_IRQHandler

    PUBWEAK DMA1_Stream1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream1_IRQHandler
    B       DMA1_Stream1_IRQHandler

    PUBWEAK DMA1_Stream2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream2_IRQHandler
    B       DMA1_Stream2_IRQHandler

    PUBWEAK DMA1_Stream3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream3_IRQHandler
    B       DMA1_Stream3_IRQHandler

    PUBWEAK DMA1_Stream4_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream4_IRQHandler
    B       DMA1_Stream4_IRQHandler

    PUBWEAK DMA1_Stream5_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream5_IRQHandler
    B       DMA1_Stream5_IRQHandler

    PUBWEAK DMA1_Stream6_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream6_IRQHandler
    B       DMA1_Stream6_IRQHandler

    PUBWEAK ADC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
ADC_IRQHandler
    B       ADC_IRQHandler

    PUBWEAK CAN1_TX_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN1_TX_IRQHandler
    B       CAN1_TX_IRQHandler

    PUBWEAK CAN1_RX0_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN1_RX0_IRQHandler
    B       CAN1_RX0_IRQHandler

    PUBWEAK CAN1_RX1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN1_RX1_IRQHandler
    B       CAN1_RX1_IRQHandler

    PUBWEAK CAN1_SCE_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN1_SCE_IRQHandler
    B       CAN1_SCE_IRQHandler

    PUBWEAK EXTI9_5_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI9_5_IRQHandler
    B       EXTI9_5_IRQHandler

    PUBWEAK TIM1_BRK_TIM9_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM1_BRK_TIM9_IRQHandler
    B       TIM1_BRK_TIM9_IRQHandler

    PUBWEAK TIM1_UP_TIM10_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM1_UP_TIM10_IRQHandler
    B       TIM1_UP_TIM10_IRQHandler

    PUBWEAK TIM1_TRG_COM_TIM11_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM1_TRG_COM_TIM11_IRQHandler
    B       TIM1_TRG_COM_TIM11_IRQHandler

    PUBWEAK TIM1_CC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM1_CC_IRQHandler
    B       TIM1_CC_IRQHandler

    PUBWEAK TIM2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM2_IRQHandler
    B       TIM2_IRQHandler

    PUBWEAK TIM3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM3_IRQHandler
    B       TIM3_IRQHandler

    PUBWEAK TIM4_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM4_IRQHandler
    B       TIM4_IRQHandler

    PUBWEAK I2C1_EV_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C1_EV_IRQHandler
    B       I2C1_EV_IRQHandler

    PUBWEAK I2C1_ER_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C1_ER_IRQHandler
    B       I2C1_ER_IRQHandler

    PUBWEAK I2C2_EV_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C2_EV_IRQHandler
    B       I2C2_EV_IRQHandler

    PUBWEAK I2C2_ER_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C2_ER_IRQHandler
    B       I2C2_ER_IRQHandler

    PUBWEAK SPI1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
SPI1_IRQHandler
    B       SPI1_IRQHandler

    PUBWEAK SPI2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
SPI2_IRQHandler
    B       SPI2_IRQHandler

    PUBWEAK USART1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
USART1_IRQHandler
    B       USART1_IRQHandler

    PUBWEAK USART2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
USART2_IRQHandler
    B       USART2_IRQHandler

    PUBWEAK USART3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
USART3_IRQHandler
    B       USART3_IRQHandler

    PUBWEAK EXTI15_10_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
EXTI15_10_IRQHandler
    B       EXTI15_10_IRQHandler

    PUBWEAK RTC_Alarm_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
RTC_Alarm_IRQHandler
    B       RTC_Alarm_IRQHandler

    PUBWEAK OTG_FS_WKUP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_FS_WKUP_IRQHandler
    B       OTG_FS_WKUP_IRQHandler

    PUBWEAK TIM8_BRK_TIM12_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM8_BRK_TIM12_IRQHandler
    B       TIM8_BRK_TIM12_IRQHandler

    PUBWEAK TIM8_UP_TIM13_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM8_UP_TIM13_IRQHandler
    B       TIM8_UP_TIM13_IRQHandler

    PUBWEAK TIM8_TRG_COM_TIM14_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM8_TRG_COM_TIM14_IRQHandler
    B       TIM8_TRG_COM_TIM14_IRQHandler

    PUBWEAK TIM8_CC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM8_CC_IRQHandler
    B       TIM8_CC_IRQHandler

    PUBWEAK DMA1_Stream7_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA1_Stream7_IRQHandler
    B       DMA1_Stream7_IRQHandler

    PUBWEAK FSMC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
FSMC_IRQHandler
    B       FSMC_IRQHandler

    PUBWEAK SDIO_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
SDIO_IRQHandler
    B       SDIO_IRQHandler

    PUBWEAK TIM5_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM5_IRQHandler
    B       TIM5_IRQHandler

    PUBWEAK SPI3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
SPI3_IRQHandler
    B       SPI3_IRQHandler

    PUBWEAK UART4_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
UART4_IRQHandler
    B       UART4_IRQHandler

    PUBWEAK UART5_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
UART5_IRQHandler
    B       UART5_IRQHandler

    PUBWEAK TIM6_DAC_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM6_DAC_IRQHandler
    B       TIM6_DAC_IRQHandler

    PUBWEAK TIM7_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
TIM7_IRQHandler
    B       TIM7_IRQHandler

    PUBWEAK DMA2_Stream0_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream0_IRQHandler
    B       DMA2_Stream0_IRQHandler

    PUBWEAK DMA2_Stream1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream1_IRQHandler
    B       DMA2_Stream1_IRQHandler

    PUBWEAK DMA2_Stream2_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream2_IRQHandler
    B       DMA2_Stream2_IRQHandler

    PUBWEAK DMA2_Stream3_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream3_IRQHandler
    B       DMA2_Stream3_IRQHandler

    PUBWEAK DMA2_Stream4_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream4_IRQHandler
    B       DMA2_Stream4_IRQHandler

    PUBWEAK ETH_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
ETH_IRQHandler
    B       ETH_IRQHandler

    PUBWEAK ETH_WKUP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
ETH_WKUP_IRQHandler
    B       ETH_WKUP_IRQHandler

    PUBWEAK CAN2_TX_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN2_TX_IRQHandler
    B       CAN2_TX_IRQHandler

    PUBWEAK CAN2_RX0_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN2_RX0_IRQHandler
    B       CAN2_RX0_IRQHandler

    PUBWEAK CAN2_RX1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN2_RX1_IRQHandler
    B       CAN2_RX1_IRQHandler

    PUBWEAK CAN2_SCE_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CAN2_SCE_IRQHandler
    B       CAN2_SCE_IRQHandler

    PUBWEAK OTG_FS_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_FS_IRQHandler
    B       OTG_FS_IRQHandler

    PUBWEAK DMA2_Stream5_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream5_IRQHandler
    B       DMA2_Stream5_IRQHandler

    PUBWEAK DMA2_Stream6_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream6_IRQHandler
    B       DMA2_Stream6_IRQHandler

    PUBWEAK DMA2_Stream7_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DMA2_Stream7_IRQHandler
    B       DMA2_Stream7_IRQHandler

    PUBWEAK USART6_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
USART6_IRQHandler
    B       USART6_IRQHandler

    PUBWEAK I2C3_EV_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C3_EV_IRQHandler
    B       I2C3_EV_IRQHandler

    PUBWEAK I2C3_ER_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
I2C3_ER_IRQHandler
    B       I2C3_ER_IRQHandler

    PUBWEAK OTG_HS_EP1_OUT_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_HS_EP1_OUT_IRQHandler
    B       OTG_HS_EP1_OUT_IRQHandler

    PUBWEAK OTG_HS_EP1_IN_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_HS_EP1_IN_IRQHandler
    B       OTG_HS_EP1_IN_IRQHandler

    PUBWEAK OTG_HS_WKUP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_HS_WKUP_IRQHandler
    B       OTG_HS_WKUP_IRQHandler

    PUBWEAK OTG_HS_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
OTG_HS_IRQHandler
    B       OTG_HS_IRQHandler

    PUBWEAK DCMI_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
DCMI_IRQHandler
    B       DCMI_IRQHandler

    PUBWEAK CRYP_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
CRYP_IRQHandler
    B       CRYP_IRQHandler

    PUBWEAK HASH_RNG_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
HASH_RNG_IRQHandler
    B       HASH_RNG_IRQHandler

    PUBWEAK FPU_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
FPU_IRQHandler
    B       FPU_IRQHandler

    PUBWEAK LCD_TFT_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
LCD_TFT_IRQHandler
    B       LCD_TFT_IRQHandler

    PUBWEAK LCD_TFT_1_IRQHandler
    SECTION .text:CODE:NOROOT:REORDER(1)
LCD_TFT_1_IRQHandler
    B       LCD_TFT_1_IRQHandler

    END