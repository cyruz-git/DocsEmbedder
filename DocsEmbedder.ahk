; ----------------------------------------------------------------------------------------------------------------------
; Name .........: DocsEmbedder
; Description ..: Tool that allows to embed a set of html related files inside a PE file.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; Changelog ....: Jan. 13, 2015 - v0.1   - First version.
; ..............: Jan. 22, 2015 - v0.1.1 - Now using the BinGet library to load the logo.
; License ......: GNU Lesser General Public License
; ..............: This program is free software: you can redistribute it and/or modify it under the terms of the GNU
; ..............: Lesser General Public License as published by the Free Software Foundation, either version 3 of the
; ..............: License, or (at your option) any later version.
; ..............: This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
; ..............: the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser 
; ..............: General Public License for more details.
; ..............: You should have received a copy of the GNU Lesser General Public License along with this program. If 
; ..............: not, see <http://www.gnu.org/licenses/>.
; ----------------------------------------------------------------------------------------------------------------------

#SingleInstance force
#NoTrayIcon
#NoEnv
#Include <BinGet>
#Include <PECreateEmpty>
#Include <UpdRes>

; ===[ CONSTANTS ]======================================================================================================
  SCRIPTNAME    := "DocsEmbedder"
  SCRIPTVERSION := "0.1"
  HELPWIDTH     := 1024
  HELPHEIGHT    := 500
  DOCPATH       := ( A_IsCompiled ) ? "res://" A_ScriptFullPath "/index.html" : A_ScriptDir "\docs\site\index.html"
; ======================================================================================================================

; ======================================================================================================================
; ===[ MAIN SECTION ]===================================================================================================
; ======================================================================================================================

Menu, FileMenu, Add, &Embed, 1BTN_C_EMBED
Menu, FileMenu, Add
Menu, FileMenu, Add, E&xit,  GUICLOSE
Menu, HelpMenu, Add, &Help,  1MENU_HELP
Menu, HelpMenu, Add
Menu, HelpMenu, Add, &About, 1MENU_ABOUT
Menu, MenuBar,  Add, &File,  :FileMenu
Menu, MenuBar,  Add, &Help,  :HelpMenu

Gui, 1:Menu, MenuBar
Gui, 1:Margin, 10, 10

If ( A_IsCompiled )
    GoSub, 1ADDPICTURE
Else
    ; Gui width: 500. Logo width: 376. To center it (500-376)/2 = 67.
    Gui, 1:Add, Picture, x67, %A_ScriptDir%\Logo.png

Gui, 1:Add, GroupBox,   w480 h120 x10 y+15, Required Parameters:
Gui, 1:Add, Text,       w60 x20 yp+30, PE File:
Gui, 1:Add, Edit,       w330 h23 x+10 y+-16 v1EDIT_A +Disabled
Gui, 1:Add, Button,     w50 h23 x+10 g1BTN_A_BROWSE, Browse
Gui, 1:Add, Text,       w60 x20 y+10, Html Folder:
Gui, 1:Add, Edit,       w330 h23 x+10 y+-16 v1EDIT_B +Disabled
Gui, 1:Add, Button,     w50 h23 x+10 g1BTN_B_BROWSE, Browse
Gui, 1:Add, CheckBox,   h20 x90 y+10 v1CBOX_A g1CBOX_A_FLATTEN, Flatten the html folder
Gui, 1:Add, CheckBox,   h20 x+10 v1CBOX_B +Disabled, Flatten to a temporary folder
Gui, 1:Add, Button,     w80 h23 x210 y+20 v1BTN_C g1BTN_C_EMBED, > Embed <
Gui, 1:Add, Statusbar,, Ready

Gui, 1:Show,, %SCRIPTNAME% :: Embed html docs in PE files
Return

; ======================================================================================================================
; ===[ LABELS ]=========================================================================================================
; ======================================================================================================================

