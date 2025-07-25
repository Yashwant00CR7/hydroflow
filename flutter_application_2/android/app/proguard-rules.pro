# Keep the JP2Decoder class and related PDFBox classes
-keep class com.gemalto.jp2.** { *; }
-keep class com.tom_roush.pdfbox.** { *; }
-dontwarn com.gemalto.jp2.**
-dontwarn com.tom_roush.pdfbox.**