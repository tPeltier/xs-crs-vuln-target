#!/bin/bash -eu
# Two-step chain: run the LLM bug-finding CRS against vuln-target, then feed
# its discovered PoV into the LLM bug-patching CRS.
#
# Run from oss-crs repo root

FIND_COMPOSE=~/xs-crs-vuln-target/crs-bug-finding-claude-code/compose.yaml
PATCH_COMPOSE=~/xs-crs-vuln-target/crs-claude-code/compose.yaml
FUZZ_PROJ_PATH=~/xs-crs-vuln-target/target
HARNESS=vuln_fuzzer

echo "==> [1/5] Preparing bug-finding CRS"
uv run oss-crs prepare --compose-file "$FIND_COMPOSE"

echo "==> [2/5] Building target for bug-finding CRS"
uv run oss-crs build-target \
  --compose-file "$FIND_COMPOSE" \
  --fuzz-proj-path "$FUZZ_PROJ_PATH"

echo "==> [3/5] Running bug-finding CRS (stops at first PoV)"
uv run oss-crs run \
  --compose-file "$FIND_COMPOSE" \
  --fuzz-proj-path "$FUZZ_PROJ_PATH" \
  --target-harness "$HARNESS" \
  --early-exit

echo "==> Locating discovered PoV(s)"
POV_DIR=$(uv run oss-crs artifacts \
  --compose-file "$FIND_COMPOSE" \
  --fuzz-proj-path "$FUZZ_PROJ_PATH" \
  --target-harness "$HARNESS" \
  --latest | python3 -c "import json,sys; print(json.load(sys.stdin)['exchange_dir']['pov'])")

if [ -z "$(ls -A "$POV_DIR" 2>/dev/null)" ]; then
  echo "No PoV found in $POV_DIR — bug-finding CRS did not discover a crash. Aborting chain." >&2
  exit 1
fi
echo "PoV(s) found in: $POV_DIR"

echo "==> [4/5] Preparing + building bug-patching CRS"
uv run oss-crs prepare --compose-file "$PATCH_COMPOSE"
uv run oss-crs build-target \
  --compose-file "$PATCH_COMPOSE" \
  --fuzz-proj-path "$FUZZ_PROJ_PATH" \
  --incremental-build

echo "==> [5/5] Running bug-patching CRS against the discovered PoV"
uv run oss-crs run \
  --compose-file "$PATCH_COMPOSE" \
  --fuzz-proj-path "$FUZZ_PROJ_PATH" \
  --target-harness "$HARNESS" \
  --incremental-build \
  --pov-dir "$POV_DIR"
