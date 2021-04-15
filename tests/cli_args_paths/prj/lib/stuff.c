#include "stuff.h"

#include <stdio.h>

int do_c_stuff(int a){
	printf("lib: c source file = %s\n", __FILE__);
	return a + 13;
}
