@echo off
echo ========================================
echo Regenerando archivos Freezed y JSON
echo ========================================
echo.

echo Instalando dependencias...
call flutter pub get

echo.
echo Regenerando archivos con build_runner...
call flutter pub run build_runner build --delete-conflicting-outputs

echo.
echo ========================================
echo PROCESO COMPLETADO
echo ========================================
echo.
echo Los archivos .g.dart y .freezed.dart han sido regenerados.
echo.
pause
