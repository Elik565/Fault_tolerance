#include "import.hpp"
#include <filesystem>
#include <iostream>
#include <fstream>

namespace fs = std::filesystem;

std::string get_xml_filename(const std::string& xml_path) {
    size_t pos = xml_path.rfind('/');
    if (pos != std::string::npos) {
        return xml_path.substr(pos + 1);  // оставляем только имя файла
    }

    return xml_path;  // путь и есть имя файла
}

std::vector<std::string> get_fields(const std::string& xml_path, const std::string& fields_file) {
    std::ifstream fin(fields_file);
    if (!fin) {
        std::cerr << "Ошибка открытия файла с полями таблиц " << fields_file << "!\n";
        exit(1);
    }

    std::string xml_filename = get_xml_filename(xml_path);  // получаем имя xml файла 
    std::vector<std::string> fields;
    std::string line;

    // находим xml файл в файле с полями
    while (std::getline(fin, line)) {  // читаем файл построчно
        if (line.find(xml_filename) != std::string::npos) {  // если нашли строку с именем xml файла
            break;
        }
    }

    // читаем поля xml файла построчно
    while (std::getline(fin, line)) {
        if (line.find("Поля в файле") != std::string::npos) {  // ищем до следующего файла
            break;
        }
        
        if (line != "") {
            fields.push_back(line);
        }
    }

    return fields;
}

void xml_to_csv(const std::string& xml_path, const std::string& fields_file) {
    std::ifstream xml_fin(xml_path);
    if (!xml_fin) {
        std::cerr << "Ошибка открытия файла " << xml_path << " для конвертации в csv!\n";
        return;  // не выходим из программы
    }

    std::vector<std::string> fields = get_fields(xml_path, fields_file);  // находим поля в этом файле

    if (fields.size() == 0) {
        std::cerr << "Поля файла " << xml_path << " не найдены!\n";
        return;  // не выходим из программы
    }
    
}

void xml_directory_to_csv(const std::string& xml_directory, const std::string& fields_file) {
    if (!fs::is_directory(xml_directory)) {
        std::cerr << "Директория " << xml_directory << " не найдена!\n";
        exit(1);
    }

    // проходимся по всем xml файлам директории
    for (const auto& entry : fs::directory_iterator(xml_directory)) {
        if (entry.is_regular_file() && entry.path().extension() == ".xml") {
            xml_to_csv(entry.path(), fields_file);
        }
    }
}

// std::cerr << "Поля файла " << xml_filename << " не найдены в файле" << fields_file << "!\n";
            //exit(1);