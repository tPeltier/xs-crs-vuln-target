#include <cstddef>
#include <cstdint>
#include <stdint.h>
#include <stddef.h>

extern "C" void parse_packet(const uint8_t *data, size_t size);

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    parse_packet(data, size);
    return 0;
}
