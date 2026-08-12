#!/bin/bash
# Patch V8/Chromium source to shrink large VA reservations so they fit
# within RLIMIT_AS=16GB. Run from the V8 source root.
#
# NOTE: cppgc caged heap is disabled via gn arg cppgc_enable_caged_heap=false
# (which is the real source of the 32GB reservation), so we only patch the
# PartitionAlloc pool size here.
set -e

echo "=== Patch: PartitionAlloc kPoolMaxSize 8GB -> 2GB ==="
PA_CONST=$(find . -path "*partition_alloc/partition_alloc_constants.h" | head -1)
echo "PA_CONST=$PA_CONST"
if [ -n "$PA_CONST" ]; then
  sed -i 's/constexpr size_t kPoolMaxSize = 8 \* kGiB;/constexpr size_t kPoolMaxSize = 2 * kGiB;/' "$PA_CONST"
  sed -i 's/constexpr size_t kPoolMaxSize = 16 \* kGiB;/constexpr size_t kPoolMaxSize = 2 * kGiB;/' "$PA_CONST"
  grep -n "kPoolMaxSize =" "$PA_CONST" | head -4
else
  echo "!! partition_alloc_constants.h not found"
fi

echo ""
echo "=== Done patching ==="
