#include "import.hpp"
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Неправильные входные параметры!\n";
        return 1;
    }

    xml_directory_to_csv(argv[1], argv[2]);
}
