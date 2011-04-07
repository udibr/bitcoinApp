= bitcoin.org =
git clone https://github.com/bitcoin/bitcoin.git bitcoin.org
Add bitcoin.org to project
remove unused files from project (but dont delete them):
sha256.cpp
crypt/obj
obj/
ui.*
uibase.*
uiproject.*
xpm/

add preprocessor macros to Debug/Release
CRYPTOPP_DISABLE_ASM
MSG_NOSIGNAL=0
for now we will skip USE_SSL

We will ignore the warning suppresion flags:
-Wno-invalid-offsetof -Wformat

Download bitcoin530.png from https://www.bitcoin.org/smf/index.php?topic=64.0
and resize it to  bitcoin512.png (512*512) and bitcoinScreenShot.png (320*480) (with Gimp)

comment out the main function in init.cpp

= openssl =
mkdir /tmp/openssl
mkdir /tmp/openssl/openssl_i386
mkdir /tmp/openssl/openssl_armv6
mkdir /tmp/openssl/openssl_armv7

#http://www.therareair.com/2009/01/01/tutorial-how-to-compile-openssl-for-the-iphone/
# download openssl-1.0.0d.tar.gz from http://www.openssl.org/source/ and open to /tmp/openssl
cd /tmp/openssl/openssl-1.0.0d/
./config --openssldir=/tmp/openssl/openssl_i386/ no-asm
edit Makefile
<pre>
Find CFLAG and add to the BEGINNING!!:
-D__OpenBSD__ 
</pre>
make
make install

make clean
./config --openssldir=/tmp/openssl/openssl_armv6/ no-asm
edit Makefile
<pre>
Find CC= cc and change it to:
CC= /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc-4.2

Find -arch i386 in CFLAG and change it to:
-arch armv6

Find CFLAG and add to the BEGINNING!!:
-isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS4.3.sdk -D__OpenBSD__

Find SHARED_LDFLAGS=-arch i386 -dynamiclib and change it to:
SHARED_LDFLAGS=-arch armv6 -dynamiclib

Find PEX_LIBS= -Wl, -search_paths_firstxc and change it to:
PEX_LIBS= -Wl
</pre>
edit crypto/ui/ui_openssl.c line 407:
static volatile sig_atomic_t intr_signal;
to
static volatile int intr_signal;
make
make install

repeat the process for armv7 (use /tmp/openssl/openssl_armv7/)

cd /tmp/openssl
cp -R openssl_i386/include include
mkdir lib
lipo -create openssl_i386/lib/libcrypto.a openssl_armv6/lib/libcrypto.a openssl_armv7/lib/libcrypto.a -output lib/libcrypto.a
lipo -create openssl_i386/lib/libssl.a openssl_armv6/lib/libssl.a openssl_armv7/lib/libssl.a -output lib/libssl.a

mkdir $PROJ/openssl
cp -R /tmp/openssl/include $PROJ/openssl/include
cp -R /tmp/openssl/lib $PROJ/openssl/lib


= boost =
# http://goodliffe.blogspot.com/2010/09/building-boost-framework-for-ios-iphone.html
cd /tmp
git clone git://gitorious.org/boostoniphone/boostoniphone.git
cd boostoniphone
edit boost.sh
* change SDK to 4.3
* replace 4.2.1 to 4.3 (many places)
# use boost_1_44_0 that comes with it. dont try newer boost versions
./boost.sh
open the xcode in the directory and drag-drop boost framework to your project

cp -R framework $PROJ/framework

= Berkley DB =
#download http://www.oracle.com/technetwork/database/berkeleydb/downloads/index.html
open in /tmp
#http://ankitthakur.wordpress.com/2011/01/16/build-scripts-for-berkely-db-static-libraries-with-ios-development/

cd /tmp/db-5.1.19
mkdir build_i386
mkdir build_armv6
mkdir build_armv7

