#include "stdint.h"
#include "stdbool.h"

#include "HalUart.h"
#include "HalInterrupt.h"
#include "HalTimer.h"

#include "stdio.h"
#include "stdlib.h"

#include "task.h"

static void Hw_init(void);
static void Kernel_init(void);


void User_task0(void);
void User_task1(void);
void User_task2(void);

void main(void)
{
    Hw_init();

    uint32_t i = 100;
    while(i--)
    {
        Hal_uart_put_char('N');
    }
    Hal_uart_put_char('\n');

    kprintf("Hello World!\n");

    Kernel_init();

    while(true);
}

static void Hw_init(void)
{
    Hal_interrupt_init();
    Hal_uart_init();
    Hal_timer_init();
}


static void Kernel_init(void)
{
    uint32_t taskId;

    taskId = Kernel_task_create(User_task0);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task0 creation fail\n");
    }

    taskId = Kernel_task_create(User_task1);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task1 creation fail\n");
    }

    taskId = Kernel_task_create(User_task2);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task2 creation fail\n");
    }
}

static void Printf_test(void)
{
    char* str = "printf pointer test";
    char* nullptr = 0;
    uint32_t i = 5;
    uint32_t* sysctrl0 = (uint32_t*)0x10001000;

    kprintf("%s\n", "Hello printf");
    kprintf("output string pointer: %s\n", str);
    kprintf("%s is null pointer, %u number\n", nullptr, 10);
    kprintf("%u = 5\n", i);
    kprintf("dec=%u hex=%x\n", 0xff, 0xff);
    kprintf("print zero %u\n", 0);
    kprintf("SYSCTRL0 %x\n", *sysctrl0);
}

static void Timer_test(void)
{
    for(uint32_t i = 0; i < 5 ; i++)
    {
        kprintf("current count : %u\n", Hal_timer_get_1ms_counter());
        delay(1000);
    }
}

void User_task0(void)
{
    kprintf("User Task #0\n");

    while(true);
}

void User_task1(void)
{
    kprintf("User Task #1\n");

    while(true);
}

void User_task2(void)
{
    kprintf("User Task #2\n");

    while(true);
}
