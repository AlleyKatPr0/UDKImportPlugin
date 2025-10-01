#pragma once

// Core includes
#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

// Engine includes
#include "Engine/Engine.h"
#include "UObject/ObjectMacros.h"
#include "UObject/UObjectGlobals.h"

// Editor includes
#include "Editor.h"
#include "UnrealEdGlobals.h"
#include "Editor/UnrealEdEngine.h"

// Slate includes
#include "Widgets/DeclarativeSyntaxSupport.h"
#include "Widgets/SCompoundWidget.h"
#include "Widgets/SWindow.h"
#include "Widgets/Layout/SBox.h"
#include "Widgets/Input/SButton.h"
#include "Widgets/Input/SEditableTextBox.h"
#include "Widgets/Input/SComboBox.h"
#include "Widgets/Text/STextBlock.h"
#include "Framework/Application/SlateApplication.h"

// Level editor
#include "LevelEditor.h"
#include "Layers/ILayers.h"

// Asset tools
#include "AssetToolsModule.h"
#include "IAssetTools.h"

// Material expression includes
#include "Materials/MaterialExpressionTextureSample.h"
#include "Materials/MaterialExpressionTextureBase.h"
#include "Materials/MaterialExpressionComment.h"
#include "Materials/MaterialExpressionConstant4Vector.h"
#include "Materials/MaterialExpressionConstant3Vector.h"
#include "Materials/MaterialExpressionMaterialFunctionCall.h"
#include "Materials/MaterialExpressionConstant.h"

// Version-specific includes
#if ENGINE_MAJOR_VERSION >= 5
	#include "Styling/AppStyle.h"
#else
	#include "EditorStyleSet.h"
#endif

// Plugin interface
#include "IUDKImportPlugin.h"