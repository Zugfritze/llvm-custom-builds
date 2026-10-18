$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

clang-cl --version
lld-link --version

git -C llvm apply @(Get-ChildItem "patch/*.patch" -File | Sort-Object Name | ForEach-Object { $_.FullName })

cmake -S llvm/llvm -B build -G Ninja `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_INSTALL_PREFIX="$PWD/install" `
    -DCMAKE_C_COMPILER=clang-cl.exe `
    -DCMAKE_CXX_COMPILER=clang-cl.exe `
    -DCMAKE_C_COMPILER_LAUNCHER="$env:SCCACHE_PATH" `
    -DCMAKE_CXX_COMPILER_LAUNCHER="$env:SCCACHE_PATH" `
    -DCMAKE_LINKER=lld-link.exe `
    -DLLVM_ENABLE_LLD=ON `
    -DCMAKE_C_FLAGS="-fuse-ld=lld" `
    -DCMAKE_CXX_FLAGS="-fuse-ld=lld" `
    -DLLVM_TARGETS_TO_BUILD="X86" `
    -DLLVM_OPTIMIZED_TABLEGEN=ON `
    -DLLVM_ENABLE_ASSERTIONS=OFF `
    -DLLVM_ENABLE_DUMP=ON `
    -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_ZLIB=OFF -DLLVM_ENABLE_ZSTD=OFF `
    -DLLVM_ENABLE_CURL=OFF -DLLVM_ENABLE_HTTPLIB=OFF `
    -DLLVM_ENABLE_DIA_SDK=OFF `
    -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF `
    -DLLVM_INCLUDE_BENCHMARKS=OFF -DLLVM_INCLUDE_DOCS=OFF `
    -DLLVM_BUILD_LLVM_DYLIB=ON `
    -DLLVM_BUILD_LLVM_DYLIB_VIS=ON `
    -DLLVM_LINK_LLVM_DYLIB=ON `
    -DLLVM_BUILD_LLVM_C_DYLIB=ON `
    -DLLVM_ENABLE_PLUGINS=ON `
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON

ninja -C build install
