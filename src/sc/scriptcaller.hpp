#pragma once
#define BOOST_NO_AUTO_PTR
#include <Python.h>
#include <boost/python.hpp>
#include <string>
namespace sc {
class ScriptCaller {
private:
    std::size_t state;
private:
    boost::python::object main_module;
    boost::python::object main_namespace;
    boost::python::object call_function;
private:
    void handel_error();
public:
    ScriptCaller();
    ~ScriptCaller();
    void init(const std::string &fpath);
    void run();
};
} // namespace sc