cd build_unix
export DEV_iSimulator=/Developer/Platforms/iPhoneSimulator.platform/Developer 
export SDK_iSimulator=${DEV_iSimulator}/SDKs/iPhoneSimulator4.3.sdk 
export COMPILER_iSimulator=${DEV_iSimulator}/usr/bin
export CC=${COMPILER_iSimulator}/gcc
export CXX=${COMPILER_iSimulator}/g++
export LDFLAGS="-arch i386 -pipe -Os -gdwarf-2 -no-cpp-precomp -mthumb -isysroot ${SDK_iSimulator}"
export CFLAGS=${LDFLAGS}
export CXXFLAGS=${LDFLAGS}
export CPP="/usr/bin/cpp ${CPPFLAGS}"
export LD=${COMPILER_iSimulator}/ld
export AR=${COMPILER_iSimulator}/ar
export AS=${COMPILER_iSimulator}/as
export NM=${COMPILER_iSimulator}/nm
export RANLIB=${COMPILER_iSimulator}/ranlib
../dist/configure --prefix=/tmp/db-5.1.19/build_i386 --host=i386-apple-darwin10 --enable-cxx
make
make install

make clean
make realclean

export DEV_iOS=/Developer/Platforms/iPhoneOS.platform/Developer 
export SDK_iOS=${DEV_iOS}/SDKs/iPhoneOS4.3.sdk 
export COMPILER_iOS=${DEV_iOS}/usr/bin
export CC=${COMPILER_iOS}/gcc
export CXX=${COMPILER_iOS}/g++
export LDFLAGS="-arch armv6 -pipe -Os -gdwarf-2 -no-cpp-precomp -mthumb -isysroot ${SDK_iOS}"
export CFLAGS=${LDFLAGS}
export CXXFLAGS=${LDFLAGS}
export CPP="/usr/bin/cpp ${CPPFLAGS}"
export LD=${COMPILER_iOS}/ld
export AR=${COMPILER_iOS}/ar
export AS=${COMPILER_iOS}/as
export NM=${COMPILER_iOS}/nm
export RANLIB=${COMPILER_iOS}/ranlib
../dist/configure --prefix=/tmp/db-5.1.19/build_armv6 --host=arm-apple-darwin10 --enable-cxx
make
make install

export DEV_iOS=/Developer/Platforms/iPhoneOS.platform/Developer 
export SDK_iOS=${DEV_iOS}/SDKs/iPhoneOS4.3.sdk 
export COMPILER_iOS=${DEV_iOS}/usr/bin
export CC=${COMPILER_iOS}/gcc
export CXX=${COMPILER_iOS}/g++
export LDFLAGS="-arch armv7 -pipe -Os -gdwarf-2 -no-cpp-precomp -mthumb -isysroot ${SDK_iOS}"
export CFLAGS=${LDFLAGS}
export CXXFLAGS=${LDFLAGS}
export CPP="/usr/bin/cpp ${CPPFLAGS}"
export LD=${COMPILER_iOS}/ld
export AR=${COMPILER_iOS}/ar
export AS=${COMPILER_iOS}/as
export NM=${COMPILER_iOS}/nm
export RANLIB=${COMPILER_iOS}/ranlib
../dist/configure --prefix=/Users/udi/Documents/MyProjects/iPhone/db/db-5.1.19/build_armv7 --host=arm-apple-darwin10 --enable-cxx
make
make install


cd /tmp/db/
mkdir lib
lipo -create /tmp/db-5.1.19/build_i386/lib/libdb.a /tmp/db-5.1.19/build_armv6/lib/libdb.a /tmp/db-5.1.19/build_armv7/lib/libdb.a -output /tmp/db/lib/libdb.a
lipo -create /tmp/db-5.1.19/build_i386/lib/libdb_cxx.a /tmp/db-5.1.19/build_armv6/lib/libdb_cxx.a /tmp/db-5.1.19/build_armv7/lib/libdb_cxx.a -output /tmp/db/lib/libdb_cxx.a
cp -R /tmp/db-5.1.19/build_i386/include /tmp/db/include

cp -R /tmp/db $PROJ/db

= Three20 =
cd $PROJ

At the root directory where the project file is located do:
git submodule add git://github.com/facebook/three20.git three20
git submodule init
git add three20
git commit -m "Add Three20 submodule"
build the Twitter sample
add three20 to project:
> python three20/src/scripts/ttmodule.py -p full-path/BitCoin.xcodeproj Three20
> python three20/src/scripts/ttmodule.py -p full-path/BitCoin.xcodeproj extThree20JSON:extThree20JSON+SBJSON
