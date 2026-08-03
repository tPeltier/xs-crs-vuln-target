#!/bin/bash -eu

$CC $CFLAGS -c $SRC/vuln-target/vuln.c -o vuln.o
$CXX $CXXFLAGS $LIB_FUZZING_ENGINE vuln.o \
    $SRC/vuln-target/fuzzer.cc \
    -o $OUT/vuln_fuzzer
