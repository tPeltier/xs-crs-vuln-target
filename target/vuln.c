#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

void parse_packet(const uint8_t *data, size_t size) {
    if (size < 4) return;

    uint32_t len = *(uint32_t *)data;
    char *buf = malloc(256);
    if (!buf) return;

    memcpy(buf, data + 4, len);

    buf[0] = 0;

    free(buf);
}
