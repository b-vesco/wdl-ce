#! /bin/sh

BASEDIR=$(dirname $0)

cd $BASEDIR

echo "making IPlugEffect mac distribution..."
echo ""
if [ -d dist ] 
then
	rm -R dist
fi

mkdir dist

#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target VST_32_ub -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target AU_32_ub -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target VST_32_intel -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target AU_32_intel -configuration Release
xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target "VST_32&64_intel" -configuration Release
xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target "AU_32&64_intel" -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target VST_32&64_ub -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -xcconfig IPlugEffect.xcconfig -target AU_32&64_ub -configuration Release

# check binarys to see what architechtures are inside
echo "verify architectures..."
echo ""
file /Library/Audio/Plug-Ins/Components/IPlugEffect.component/Contents/MacOS/IPlugEffect 
echo ""
file /Library/Audio/Plug-Ins/VST/IPlugEffect.vst/Contents/MacOS/IPlugEffect 

echo "copying and zipping binaries..."
echo ""
cp -R /Library/Audio/Plug-Ins/Components/IPlugEffect.component dist/IPlugEffect.component
cp -R /Library/Audio/Plug-Ins/VST/IPlugEffect.vst dist/IPlugEffect.vst

ditto -c -k dist IPlugEffect-mac.zip
rm -R dist

echo "done"