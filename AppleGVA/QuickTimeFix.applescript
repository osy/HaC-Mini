tell application "QuickTime Player" to activate
tell application "QuickTime Player" to quit
do shell script "cp /Library/Preferences/com.apple.AppleGVA.plist ~/Library/Containers/com.apple.QuickTimePlayerX/Data/Library/Preferences/"
display alert "QuickTime fixed for this user. You can delete this script."