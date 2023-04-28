# Demo Video
https://user-images.githubusercontent.com/89015620/235119766-28f46042-ae34-4982-bf9d-8351c610398d.MP4

# Nutrition-AI-Reels

Let's create some amazing Insta Reels and YouTube Shorts by leveraging real-time on-device food recognition! 

This repo gives you the code that can add an amazing reel-creator feature to your app. 
The reel-creator uses real-time on-device recognition of foods to create fabulous food log, recipe and "what I eat in a day videos". 

The repo come with a demo app that you can use out of the box. The code can be adjusted to meet your style and design needs, but the Reels-creator is working out of the box and is ready for integration into your app.

To use Passio's Nutrition-AI SDK you will need a license key. You can get one here: passio.ai/nutrition-ai The use of the SDK is free when you have under 10 active users so you can experiment and use it in demo and dev efforts for free.

# BEFORE YOU CONTINUE:
To use the SDK please make sure you receive your SDK license key from Passio. The SDK WILL NOT WORK without a valid SDK key.

# Minimum Requirements:
In order to use the PassioSDK your app needs to meet the following minimal requirements:

- The Demo will only run on iOS 14 or newer.
- Passio SDK can only be used on a device and will not run on a simulator
- The SDK requires access to iPhone's camera

# Try to run the Demo:
A fast and easy way to get started with the Demo and create Reels is to test it inside of Demo App included in this Repo. Here are the steps:

1. Open the project in Xcode:
2. Replace the SDK Key in the EntryViewController.swift file with the license key you get from Passio
3. Connect your iPhone and run
4. Modify the app bundle from "com.passio.NutritionAIReels" to "com.yourcompany...."
5. Run the demo app on your iPhone.
6. For support, please contact support@passiolife.com

# Integrate Nutrition AI Reels/Shorts Sharing feature into your project.

### Add PassioNutritionAISDK SDK into your project:

1. Drag and drop the "PassioNutritionAISDK.xcframework" into your project. Make sure to select "Copy items if needed".
2. In project "General" -> "Frameworks, Libraries and Embedded Content" Change to "Embed & Sign"
3. Edit your Info.plist
   - If opening from Xcode, right click and select 'open as source code' To allow camera usage add:
   - `<key>NSCameraUsageDescription</key><string>For real-time food recognition</string>`.

### Add necessary files into your project:
1. Drag and drop `EntryViewController.swift` and `FoodRecognitionController.swift` files into your project. Make sure to select "Copy items if needed".
2. Also add `EntryViewController` and `FoodRecognitionController` files from `Main.storyboard`.
3. Drag and drop **Views, Cell, Model, Media and Extension** folder into your project. Make sure to select "Copy items if needed".
4. Add **Colors and Images** from `Assets.xcassets`.
5. After adding all above files and folder, you'll be able to build and share Reels/Shorts direclty from your app.
6. You can customise the user interface to meet your own requirements.




