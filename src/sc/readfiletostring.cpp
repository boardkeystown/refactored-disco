#include "readfiletostring.hpp"
#include <fstream>
#include <sstream>
namespace sc {
std::string readFileToString(const std::string& filePath) {
    std::ifstream fileStream(filePath);
    std::stringstream buffer;
    buffer << fileStream.rdbuf();
    return buffer.str();
}
} // namespace sc