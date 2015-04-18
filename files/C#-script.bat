/*
@echo off && cls
set WinDirNet=%WinDir%\Microsoft.NET\Framework
IF EXIST "%WinDirNet%\v2.0.50727\csc.exe" set csc="%WinDirNet%\v2.0.50727\csc.exe"
IF EXIST "%WinDirNet%\v3.5\csc.exe" set csc="%WinDirNet%\v3.5\csc.exe"
IF EXIST "%WinDirNet%\v4.0.30319\csc.exe" set csc="%WinDirNet%\v4.0.30319\csc.exe"
%csc% /platform:x86 /nologo /out:"%~0.exe" %0
"%~0.exe" %1 %2 %3 %4 %5 %6 %7 %8
del "%~0.exe"
exit
*/
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class Program
{
    static void Main(string[] args)
    {
        try
        {
            Console.WriteLine("Hello, World!");
        }
        catch (Exception e)
        {
            Console.WriteLine("*** ERROR ***: " + e.Message);
        }
    }
}    
