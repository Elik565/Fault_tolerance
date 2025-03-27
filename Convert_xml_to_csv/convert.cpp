#include "convert.hpp"
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


std::vector<std::string> get_fields(const std::string& xml_filename, const std::string& fields_file) {
    std::ifstream fin(fields_file);
    if (!fin) {
        std::cerr << "Ошибка открытия файла с полями таблиц " << fields_file << "!\n";
        exit(1);
    }

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

    fin.close();

    return fields;
}


void xml_to_csv(const std::string& xml_path, const std::string& fields_file, const std::string& csv_directory) {
    std::ifstream fin(xml_path);
    if (!fin) {
        std::cerr << "Ошибка открытия файла " << xml_path << " для конвертации в csv!\n";
        return;  // не выходим из программы
    }

    std::string xml_filename = get_xml_filename(xml_path);  // получаем имя xml файла 

    std::vector<std::string> fields = get_fields(xml_filename, fields_file);  // находим поля в этом файле

    if (fields.size() == 0) {  // если не нашли полей xml файла
        std::cerr << "Поля файла " << xml_path << " не найдены в файле" << fields_file << "!\n";
        return;  // не выходим из программы
    }
    
    // создаем файл csv
    std::string csv_path = csv_directory + "/" + xml_filename.substr(0, xml_filename.find('.')) + ".csv";
    std::ofstream fout(csv_path);

    // печатаем поля в csv файл
    for (size_t i = 0; i < fields.size(); i++) {
        fout << fields[i];
        if (i != fields.size() - 1) {
            fout << ", ";
        }
    }
    fout << "\n";

    std::string line;

    // пропускаем первые две строки
    std::getline(fin, line);
    std::getline(fin, line);

    // читаем файл построчно
    while (std::getline(fin, line)) {
        for (size_t i = 0; i < fields.size(); i++) {
            size_t field_pos = line.find(" " + fields[i]);  // находим позицию поля
            if (field_pos != std::string::npos) {  // если нашли 
                size_t mark_pos1 = line.find_first_of('"', field_pos + fields[i].size());
                size_t mark_pos2 = line.find_first_of('"', mark_pos1 + 1);
                std::string str = line.substr(mark_pos1 + 1, mark_pos2 - mark_pos1 - 1);
                fout << line.substr(mark_pos1 + 1, mark_pos2 - mark_pos1 - 1);
            }
            if (i != fields.size() - 1) {
                fout << ", ";
            }
            else {
                fout << "\n";
            }
        }
    }

    fin.close();

    std::cout << "Файл " << xml_path << " успешно обработан!\n";
}


void xml_directory_to_csv(const std::string& xml_directory, const std::string& fields_file) {
    if (!fs::is_directory(xml_directory)) {
        std::cerr << "Директория " << xml_directory << " не найдена!\n";
        exit(1);
    }

    // создаем директорию с csv файлами
    std::string csv_directory = xml_directory + "_csv";
    if (!fs::exists(csv_directory)) {
        if (!fs::create_directory(csv_directory)) {
            std::cerr << "Директорию с csv файлами " << csv_directory << " не удалось создать!\n";
            exit(1);
        }
    }

    // проходимся по всем xml файлам директории
    for (const auto& entry : fs::directory_iterator(xml_directory)) {
        if (entry.is_regular_file() && entry.path().extension() == ".xml") {
            xml_to_csv(entry.path(), fields_file, csv_directory);
        }
    }

    std::cout << "Директория " << csv_directory << " с csv файлами успешно создана!\n";
}