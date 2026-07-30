FROM gcr.io/oss-fuzz-base/base-builder
COPY build.sh $SRC/
COPY . $SRC/vuln-target
WORKDIR $SRC/vuln-target
