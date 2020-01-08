#include <iostream>

int main(int argc, char** argv){
	if(argc > 1){
		std::cout << "Error: program does not expect any arguments" << std::endl;
		return 1;
	}
	return 0;
}
