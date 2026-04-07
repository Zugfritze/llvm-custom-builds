$LLVM_REPO_URL = $args[0]
$LLVM_BRANCH = $args[1]
$LLVM_BOOTSTRAP_PATH = $args[2]

if ([string]::IsNullOrEmpty($LLVM_REPO_URL)) {
    $LLVM_REPO_URL = "https://github.com/llvm/llvm-project.git"
}

if ([string]::IsNullOrEmpty($LLVM_BRANCH)) {
    $LLVM_BRANCH = "main"
}

$C_COMPILER = "clang-cl.exe"
$CXX_COMPILER = "clang-cl.exe"
if (![string]::IsNullOrEmpty($LLVM_BOOTSTRAP_PATH)) {
    $C_COMPILER = "$LLVM_BOOTSTRAP_PATH\bin\clang-cl.exe"
    $CXX_COMPILER = "$LLVM_BOOTSTRAP_PATH\bin\clang-cl.exe"
}

if (-not (Test-Path -Path "llvm-project" -PathType Container)) {
    git clone --branch "$LLVM_BRANCH" --single-branch --depth=1 "$LLVM_REPO_URL" llvm-project
}

Set-Location llvm-project
git fetch origin
git checkout "$LLVM_BRANCH"

git apply ..\175764.patch
git apply ..\176788.patch

New-Item -Path "build" -Force -ItemType "directory"
Set-Location build

New-Item -Path "install" -Force -ItemType "directory"

cmake `
    -G Ninja `
    -DCMAKE_INSTALL_PREFIX=install `
    -DCMAKE_C_COMPILER="$C_COMPILER" `
    -DCMAKE_CXX_COMPILER="$CXX_COMPILER" `
    -DLLVM_USE_LINKER=lld `
    -DCMAKE_BUILD_TYPE=Release `
    -DLLVM_TARGETS_TO_BUILD=X86 `
    -DLLVM_ENABLE_LTO=Thin `
    -DLLVM_ENABLE_ZLIB=OFF `
    -DLLVM_ENABLE_LIBXML2=OFF `
    -DLLVM_INCLUDE_DOCS=OFF `
    -DLLVM_INCLUDE_BENCHMARKS=OFF `
    -DLLVM_INCLUDE_EXAMPLES=OFF `
    -DLLVM_INCLUDE_TESTS=OFF `
    -DLLVM_INCLUDE_TOOLS=ON `
    -DLLVM_INCLUDE_UTILS=OFF `
    -DLLVM_OPTIMIZED_TABLEGEN=ON `
    -DLLVM_BUILD_LLVM_DYLIB=ON `
    -DLLVM_BUILD_LLVM_DYLIB_VIS=ON `
    -DLLVM_LINK_LLVM_DYLIB=ON `
    -DLLVM_ENABLE_PLUGINS=ON `
    ../llvm

cmake --build . --config Release
cmake --install . --strip --config Release
