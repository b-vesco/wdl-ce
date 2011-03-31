#! /bin/sh

BASEDIR=$(dirname $0)

cd $BASEDIR

echo "making IPlugEffect mac distribution..."

if [ -d dist ] 
then
	rm -R dist
fi

mkdir dist

#xcodebuild -project IPlugEffect.xcodeproj -target VST_32_ub -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -target AU_32_ub -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -target VST_32_intel -configuration Release
#xcodebuild -project IPlugEffect.xcodeproj -target AU_32_intel -configuration Release
xcodebuild -project IPlugEffect.xcodeproj -target VST_32&64_intel -configuration Release
xcodebuild -project IPlugEffect.xcodeproj -target AU_32&64_intel -configuration Release

cp -R /Library/Audio/Plug-Ins/Components/IPlugEffect.component dist/IPlugEffect.component
cp -R /Library/Audio/Plug-Ins/VST/IPlugEffect.vst dist/IPlugEffect.vst

ditto -c -k dist IPlugEffect-mac.zip
rm -R dist

echo "done"