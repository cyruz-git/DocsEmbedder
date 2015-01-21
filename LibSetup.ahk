; ----------------------------------------------------------------------------------------------------------------------
; Name .........: LibSetup
; Description ..: Generic lib retrieval tool.
; AHK Version ..: AHK_L 1.1.13.01 x32/64 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; ----------------------------------------------------------------------------------------------------------------------

; ===[ LIB VARIABLES ]==================================================================================================
  LIB_URL_1 = https://raw.githubusercontent.com/cyruz-git/ahk-libs/master/PECreateEmpty.ahk
  LIB_FNM_1 = PECreateEmpty.ahk

  LIB_URL_2 = https://raw.githubusercontent.com/cyruz-git/ahk-libs/master/UpdRes.ahk
  LIB_FNM_2 = UpdRes.ahk
; ======================================================================================================================

If ( !InStr(FileExist(A_ScriptDir "\lib"), "D") )
    FileCreateDir, %A_ScriptDir%\lib

While ( (liburl := LIB_URL_%A_Index%) && (libfnm := LIB_FNM_%A_Index%) )
    UrlDownloadToFile, %liburl%, %A_ScriptDir%\lib\%libfnm%