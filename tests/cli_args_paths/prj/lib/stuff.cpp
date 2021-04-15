#include "stuff.hpp"

#include <iostream>

int do_stuff(int a){
	std::cout << "lib: cpp source file = " << __FILE__ << '\n';
	return a + 13;
}
