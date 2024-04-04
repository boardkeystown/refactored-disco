#include "scriptcaller.hpp"
#include "scriptcallerstate.hpp"
#include "readfiletostring.hpp"


#include <stdexcept>
#include <iostream>
namespace sc {
// private
void ScriptCaller::handel_error() {
    this->state = state::ERROR;
    PyObject* ptype = nullptr;
    PyObject* pvalue = nullptr;
    PyObject* ptraceback = nullptr;
    PyErr_Fetch(&ptype, &pvalue, &ptraceback);
    PyErr_NormalizeException(&ptype, &pvalue, &ptraceback);
    if (ptraceback != nullptr) {
        PyException_SetTraceback(pvalue, ptraceback);
    }
    boost::python::handle<> htype(ptype);
    boost::python::handle<> hvalue(boost::python::allow_null(pvalue));
    boost::python::handle<> htraceback(boost::python::allow_null(ptraceback));
    boost::python::object traceback = boost::python::import("traceback");
    boost::python::object format_exception = traceback.attr("format_exception");
    boost::python::object formatted_list = format_exception(htype, hvalue, htraceback);
    boost::python::object formatted = boost::python::str("\n").join(formatted_list);
    std::string result_str = boost::python::extract<std::string>(formatted);
    std::cout << result_str << std::endl;
}

// public 
ScriptCaller::ScriptCaller() :
    state(state::INIT)
{}
ScriptCaller::~ScriptCaller() {
    if (this->state>=state::RUN) {
        this->main_module=boost::python::object();
        this->main_namespace=boost::python::object();
        this->call_function=boost::python::object();
    }
}
void ScriptCaller::init(const std::string &fpath) {
    if (this->state!=state::INIT) return;
    this->state=state::RUN;
    try {
        if (Py_IsInitialized()==0) Py_Initialize();
        // wchar_t* pythonHome = Py_DecodeLocale("C:\\msys64\\mingw64", NULL);
        // Py_SetPythonHome(pythonHome);
        PyRun_SimpleString("import sys");
        PyRun_SimpleString("sys.path.append('./')");
        this->main_module=boost::python::import("__main__");
        this->main_namespace=this->main_module.attr("__dict__");
        // NOTE: why on windows does exec_file not work??? cringe
        boost::python::exec(
            readFileToString(fpath).c_str(),
            this->main_namespace,
            this->main_namespace
        );
        boost::python::object false_object(false);
        this->call_function=boost::python::dict(
            this->main_namespace
        ).get("call_function",false_object);
        if (this->call_function==false_object) {
             throw std::runtime_error("failed to bind call function!");
        }
    } catch (const boost::python::error_already_set &) {
        this->handel_error();
    } catch (const std::runtime_error &e) {
        this->state=state::ERROR;
        std::cout << "Error:" << e.what() << "\n";
    } catch (...) {
        std::cout << "Error: something bad happened and I do not know what?\n";
    }
}
void ScriptCaller::run() {
    if (this->state!=state::RUN) return;
    try {
        this->call_function();
    } catch (const boost::python::error_already_set &) {
        this->handel_error();
    }
}
} // namespace sc
