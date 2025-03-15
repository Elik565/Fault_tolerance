#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <set>
#include <filesystem>

void find_fields_in_file(const std::string& filename) {
    std::ifstream fin(filename);
    if (!fin) {
        std::cerr << "Ошибка при открытии файла " << filename << "!\n";
        return;
    }

    std::set<std::string> fields;  // словарь
    std::string line;

    // читаем файл построчно
    while (std::getline(fin, line)) {
        if (line.find("<row ") != std::string::npos) {
            std::istringstream iss(line);
            std::string str_1;  // слово между пробелами в строке
            while (iss >> str_1) {
                // находим поле (в слове должно быть ' ="***" ')
                size_t pos_1 = str_1.find("=\"");
                if (pos_1 != std::string::npos) {
                    std::string str_2 = str_1.substr(pos_1 + 2, str_1.size());  // отбрасываем ' =" '
                    if (str_2.find("\"") != std::string::npos) {
                        fields.insert(str_1.substr(0, pos_1));  // если нашли, то заносим поле в словарь
                    }
                }
            }
        }
    }

    // выводим поля
    std::cout << "Поля в файле " << filename << ":\n";
    for (const auto& field : fields) {
        std::cout << "\t" << field << "\n";
    }
}

void find_fields_in_directory(const std::string& directory) {
    for (const auto& entry : std::filesystem::directory_iterator(directory)) {
        if (entry.is_regular_file() && entry.path().extension() == ".xml") {
            find_fields_in_file(entry.path());
        }
        std::cout << "\n";
    }
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Неправильные входны параметры!\n";
        return 1;
    }
    
    if (!std::filesystem::is_directory(argv[1])) {
        std::cerr << "Указанная директория не найдена!\n";
        return 1;
    }

    find_fields_in_directory(argv[1]);
    
    return 0;
}
