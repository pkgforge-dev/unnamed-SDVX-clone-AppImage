#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake          \
	freetype2      \
	libarchive     \
	libjpeg-turbo  \
	libogg         \
	libpng         \
	libvorbis      \
	noto-fonts     \
	openssl        \
	sdl2           \
	zlib


echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# If the application needs to be manually built that has to be done down here
git clone https://github.com/Drewol/unnamed-sdvx-clone.git ./usc && (
	cd ./usc

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta\|nightly' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version

	git apply --index --ignore-whitespace ../cmake4-build-fix.patch
	git submodule update --init --recursive
	cmake -DCMAKE_BUILD_TYPE=Release ./
	make -j"$(nproc)"
)

mkdir -p ./AppDir/bin
cp -r ./usc/bin/* ./AppDir/bin
