
.section ".init_table", "a"
  .long vectortable_start
  .long init_vectortable_start
  .long init_vectortable_end
  .long data_start
  .long init_data_start
  .long init_data_end
  .long data_nocache_start
  .long init_data_nocache_start
  .long init_data_nocache_end
  .long data_shareable_start
  .long init_data_shareable_start
  .long init_data_shareable_end

.section ".zero_table", "a"
  .long bss_start
  .long bss_end
  .long bss_nocache_start
  .long bss_nocache_end
  .long bss_shareable_start
  .long bss_shareable_end


.section ".startup","ax"
.thumb
.set VTOR_REG,  0xE000ED08                      /* Vector Table Offset Register */
/*.set MASTER_ID, 0x4001FC00   */               /* Đọc giá trị trong địa chỉ này để xem đang là core nào */
.set MAIN_CORE, 0x0
.align 2

.thumb 
.globl Reset_Handler
.globl _start
_start:
Reset_Handler:

/* Clear Register */
BL ClearRegister

/* Reset core register */
BL SetUpVtorRegister

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
  
.globl ThoNVEnd
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

/* Gán giá trị VTOR_REG vào memory vectortable_start */
SetUpVtorRegister:
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
    /* Nếu SRAM_INIT không bằng 0 thì bỏ qua */
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
    LDR     R0, =init_table
    LDR     R6, =init_table_end
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
    LDR     R0, =zero_table
    LDR     R6, =zero_table_end
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

