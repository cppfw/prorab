#include <iostream>

#include "main.hpp"

int main(int argc, const char** argv){

	std::cout << "Hello stuff!" << '\n';
	std::cout << do_stuff(2) << '\n';
	std::cout << do_some(4) << '\n';
	std::cout << "app: cpp source file = " << __FILE__ << '\n';

	return 0;
}
