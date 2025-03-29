#pragma once

#include <vector>
#include <string>

std::string get_xml_filename(const std::string& xml_path);

std::string check_delimiters(const std::string& line_part);

std::vector<std::string> get_fields(const std::string& xml_filename, const std::string& fields_file);

void xml_to_csv(const std::string& xml_path, const std::string& fields_file, const std::string& csv_directory);

void xml_directory_to_csv(const std::string& xml_directory, const std::string& fields_file);