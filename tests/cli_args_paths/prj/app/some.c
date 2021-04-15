#include "some.h"

#include <stdio.h>

int do_some(int a){
	printf("app: c source file = %s\n", __FILE__);
	return do_c_stuff(a);
}