1ADDPICTURE:
    ; Code based on http://www.autohotkey.com/forum/viewtopic.php?p=147052
    Gui, 1:Add, Text, w376 h110 x67 +0xE hwnd1TEXT_A_HWND
    szData  := 0, pData := UpdRes_LockResource("LOGO.PNG", 10, szData)
    hBitmap := BinGet_Bitmap(pData, szData)
    SendMessage, 0x172, 0, hBitmap,, ahk_id %1TEXT_A_HWND% ; 0x172 = STM_SETIMAGE, 0 = IMAGE_BITMAP
    GuiControl, 1:Move, %1TEXT_A_HWND%, w376 h110
    Return
;1ADDPICTURE

1DUMMY:
    FileInstall, Logo.png, DUMMY
    Return
;1DUMMY

1BTN_A_BROWSE:
    Gui, 1:+OwnDialogs
    FileSelectFile, sFile, S2,, Select the PE file in which the resources will be embedded:
    If ( ErrorLevel )
        Return
    GuiControl, 1:, 1EDIT_A, %sFile%
    Return
;1BTN_A_BROWSE

1BTN_B_BROWSE:
    Gui, 1:+OwnDialogs
    FileSelectFolder, sDir,, 0, Select the folder containing the html resources to embed:
    If ( ErrorLevel )
        Return
    GuiControl, 1:, 1EDIT_B, %sDir%
    Return
;1BTN_B_BROWSE

