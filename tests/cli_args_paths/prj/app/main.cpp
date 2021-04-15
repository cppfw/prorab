#include <iostream>

#include "main.hpp"

int main(int argc, const char** argv){

	std::cout << "Hello stuff!" << '\n';
	std::cout << "2 + 13 = " << do_stuff(2) << '\n';
	std::cout << "4 + 13 = " << do_some(4) << '\n';

	return 0;
}
