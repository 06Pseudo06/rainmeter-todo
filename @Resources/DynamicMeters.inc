@IncludeMUI=#@#MUI.inc
[MeterCardBackground]
Meter=Shape
Shape=Rectangle 0,0,42,42,12,12 | Fill Color 252,250,246,245 | StrokeWidth 1 | Stroke Color 232,226,218,255
DynamicVariables=1
[MeterCollapsedHeart]
Meter=String
Text=#mui-heart#
FontFace=Material Icons
FontSize=15
FontColor=225,120,135,255
StringAlign=CenterCenter
SolidColor=0,0,0,1
AntiAlias=1
X=21
Y=21
ToolTipText=Click to expand To-Do widget
LeftMouseUpAction=[!CommandMeasure "MeasureDynamicTasks" "SetCollapsed(0)"]