1BTN_C_EMBED:
    Gui, 1:+OwnDialogs
    Gui, 1:Submit, NoHide
    GuiControl, 1:Disable, 1BTN_C
    sFinalFile := 1EDIT_A, sFinalDir := 1EDIT_B
    
    If ( sFinalFile == "" || sFinalDir == "" ) {
        MsgBox, 0x10, %SCRIPTNAME%, PE File or/and Html Folder missing.
        GuiControl, 1:Enable, 1BTN_C
        Return
    }
    
    If ( (sErrMsg := CheckDirAndFilenames(sFinalDir, 1CBOX_A)) != "" ) {
        MsgBox, 0x10, %SCRIPTNAME%, %sErrMsg%
        GuiControl, 1:Enable, 1BTN_C
        Return
    }
    
    If ( 1CBOX_A )
        SB_SetText("Flattening html folder...")
      , FlattenFiles(sFinalDir, (( 1CBOX_B ) ? A_Temp "\" SCRIPTNAME : ""))
      , sFinalDir := ( 1CBOX_B ) ? A_Temp "\" SCRIPTNAME : sFinalDir
      , ReplaceHrefs(sFinalDir)
    
    If ( !FileExist(sFinalFile) )
        SB_SetText("Creating empty binary file...")
      , PECreateEmpty(sFinalFile)
    
    SB_SetText("Embedding resources...")
    ; 0 = DELETE OLD, 23 = RT_HTML, 0 = NEUTRAL LANG ID
    UpdRes_UpdateDirOfResources(sFinalDir, sFinalFile, 0, 23, 0)
    
    ; Remove the temporary folder if the checkboxes are both selected.
    If ( 1CBOX_A && 1CBOX_B )
        FileRemoveDir, %A_Temp%\%SCRIPTNAME%, 1
    
    SB_SetText("Done.")
    GuiControl, 1:Enable, 1BTN_C
    MsgBox, 0x40, %SCRIPTNAME%, Embedding complete.
    Return
;1BTN_C_EMBED

1CBOX_A_FLATTEN:
    GuiControlGet, bVal, 1:, 1CBOX_A
    GuiControl, 1:Enable%bVal%, 1CBOX_B
    Return
;1CBOX_A_FLATTEN

1MENU_HELP:
    ShowBrowser(HELPWIDTH, HELPHEIGHT, SCRIPTNAME " - Help", DOCPATH)
    Return
;HELP

1MENU_ABOUT:
    Gui, 1:+OwnDialogs
    MsgBox, 0x40, %SCRIPTNAME%,
    ( LTrim
        %SCRIPTNAME% - %SCRIPTVERSION%
        Embed html documentation in the desired Portable Executable file.
        
        Project:`thttps://github.com/cyruz-git/DocsEmbedder
        Forum:`thttp://ahkscript.org/boards/viewtopic.php?f=6&t=5918
        
        Copyright ©2015 - Ciro Principe (http://ciroprincipe.info)
    )
    Return
;ABOUT

GUICLOSE:
    ExitApp
;GUICLOSE

; ======================================================================================================================
; ===[ FUNCTIONS ]======================================================================================================
; ======================================================================================================================

; Check if a directory contains any file.
IsDirEmpty(sDir, nRecur:=0) {
    Loop, %sDir%\*, 0, %nRecur%
        Return 0
    Return 1
}

; Check directory for emptyness and files for malformed file names (e.g. only numbers).
CheckDirAndFilenames(sDir, bFlatten) {
    sRegex = iS)^[\d\W]+(?!\w)
    
    bFlagFlatt := IsDirEmpty(sDir)
    bFlagRecur := IsDirEmpty(sDir, 1)
    
    If ( bFlagRecur)
        Return "The selected folder is empty, please select a different one."
    If ( !bFlatten && bFlagFlatt )
        Return "The root folder doesn't contain any file, please flatten it or select a different one."
    
    Loop, %sDir%\*, 0, 1
        If ( RegExMatch(A_LoopFileName, sRegex) )
            Return "Some files have a wrong name. Please verify that no file "
                 . "with a name composed solely of digits or/and spaces exists."
                 
    Return ""
}

; Move all the files to the root directory, flattening it.
FlattenFiles(sDir, sTempDir:="") {
    If ( isDirEmpty(sDir, 1) )
        Return 0
    If ( sTempDir != "" ) {
        If ( InStr(FileExist(sTempDir), "D") )
            FileRemoveDir, %sTempDir%, 1
        FileCopyDir, %sDir%, %sTempDir%, 1
        sDir := sTempDir
    }
    ; Loop root directories. No recursion.
    Loop, %sDir%\*, 2
    {
        sCurDir := A_LoopFileLongPath
        Loop, %sCurDir%\*, 0, 1   ; Loop files recursively.
            FileMove, %A_LoopFileLongPath%, %sDir%
        ; Remove now empty directory.
        FileRemoveDir, %sCurDir%, 1
    }
    Return 1
}

; Replace the href/src/url attributes inside html and css files.
; The directory must be flattened.
ReplaceHrefs(sDir) {
    sRegex_htm = iS)(?:(href|src)\s*=\s*("|')\s*[^:"']*(?:\/|\\))(?=[^\/\\:"']+\s*["'])
    sSubst_htm = $1=$2
    sRegex_css = iS)(?:url\s*\(("|')\s*[^:"']*(?:\/|\\))(?=[^\/\\:"']+\s*["'])
    sSubst_css = url($1
    
    Loop, %sDir%\*.*    ; No recursion.
    {
        If ( InStr(A_LoopFileExt, "htm") || InStr(A_LoopFileExt, "css") ) {
            FileRead, sContent, %A_LoopFileLongPath%
            sRegex := ( InStr(A_LoopFileExt, "htm") ) ? sRegex_htm : sRegex_css
            sSubst := ( InStr(A_LoopFileExt, "htm") ) ? sSubst_htm : sSubst_css
            sContent := RegExReplace(sContent, sRegex, sSubst)
            FileDelete, %A_LoopFileLongPath%
            FileAppend, %sContent%, %A_LoopFileLongPath%
        }
    }
}

; Show a res:// url in an embedded WebBrowser ActiveX object.
ShowBrowser(nW, nH, sGuiName, sResUrl) {
    Static 2AX_A, 2AX_A_HWND
    
    Gui, 2:Destroy
    Gui, 2:+Resize
    Gui, 2:Add, ActiveX, w%nW% h%nH% x0 y0 v2AX_A hwnd2AX_A_HWND, Shell.Explorer
    2AX_A.Silent := True
    2AX_A.Navigate(sResUrl)
    Gui, 2:Show,, %sGuiName%
    Return
    
    2GUICLOSE:
        Gui, 2:Destroy
        Return
   ;2GUICLOSE
   
    2GUISIZE:
        WinMove, % "ahk_id " . 2AX_A_HWND, , 0,0, A_GuiWidth, A_GuiHeight
        Return
   ;2GUISIZE
}
