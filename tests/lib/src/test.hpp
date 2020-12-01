#pragma once

#include <iostream>

class test_class{

public:
	test_class(){
		int a = 3;

		[&a](){a += 1;}();

		std::cout << "a = " << a << std::endl;
	}

	test_class(const test_class&) = delete;
};
