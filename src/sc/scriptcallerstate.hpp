#pragma once
#include <cstddef>
namespace sc::state {
enum TYPE : std::size_t {
    INIT,
    RUN,
    ERROR
};
} // namespace sc::state