# --------------------------------------------------

if [ ! -f "deps" ]; then
  sudo rm -r deps
fi
if [ ! -f "prefix" ]; then
  sudo rm -r prefix
fi

./download.sh
./patch.sh

# --------------------------------------------------

if [ ! -f "scripts/ffmpeg" ]; then
  rm scripts/ffmpeg.sh
fi
cp flavors/full.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

mkdir -p temp_dir/lib/arm64-v8a
mkdir -p temp_dir/lib/armeabi-v7a
mkdir -p temp_dir/lib/x86
mkdir -p temp_dir/lib/x86_64

cp app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so      temp_dir/lib/arm64-v8a/
cp app/build/outputs/apk/release/lib/armeabi-v7a/libmediakitandroidhelper.so    temp_dir/lib/armeabi-v7a/
cp app/build/outputs/apk/release/lib/x86/libmediakitandroidhelper.so            temp_dir/lib/x86/
cp app/build/outputs/apk/release/lib/x86_64/libmediakitandroidhelper.so         temp_dir/lib/x86_64/

cp ../../prefix/arm64-v8a/usr/local/lib/*.so temp_dir/lib/arm64-v8a
cp ../../prefix/armeabi-v7a/usr/local/lib/*.so temp_dir/lib/armeabi-v7a
cp ../../prefix/x86/usr/local/lib/*.so temp_dir/lib/x86
cp ../../prefix/x86_64/usr/local/lib/*.so temp_dir/lib/x86_64

cd temp_dir

zip -r full-arm64-v8a.jar                lib/arm64-v8a/*.so
zip -r full-armeabi-v7a.jar              lib/armeabi-v7a/*.so
zip -r full-x86.jar                      lib/x86/*.so
zip -r full-x86_64.jar                   lib/x86_64/*.so

md5sum *.jar

echo "Output dir: $(realpath ../../../../../../../../output)"
echo "Script dir: $(cd "$(dirname "$0")"; pwd)"