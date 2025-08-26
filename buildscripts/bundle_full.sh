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

# if [ ! -f "scripts/ffmpeg" ]; then
#   rm scripts/ffmpeg.sh
# fi
# cp flavors/full.sh scripts/ffmpeg.sh

# --------------------------------------------------

./build.sh

echo "libmpv build inner:"
ls -la /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/buildscripts/deps/mpv/_build

# --------------------------------------------------

cd deps/media-kit-android-helper

sudo chmod +x gradlew
./gradlew assembleRelease

unzip -o app/build/outputs/apk/release/app-release.apk -d app/build/outputs/apk/release

ln -sf "$(pwd)/app/build/outputs/apk/release/lib/arm64-v8a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/arm64-v8a"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/armeabi-v7a/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/armeabi-v7a"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/x86/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/x86"
ln -sf "$(pwd)/app/build/outputs/apk/release/lib/x86_64/libmediakitandroidhelper.so" "../../../libmpv/src/main/jniLibs/x86_64"

echo "libmediakitandroidhelper dir: $(realpath ../../../libmpv/src/main/jniLibs/armeabi-v7a)"
echo "libmediakitandroidhelper inner:"
ls -la ../../../libmpv/src/main/jniLibs/armeabi-v7a

cd ../..

# --------------------------------------------------

cd deps/media_kit/media_kit_native_event_loop

flutter create --org com.alexmercerind --template plugin_ffi --platforms=android .

if ! grep -q android "pubspec.yaml"; then
  printf "      android:\n        ffiPlugin: true\n" >> pubspec.yaml
fi

flutter pub get

cp -a ../../mpv/libmpv/. src/include/

cd example

flutter clean
flutter build apk --release

unzip -o build/app/outputs/apk/release/app-release.apk -d build/app/outputs/apk/release

cd build/app/outputs/apk/release/

# --------------------------------------------------

rm -r lib/*/libapp.so
rm -r lib/*/libflutter.so

# --------------------------------------------------

mkdir -p temp_dir/lib/arm64-v8a
mkdir -p temp_dir/lib/armeabi-v7a
mkdir -p temp_dir/lib/x86
mkdir -p temp_dir/lib/x86_64

cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/armeabi-v7a/libmediakitandroidhelper.so temp_dir/lib/armeabi-v7a/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/armeabi-v7a/libmpv.so temp_dir/lib/armeabi-v7a/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/arm64-v8a/libmediakitandroidhelper.so temp_dir/lib/arm64-v8a/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/arm64-v8a/libmpv.so temp_dir/lib/arm64-v8a/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/x86/libmediakitandroidhelper.so temp_dir/lib/x86/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/x86/libmpv.so temp_dir/lib/x86/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/x86_64/libmediakitandroidhelper.so temp_dir/lib/x86_64/
cp /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/libmpv/src/main/jniLibs/x86_64/libmpv.so temp_dir/lib/x86_64/

cd temp_dir

echo "final build temp_dir:"
ls -la ./lib/armeabi-v7a

zip -r "full-arm64-v8a.jar"                lib/arm64-v8a
zip -r "full-armeabi-v7a.jar"              lib/armeabi-v7a
zip -r "full-x86.jar"                      lib/x86
zip -r "full-x86_64.jar"                   lib/x86_64

# --------------------------------------------------

mkdir -p /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/output

cp *.jar /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/output

md5sum *.jar

echo "Output dir: $(realpath /home/runner/work/libmpv-android-video-build/libmpv-android-video-build/output)"
echo "Script dir: $(cd "$(dirname "$0")"; pwd)"