.thumb
.section ".intc_vector","ax"
.align 2
.globl VTABLE
.globl NMI_Handler
.globl HardFault_Handler
.globl MemManage_Handler
.globl BusFault_Handler
.globl UsageFault_Handler
.globl undefined_handler
.globl undefined_handler
.globl SVC_Handler
.globl DebugMon_Handler
.globl PendSV_Handler
.globl SysTick_Handler
VTABLE:
.long  Stack_start_c0
.long Reset_Handler
.long NMI_Handler
.long HardFault_Handler
.long	MemManage_Handler
.long	BusFault_Handler
.long	UsageFault_Handler
.long	0
.long	0
.long	0
.long	0
.long	SVC_Handler
.long	DebugMon_Handler
.long	0
.long	PendSV_Handler
.long	SysTick_Handler
.long	WWDG_IRQHandler              			/* Window Watchdog interrupt                                          */
.long	PVD_IRQHandler               			/* PVD through EXTI line detection interrupt                          */
.long	TAMP_STAMP_IRQHandler        			/* Tamper and TimeStamp interrupts through the EXTI line              */
.long	RTC_WKUP_IRQHandler          			/* RTC Wakeup interrupt through the EXTI line                         */
.long	0                            			/* Reserved                                                           */
.long	RCC_IRQHandler               			/* RCC global interrupt                                               */
.long	EXTI0_IRQHandler             			/* EXTI Line0 interrupt                                               */
.long	EXTI1_IRQHandler             			/* EXTI Line1 interrupt                                               */
.long	EXTI2_IRQHandler             			/* EXTI Line2 interrupt                                               */
.long	EXTI3_IRQHandler             			/* EXTI Line3 interrupt                                               */
.long	EXTI4_IRQHandler             			/* EXTI Line4 interrupt                                               */
.long	DMA1_Stream0_IRQHandler      			/* DMA1 Stream0 global interrupt                                      */
.long	DMA1_Stream1_IRQHandler      			/* DMA1 Stream1 global interrupt                                      */
.long	DMA1_Stream2_IRQHandler      			/* DMA1 Stream2 global interrupt                                      */
.long	DMA1_Stream3_IRQHandler      			/* DMA1 Stream3 global interrupt                                      */
.long	DMA1_Stream4_IRQHandler      			/* DMA1 Stream4 global interrupt                                      */
.long	DMA1_Stream5_IRQHandler      			/* DMA1 Stream5 global interrupt                                      */
.long	DMA1_Stream6_IRQHandler      			/* DMA1 Stream6 global interrupt                                      */
.long	ADC_IRQHandler               			/* ADC3 global interrupts                                             */
.long	CAN1_TX_IRQHandler           			/* CAN1 TX interrupts                                                 */
.long	CAN1_RX0_IRQHandler          			/* CAN1 RX0 interrupts                                                */
.long	CAN1_RX1_IRQHandler          			/* CAN1 RX1 interrupts                                                */
.long	CAN1_SCE_IRQHandler          			/* CAN1 SCE interrupt                                                 */
.long	EXTI9_5_IRQHandler           			/* EXTI Line[9:5] interrupts                                          */
.long	TIM1_BRK_TIM9_IRQHandler     			/* TIM1 Break interrupt and TIM9 global interrupt                     */
.long	TIM1_UP_TIM10_IRQHandler     			/* TIM1 Update interrupt and TIM10 global interrupt                   */
.long	TIM1_TRG_COM_TIM11_IRQHandler			/* TIM1 Trigger and Commutation interrupts and TIM11 global interrupt */
.long	TIM1_CC_IRQHandler           			/* TIM1 Capture Compare interrupt                                     */
.long	TIM2_IRQHandler              			/* TIM2 global interrupt                                              */
.long	TIM3_IRQHandler              			/* TIM3 global interrupt                                              */
.long	TIM4_IRQHandler              			/* TIM4 global interrupt                                              */
.long	I2C1_EV_IRQHandler           			/* I2C1 event interrupt                                               */
.long	I2C1_ER_IRQHandler           			/* I2C1 error interrupt                                               */
.long	I2C2_EV_IRQHandler           			/* I2C2 event interrupt                                               */
.long	I2C2_ER_IRQHandler           			/* I2C2 error interrupt                                               */
.long	SPI1_IRQHandler              			/* SPI1 global interrupt                                              */
.long	SPI2_IRQHandler              			/* SPI2 global interrupt                                              */
.long	USART1_IRQHandler            			/* USART1 global interrupt                                            */
.long	USART2_IRQHandler            			/* USART2 global interrupt                                            */
.long	USART3_IRQHandler            			/* USART3 global interrupt                                            */
.long	EXTI15_10_IRQHandler         			/* EXTI Line[15:10] interrupts                                        */
.long	RTC_Alarm_IRQHandler         			/* RTC Alarms (A and B) through EXTI line interrupt                   */
.long	OTG_FS_WKUP_IRQHandler       			/* USB On-The-Go FS Wakeup through EXTI line interrupt                */
.long	TIM8_BRK_TIM12_IRQHandler    			/* TIM8 Break interrupt and TIM12 global interrupt                    */
.long	TIM8_UP_TIM13_IRQHandler     			/* TIM8 Update interrupt and TIM13 global interrupt                   */
.long	TIM8_TRG_COM_TIM14_IRQHandler			/* TIM8 Trigger and Commutation interrupts and TIM14 global interrupt */
.long	TIM8_CC_IRQHandler           			/* TIM8 Capture Compare interrupt                                     */
.long	DMA1_Stream7_IRQHandler      			/* DMA1 Stream7 global interrupt                                      */
.long	FSMC_IRQHandler              			/* FSMC global interrupt                                              */
.long	SDIO_IRQHandler              			/* SDIO global interrupt                                              */
.long	TIM5_IRQHandler              			/* TIM5 global interrupt                                              */
.long	SPI3_IRQHandler              			/* SPI3 global interrupt                                              */
.long	UART4_IRQHandler             			/* UART4 global interrupt                                             */
.long	UART5_IRQHandler             			/* UART5 global interrupt                                             */
.long	TIM6_DAC_IRQHandler          			/* TIM6 global interrupt, DAC1 and DAC2 underrun error interrupt      */
.long	TIM7_IRQHandler              			/* TIM7 global interrupt                                              */
.long	DMA2_Stream0_IRQHandler      			/* DMA2 Stream0 global interrupt                                      */
.long	DMA2_Stream1_IRQHandler      			/* DMA2 Stream1 global interrupt                                      */
.long	DMA2_Stream2_IRQHandler      			/* DMA2 Stream2 global interrupt                                      */
.long	DMA2_Stream3_IRQHandler      			/* DMA2 Stream3 global interrupt                                      */
.long	DMA2_Stream4_IRQHandler      			/* DMA2 Stream4 global interrupt                                      */
.long	ETH_IRQHandler               			/* Ethernet global interrupt                                          */
.long	ETH_WKUP_IRQHandler          			/* Ethernet Wakeup through EXTI line interrupt                        */
.long	CAN2_TX_IRQHandler           			/* CAN2 TX interrupts                                                 */
.long	CAN2_RX0_IRQHandler          			/* CAN2 RX0 interrupts                                                */
.long	CAN2_RX1_IRQHandler          			/* CAN2 RX1 interrupts                                                */
.long	CAN2_SCE_IRQHandler          			/* CAN2 SCE interrupt                                                 */
.long	OTG_FS_IRQHandler            			/* USB On The Go FS global interrupt                                  */
.long	DMA2_Stream5_IRQHandler      			/* DMA2 Stream5 global interrupt                                      */
.long	DMA2_Stream6_IRQHandler      			/* DMA2 Stream6 global interrupt                                      */
.long	DMA2_Stream7_IRQHandler      			/* DMA2 Stream7 global interrupt                                      */
.long	USART6_IRQHandler            			/* USART6 global interrupt                                            */
.long	I2C3_EV_IRQHandler           			/* I2C3 event interrupt                                               */
.long	I2C3_ER_IRQHandler           			/* I2C3 error interrupt                                               */
.long	OTG_HS_EP1_OUT_IRQHandler    			/* USB On The Go HS End Point 1 Out global interrupt                  */
.long	OTG_HS_EP1_IN_IRQHandler     			/* USB On The Go HS End Point 1 In global interrupt                   */
.long	OTG_HS_WKUP_IRQHandler       			/* USB On The Go HS Wakeup through EXTI interrupt                     */
.long	OTG_HS_IRQHandler            			/* USB On The Go HS global interrupt                                  */
.long	DCMI_IRQHandler              			/* DCMI global interrupt                                              */
.long	CRYP_IRQHandler              			/* Hash and Rng global interrupt                                      */
.long	FPU_IRQHandler               			/* CRYP crypto global interrupt                                       */
.long	HASH_RNG_IRQHandler          			/* Floating point interrupt                                           */
.long	0                            			/* Reserved                                                           */
.long	0                            			/* Reserved                                                           */
.long	0                            			/* Reserved                                                           */
.long	0                            			/* Reserved                                                           */
.long	0                            			/* Reserved                                                           */
.long	0                            			/* Reserved                                                           */
.long	LCD_TFT_IRQHandler           			/* LTDC global interrupt                                              */
.long	LCD_TFT_1_IRQHandler         			/* LTDC global error interrupt  

.size VTABLE, . - VTABLE
    
/* Default_Handler  */
.align 4
.ltorg

