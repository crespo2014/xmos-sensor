#include <platform.h>
#include <xs1.h>
#include <timer.h>
port p = XS1_PORT_1A;
port led2 = XS1_PORT_1D;
port p32A = XS1_PORT_32A;

int leds_x = (1<<19) + (1<<17) + (1<<11) + (1<<9) + (1<< 7);
int leds_x2 = (1<<18) + (1<<12) + (1<<11) + (1<<10) + (1<<8);
int button_pin_32a0 = (1<<0);

#define ts_sec 100000000 //seconds
#define ts_ms 100000  //miliseconds
#define ts_us 100	// microseconds

int all_leds(int &pos)
{
	int leds_bit[] = {1<<19, 1<<18, 1<<17, 1<<10, 1<<7, 1<<8, 1<<9, 1<<12};

	pos++;
	if (pos >= sizeof(leds_bit)/sizeof(*leds_bit))
		pos = 0;

	p32A <: ~leds_bit[pos];
	return 0;
}

void wait_button()
{
	int port_v;
	p32A :> port_v;
	while(1)
	select
	{
		case p32A when pinsneq ( port_v ) :> port_v:
			led2 <: !(port_v & button_pin_32a0);
		break ;
	}
}

void wait_button_and_time()
{
	timer tmr ;
	unsigned time ;
	int pos = 0;
	tmr :> time ;
	while(1)
	select
	{
		case tmr when timerafter ( time ) :> int now :
			time += (ts_sec / 4);
			all_leds(pos);
			break;
	}
}

int main()
{
	wait_button_and_time();
	while (1)
	{
		p32A <: ~leds_x;
		delay_milliseconds(200)		;
		p32A <: ~leds_x2		;
		delay_milliseconds(200)	;
	}

	while (1)
	{
		p <: 0;
		led2 <: 1;
		delay_milliseconds(200);
		p <: 1;
		led2 <: 0;
		delay_milliseconds(200);
}
return 0;
}



