#include "sc/scriptcaller.hpp"
#include <iostream>
int main() {
    sc::ScriptCaller sc;
    sc.init("m.py");
    for (int i= 0; i < 5; ++i) {
        sc.run();
    }
    std::cout << "done!\n";
    return 0;
}