.thumb
.thumb_func
.section .text.Default_Handler,"ax",%progbits
.align      2

Default_Handler:
  b .
  .size Default_Handler, .-Default_Handler

/* macro set Default_Handler  */
.macro             Set_Default_Handler  Handler_Name
.weak              \Handler_Name
.thumb_set         \Handler_Name, Default_Handler
.endm

        Set_Default_Handler NMI_Handler
        Set_Default_Handler HardFault_Handler
        Set_Default_Handler MemManage_Handler
        Set_Default_Handler BusFault_Handler
        Set_Default_Handler UsageFault_Handler
        Set_Default_Handler SVC_Handler
        Set_Default_Handler DebugMon_Handler
        Set_Default_Handler PendSV_Handler
        Set_Default_Handler SysTick_Handler
        Set_Default_handler	WWDG_IRQHandler              			
        Set_Default_handler	PVD_IRQHandler               			
        Set_Default_handler	TAMP_STAMP_IRQHandler        			
        Set_Default_handler	RTC_WKUP_IRQHandler          			                      			
        Set_Default_handler	RCC_IRQHandler               			
        Set_Default_handler	EXTI0_IRQHandler             			
        Set_Default_handler	EXTI1_IRQHandler             			
        Set_Default_handler	EXTI2_IRQHandler             			
        Set_Default_handler	EXTI3_IRQHandler             			
        Set_Default_handler	EXTI4_IRQHandler             			
        Set_Default_handler	DMA1_Stream0_IRQHandler      			
        Set_Default_handler	DMA1_Stream1_IRQHandler      			
        Set_Default_handler	DMA1_Stream2_IRQHandler      			
        Set_Default_handler	DMA1_Stream3_IRQHandler      			
        Set_Default_handler	DMA1_Stream4_IRQHandler      			
        Set_Default_handler	DMA1_Stream5_IRQHandler      			
        Set_Default_handler	DMA1_Stream6_IRQHandler      			
        Set_Default_handler	ADC_IRQHandler               			
        Set_Default_handler	CAN1_TX_IRQHandler           			
        Set_Default_handler	CAN1_RX0_IRQHandler          			
        Set_Default_handler	CAN1_RX1_IRQHandler          			
        Set_Default_handler	CAN1_SCE_IRQHandler          			
        Set_Default_handler	EXTI9_5_IRQHandler           			
        Set_Default_handler	TIM1_BRK_TIM9_IRQHandler     			
        Set_Default_handler	TIM1_UP_TIM10_IRQHandler     			
        Set_Default_handler	TIM1_TRG_COM_TIM11_IRQHandler			
        Set_Default_handler	TIM1_CC_IRQHandler           			
        Set_Default_handler	TIM2_IRQHandler              			
        Set_Default_handler	TIM3_IRQHandler              			
        Set_Default_handler	TIM4_IRQHandler              			
        Set_Default_handler	I2C1_EV_IRQHandler           			
        Set_Default_handler	I2C1_ER_IRQHandler           			
        Set_Default_handler	I2C2_EV_IRQHandler           			
        Set_Default_handler	I2C2_ER_IRQHandler           			
        Set_Default_handler	SPI1_IRQHandler              			
        Set_Default_handler	SPI2_IRQHandler              			
        Set_Default_handler	USART1_IRQHandler            			
        Set_Default_handler	USART2_IRQHandler            			
        Set_Default_handler	USART3_IRQHandler            			
        Set_Default_handler	EXTI15_10_IRQHandler         			
        Set_Default_handler	RTC_Alarm_IRQHandler         			
        Set_Default_handler	OTG_FS_WKUP_IRQHandler       			
        Set_Default_handler	TIM8_BRK_TIM12_IRQHandler    			
        Set_Default_handler	TIM8_UP_TIM13_IRQHandler     			
        Set_Default_handler	TIM8_TRG_COM_TIM14_IRQHandler			
        Set_Default_handler	TIM8_CC_IRQHandler           			
        Set_Default_handler	DMA1_Stream7_IRQHandler      			
        Set_Default_handler	FSMC_IRQHandler              			
        Set_Default_handler	SDIO_IRQHandler              			
        Set_Default_handler	TIM5_IRQHandler              			
        Set_Default_handler	SPI3_IRQHandler              			
        Set_Default_handler	UART4_IRQHandler             			
        Set_Default_handler	UART5_IRQHandler             			
        Set_Default_handler	TIM6_DAC_IRQHandler          			
        Set_Default_handler	TIM7_IRQHandler              			
        Set_Default_handler	DMA2_Stream0_IRQHandler      			
        Set_Default_handler	DMA2_Stream1_IRQHandler      			
        Set_Default_handler	DMA2_Stream2_IRQHandler      			
        Set_Default_handler	DMA2_Stream3_IRQHandler      			
        Set_Default_handler	DMA2_Stream4_IRQHandler      			
        Set_Default_handler	ETH_IRQHandler               			
        Set_Default_handler	ETH_WKUP_IRQHandler          			
        Set_Default_handler	CAN2_TX_IRQHandler           			
        Set_Default_handler	CAN2_RX0_IRQHandler          			
        Set_Default_handler	CAN2_RX1_IRQHandler          			
        Set_Default_handler	CAN2_SCE_IRQHandler          			
        Set_Default_handler	OTG_FS_IRQHandler            			
        Set_Default_handler	DMA2_Stream5_IRQHandler      			
        Set_Default_handler	DMA2_Stream6_IRQHandler      			
        Set_Default_handler	DMA2_Stream7_IRQHandler      			
        Set_Default_handler	USART6_IRQHandler            			
        Set_Default_handler	I2C3_EV_IRQHandler           			
        Set_Default_handler	I2C3_ER_IRQHandler           			
        Set_Default_handler	OTG_HS_EP1_OUT_IRQHandler    			
        Set_Default_handler	OTG_HS_EP1_IN_IRQHandler     			
        Set_Default_handler	OTG_HS_WKUP_IRQHandler       			
        Set_Default_handler	OTG_HS_IRQHandler            			
        Set_Default_handler	DCMI_IRQHandler              			
        Set_Default_handler	CRYP_IRQHandler              			
        Set_Default_handler	HASH_RNG_IRQHandler          			
        Set_Default_handler	FPU_IRQHandler               			                          			
        Set_Default_handler	LCD_TFT_IRQHandler           			
        Set_Default_handler	LCD_TFT_1_IRQHandler     
        .end    		
        
        


        
                            